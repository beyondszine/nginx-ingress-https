#!/bin/bash

if [[ -z $1 && -z $2 && -z $3 && -z $4 ]]
then
    echo "No environment for TLS certificate supplied!  Available options: "staging" or "prod" "
    echo "AND/OR no email id given."
    echo "AND/OR no namespace for ingress given."
    echo "AND/OR no hostname for ingress given."
    echo "Usage: bash ./ingresshttps.sh "prod" "me@mywebsite.com" "default" "www.myhostname.com" "
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
myemailid=$2
ingressnamespace=$3
ingresshostname=$4

acmeprodserver="https://acme-v02.api.letsencrypt.org/directory"
acmeprodname="letsencrypt-prod"
acmestagingserver="https://acme-staging-v02.api.letsencrypt.org/directory"
acmestagingname="letsencrypt-staging"

echo $tlstargetenvironment
echo $myemailid
echo $ingressnamespace
echo $ingresshostname

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

clusterissuername="acme"$tlstargetenvironment"name"
clusterissuerserver="acme"$tlstargetenvironment"server"

echo "Generating cluster-issuer file for your environment: "$tlstargetenvironment
clusterenvfile="cluster-issuer-"$tlstargetenvironment".yml"
echo "Generated $clusterenvfile file"
sed "s/{cluster-issuer-name}/${!clusterissuername}/g; s/{serverurl}/${!clusterissuerserver}/g; s/{myemailid}/$myemailid/g;" cluster-issuer-template.yml > $clusterenvfile

if [ $? -ne 0 ]
then
    echo "Sed error occured while replacing template; Exiting"
    exit
fi

kubectl apply -f $clusterenvfile
kubectl describe clusterissuer $acmeprodname | grep 'Ready'
sleep 5
if [ $? -ne 0 ]
then
    echo "Cluster issuer not yet ready!  Try again in a while."
    exit
fi

echo "Generating ingress resource yaml file."
sed "s/{acme-environment-name}/${!clusterissuername}/g; s/{namespace}/$ingressnamespace/g; s/{ingresshostname}/$ingresshostname/g;" templates/ingressl7-template.yml > ingress-resource.yml

echo "now issue 'kubectl apply -f ingress-resource.yml'"


