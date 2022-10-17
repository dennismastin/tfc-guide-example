#!/bin/bash

# These should be set as env vars in both standalone and tf-cloud - category: env
# The certfile needs to be on disk - for tf cloud, ?checked into git?
export CONJUR_CERT_FILE="./conjur-cloud-sempra.pem"
export CONJUR_AUTHN_API_KEY="<<<<api-key-for-conjur-host-below>>>"
export CONJUR_AUTHN_LOGIN="host/tf-host-aws"
export CONJUR_ACCOUNT="conujur"  # Always 'conjur' for conjur-cloud
export CONJUR_APPLIANCE_URL="https://ec2-xx-xxx-xx-xxx.us-west-1.compute.amazonaws.com"