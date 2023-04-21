#!/bin/bash

# These should be set as env vars in both standalone and tf-cloud - category: env
# The certfile needs to be on disk - for tf cloud, ?checked into git?
export CONJUR_CERT_FILE="./conjur-cloud-sempra.pem"
export CONJUR_AUTHN_API_KEY="<<<<api-key-for-conjur-host-below>>>"
export CONJUR_AUTHN_LOGIN="host/tf-host-aws"
export CONJUR_ACCOUNT="conujur"  # Always 'conjur' for conjur-cloud
export CONJUR_APPLIANCE_URL="https://ec2-xx-xxx-xx-xxx.us-west-1.compute.amazonaws.com"


## Flows Vars for Jody_Test
#######################################
# Flows Tenant Parameters  In TF_Cloud VARS
export FLOWS_ADMIN_USER=jody_bot@cyberark.cloud.3357
export FLOWS_ADMIN_PWD="<<SENSITIVE>>"
export FLOWS_TENANT=acj5413.flows.integration-cyberark.cloud
export FLOW_NAME=JodyTest-01-Provision
export FLOWS_REQUESTOR=dennis.mastin@cyberark.com

# Workload inputs P-Cloud Parameters  In TF_CLOUD VARS
export APP_ID=AnsibleId
export SAFE_NAME=rh_bot
export SSH_ACCOUNT_NAME=Flows-SSH
export SSH_USER=ubuntu

# From Outputs of TF_CLOUD Run
export SSH_PKEY="<<From Outputs>>"
export SSH_ADDRESS="<<From Outputs>>"
#######################################

# User_data
echo
echo "Running:"
echo "  Tenant: $FLOWS_TENANT"
echo "  Flow: $FLOW_NAME"
echo "  AppID: $APP_ID"
echo "  SafeName: $SAFE_NAME"
echo "  RequestorEmail: $REQUESTOR"
echo "  SshAcctName: $SSH_ACCOUNT_NAME"
echo "  SshUser: $SSH_USER"
echo "  SshPkey: $SSH_PKEY"
echo "  SshAddress: $SSH_ADDRESS"
echo
set -x
curl -k -X POST						\
	-H 'Content-Type: application/json' 		\
	--data "{					\
		\"adminId\": \"$FLOWS_ADMIN_USER\",		\
		\"adminPassword\": \"$FLOWS_ADMIN_PWD\",	\
		\"appId\": \"$APP_ID\",			\
		\"safeName\": \"$SAFE_NAME\",		\
		\"requestorEmail\": \"$FLOWS_REQUESTOR\",	\
		\"sshAcctName\": \"$SSH_ACCOUNT_NAME\",	\
		\"sshUser\": \"$SSH_USER\",		\
		\"sshPkey\": \"$SSH_PKEY\",		\
		\"sshAddress\": \"$SSH_ADDRESS\"	\
	}"						\
	https://$FLOWS_TENANT/flows/$FLOW_NAME/play
echo
echo
