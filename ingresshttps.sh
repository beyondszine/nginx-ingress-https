#!/bin/bash

if [[ -z $1 && -z $2 ]]
then
    echo "No environment for TLS certificate supplied!  Available options: "staging" or "prod" "
    echo "AND/OR no valid email id given."
    echo "Usage: bash ./ingresshttps.sh "prod" "me@mywebsite.com" "
    exit
fi
if [[ $1 == "prod" || $1 == "staging" ]]
then
    echo "Will setup cluster TLS with letsencrypt "$1
else
    echo "Not a valid environment"
    exit
fi

tlstargetenvironment=$1
memailid=$2
acmeprodserver="https://acme-v02.api.letsencrypt.org/directory"
acmeprodname="letsencrypt-prod"
acmestagingserver="https://acme-staging-v02.api.letsencrypt.org/directory"
acmestagingname="letsencrypt-staging"

echo $tlstargetenvironment
echo $memailid

# kubectl create namespace cert-manager
# kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
# kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/cert-manager.yaml --validate=false

# kubectl apply -f test-resources.yaml 
# kubectl describe certificate -n cert-manager-test | grep 'Certificate issued successfully'
# if [ $? -eq 0 ]
# then
#     echo "cert-manager is set up correctly and able to issue basic certificate types"
# fi

clusterissuername="acme"$tlstargetenvironment"name"
clusterissuerserver="acme"$tlstargetenvironment"server"
# printf -v clusterissuername "$t_clusterissuername" "$tlstargetenvironment"
# printf -v clusterissuerserver "$t_clusterissuerserver" "$tlstargetenvironment"


echo ${!clusterissuername}
echo ${!clusterissuerserver}

echo "Generating cluster-issuer file for your environment: "$tlstargetenvironment
sed "s/{cluster-issuer-name}/${!clusterissuername}/g; s/{serverurl}/${!clusterissuerserver}/g; s/{myemailid}/$memailid/g;" cluster-issuer-template.yml > cluster-issuer-$tlstargetenvironment.yml