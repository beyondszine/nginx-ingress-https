#!/bin/bash

if [ -z $1 && -z $2 ]
then
    echo "No environment for TLS certificate supplied!  Available options: "staging" or "prod" "
    echo "AND/OR no valid email id given."
    echo "Usage: bash ./ingresshttps.sh "prod" "me@mywebsite.com" "
    exit
fi


if [ $1 -eq "prod" || $1 -eq "staging" ]
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

    # Install the CustomResourceDefinition resources
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml

    # Install cert-manager itself
    # If you are running kubectl v1.12(which WE ARE as on 15-02-19) or below, you will need to add the --validate=false flag to your kubectl apply
    # as per https://docs.cert-manager.io/en/latest/getting-started/install.html#installing-with-helm
    # Ref: https://docs.microsoft.com/en-us/azure/aks/ingress-tls
    #      https://github.com/jetstack/cert-manager

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/cert-manager.yaml --validate=false

    # Now the output should be something like this:
    # ubuntu@dummy:~/ingress$ kubectl get pods -n=cert-manager
    # NAME                                    READY   STATUS      RESTARTS   AGE
    #cert-manager-7476cc944f-qwl42           1/1     Running     0          38m
    #cert-manager-webhook-78bb4bfdb8-pwjzq   1/1     Running     0          38m
    #cert-manager-webhook-ca-sync-6fvb6      0/1     Completed   0          37m

kubectl apply -f test-resources.yaml 

    # check: confirm that cert-manager is set up correctly and able to issue basic certificate types:
    #ubuntu@dummy:~/ingress$ kubectl describe certificate -n cert-manager-test
    #Name:         selfsigned-cert
    #Namespace:    cert-manager-test
    #Labels:       <none>
    #Annotations:  kubectl.kubernetes.io/last-applied-configuration:
    #                {"apiVersion":"certmanager.k8s.io/v1alpha1","kind":"Certificate","metadata":{"annotations":{},"name":"selfsigned-cert","namespace":"cert-m...
    #API Version:  certmanager.k8s.io/v1alpha1
    #Kind:         Certificate
    #Metadata:
    #  Creation Timestamp:  2019-02-15T09:35:30Z
    #  Generation:          1
    #  Resource Version:    4232546
    #  Self Link:           /apis/certmanager.k8s.io/v1alpha1/namespaces/cert-manager-test/certificates/selfsigned-cert
    #  UID:                 08e8bab8-3105-11e9-a99a-0e0a076cd7f4
    #Spec:
    #  Common Name:  example.com
    #  Issuer Ref:
    #    Name:       test-selfsigned
    #  Secret Name:  selfsigned-cert-tls
    #Status:
    #  Conditions:
    #    Last Transition Time:  2019-02-15T09:35:30Z
    #    Message:               Certificate is up to date and has not expired
    #    Reason:                Ready
    #    Status:                True
    #    Type:                  Ready
    #  Not After:               2019-05-16T09:35:30Z
    #Events:
    #  Type    Reason      Age   From          Message
    #  ----    ------      ----  ----          -------
    #  Normal  CertIssued  37m   cert-manager  Certificate issued successfully

kubectl describe certificate -n cert-manager-test | grep 'Certificate issued successfully'
if [ $? -eq 0 ]
then
echo "cert-manager is set up correctly and able to issue basic certificate types"
fi

    #  set up a basic ACME issuer, create a new Issuer or ClusterIssuer resource
 
 if [ $1   