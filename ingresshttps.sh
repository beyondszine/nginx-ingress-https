#!/bin/bash

if [[ -z $1 && -z $2 ]]
then
    echo "No environment for TLS certificate supplied!  Available options: "staging" or "prod" "
    echo "AND/OR no valid email id given."
    echo "Usage: bash ./ingresshttps.sh "prod" "me@mywebsite.com" "
    exit
fi
if [[ $1 -eq "prod" || $1 -eq "staging" ]]
then
    echo "Will setup cluster TLS with letsencrypt "$1
else
    echo "Not a valid environment"
    exit
fi

TlsTargetEnvironment=$1
mEmailId=$2

echo $TlsTargetEnvironment
echo $mEmailId
exit

kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/cert-manager.yaml --validate=false

kubectl apply -f test-resources.yaml 
kubectl describe certificate -n cert-manager-test | grep 'Certificate issued successfully'
if [ $? -eq 0 ]
then
    echo "cert-manager is set up correctly and able to issue basic certificate types"
fi
if [ $1   