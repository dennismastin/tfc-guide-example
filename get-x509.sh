#!/bin/bash



FQDN=sempra-p.secretsmgr.cyberark.cloud

#openssl s_client -servername $FQDN -connect $FQDN:443 2>/dev/null | \
#    openssl x509 -text

    openssl s_client -showcerts -connect $FQDN:443  < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'