#!/bin/bash

conjur_fqdn="ec2-xx-xxx-xxx-xxx.us-west-1.compute.amazonaws.com"
conjur_password="<<xxxxxxxxx>>>>>"
account="sempra"

#todo: Rework conjur docker image storage
#conjur_appliance_image="conjur-appliance:12.6.0"
conjur_appliance_image="registry.tld/conjur-appliance:12.6.0"

#todo: add full urls, to allow for single cert for all scenarios
conjur_alt_names=conjur1,conjur2,conjur3,follower1,follower2
config_dir="/home/ubuntu/.config/$account"

startConjur() {
  echo "Starting conjur container"

  echo "Creating local folders."
  sudo -i -u ubuntu mkdir -p "$config_dir"
  sudo -i -u ubuntu mkdir -p "$config_dir"/{security,configuration,backup,seeds,logs}

  echo "Place config files"
  sudo -u ubuntu cp ./config/conjur.yml "$config_dir"

  #todo: Rework conjur docker image storage
  #docker login -u dlangdocker -p secretless

  docker network create conjur-net

  echo "docker run...$conjur_appliance_image"
  docker run \
  --name conjur1 \
  --detach \
  --restart=always \
  --security-opt seccomp:unconfined \
  --publish "443:443" \
  --publish "444:444" \
  --publish "5432:5432" \
  --publish "1999:1999" \
  --volume "$config_dir"/conjur.yml:/etc/conjur/config/conjur.yml:Z \
  --volume "$config_dir"/configuration:/opt/cyberark/dap/configuration:Z \
  --volume "$config_dir"/security:/opt/cyberark/dap/security:Z \
  --volume "$config_dir"/backup:/opt/conjur/backup:Z \
  --volume "$config_dir"/seeds:/opt/cyberark/dap/seeds:Z \
  --volume "$config_dir"/logs:/var/log/conjur:Z \
  --net conjur-net \
  $conjur_appliance_image

  echo "evoke configure... ($conjur_fqdn)"
  docker exec conjur1 evoke configure master \
    --debug \
    --accept-eula \
    --hostname $conjur_fqdn \
    --master-altnames $conjur_alt_names \
    --admin-password $conjur_password \
    $account

   #namespace=conjur
   #appliance_service_name=follower-appliance
   #docker exec conjur1 evoke ca issue -f follower-appliance \
   #  ${appliance_service_name}.${namespace}.svc.cluster.local

   mkdir -p /home/ubuntu/.secrets
   docker cp conjur1:/opt/conjur/etc/ssl/$conjur_fqdn.pem /home/ubuntu/.secrets/conjur.pem
   #docker cp conjur1:/opt/conjur/etc/ssl/follower-appliance.pem /home/ubuntu/.secrets/follower-appliance.pem

}

setPolicy() {
    echo "Loading Authenticator policy."
    auth_token=$(authenticate admin)
    #echo "auth_token $auth_token"

    load_policy root ./policy/root/1-conjur-admins.yml #> "$PWD"/admin_users_api.txt
    load_policy root ./policy/root/2-conjur-auditors.yml #> "$PWD"/auditors_users_api.txt
    load_policy root ./policy/root/3-root.yml #> /dev/null
    load_policy root ./policy/root/4-secrets.yml #> /dev/null
    load_policy root ./policy/root/5-root-permits.yml #> /dev/null

    load_policy root ./policy/authenticators/authn-k8s.yml
    load_policy root ./policy/authenticators/k8s-seed-fetcher.yml

    load_policy root ./policy/cd/kubernetes/1-k8s-follower-auto-configuration.yml
    load_policy root ./policy/cd/kubernetes/2-k8s-dev-team-1.yml
    load_policy root ./policy/cd/kubernetes/3-k8s-dev-team-1-apps.yml
    load_policy root ./policy/cd/kubernetes/8-k8s-grants.yml

}

load_policy() {
  urlencoded_policy=$(echo -n "$1" | sed 's/\//\%2F/g')
  policy_output=$(curl -k -s -X POST\
                       --header "Authorization: Token token=\"$auth_token\"" \
                       -d "$(cat "$2")" https://$conjur_fqdn/policies/$account/policy/"$urlencoded_policy")
  echo $policy_output
}

load_policy_file() {
  urlencoded_policy=$(echo -n "$1" | sed 's/\//\%2F/g')

  policy_output=$(curl --insecure --silent \
  --request PUT "https://$conjur_fqdn/policies/$account/policy/$urlencoded_policy" \
  --header 'X-Request-Id: <string>' \
  --header 'Content-Type: text/plain' \
  --header "Authorization: Token token=\"$auth_token\"" \
  --data-binary "@$2")

  echo $policy_output
}

authenticate() {
  api_key=$(curl -k -s -X GET -u admin:"$conjur_password" https://$conjur_fqdn/authn/"$account"/login)
  curl -k -s -X POST \
       --header "Accept-Encoding: base64" \
       --data "$api_key" https://$conjur_fqdn/authn/$account/"$1"/authenticate
}

configureConjur(){
  echo "Setting internal CA and Key"

  docker exec conjur1 bash -c "openssl genrsa -out ca.key 2048" &> /dev/null
  docker exec conjur1 bash -c "openssl genrsa -out ca2.key 2048" &> /dev/null

  CONFIG="
  [ req ]
  distinguished_name = dn
  x509_extensions = v3_ca
  [ dn ]
  [ v3_ca ]
  basicConstraints = critical,CA:TRUE
  subjectKeyIdentifier   = hash
  authorityKeyIdentifier = keyid:always,issuer:always
  "

  docker exec conjur1 bash -c "openssl req -x509 -new -nodes -key ca.key -sha1 -days 3650 -set_serial 0x0 -out ca.cert -subj "/CN=conjur.authn-k8s.cluster1/OU=Conjur Kubernetes CA/O=$account" -config <(echo "$CONFIG")"
  docker exec conjur1 bash -c "openssl req -x509 -new -nodes -key ca2.key -sha1 -days 3650 -set_serial 0x0 -out ca2.cert -subj "/CN=conjur.authn-k8s.cluster2/OU=Conjur Kubernetes CA/O=$account" -config <(echo "$CONFIG")"

  # cmd to inspect certs
  #openssl x509 -in ca.cert -text -noout
  #openssl x509 -in ca2.cert -text -noout

  auth_token=$(authenticate admin)
  formatted_token="Token token=\"$auth_token\""

  echo "";
  curl -k -s --header "Authorization: $formatted_token" -X POST \
       -d "$(docker exec conjur1 bash -c "cat ca.key")" \
       https://localhost/secrets/$account/variable/conjur/authn-k8s/cluster1/ca/key

  echo "";
  curl -k -s --header "Authorization: $formatted_token" -X POST \
       -d "$(docker exec conjur1 bash -c "cat ca.cert")" \
       https://localhost/secrets/"$account"/variable/conjur/authn-k8s/cluster1/ca/cert
}

seed_secrets() {
  echo "Creating dummy secrets"
  for (( count=9; count<=9; count++ ))
  do
    for ((secret_count=1; secret_count<=9; secret_count++))
    do
      secret=$(LC_ALL=C < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
      curl -k -s --header "Authorization: Token token=\"$auth_token\"" -X POST \
           -d "$secret" https://localhost/secrets/"$account"/variable/vault9/lob9/safe"$count"/secret"$secret_count"
    done
  done
}

main(){
  echo "conjur_fqdn: $conjur_fqdn"
  startConjur
  #setPolicy
  #configureConjur
  #seed_secrets
}

main