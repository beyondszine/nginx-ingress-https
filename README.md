
Usage:
```sh
echo "Usage: bash ./ingresshttps.sh "prod" "me@mywebsite.com" "
```

Description:
This aims to provide single command line based TLS enabling on nginx-ingress.


Srcs:
    - https://github.com/jetstack/cert-manager/blob/master/docs/tutorials/acme/quick-start/example/production-issuer.yaml
    - https://docs.cert-manager.io/en/latest/getting-started/install.html#installing-with-helm
    - https://docs.microsoft.com/en-us/azure/aks/ingress-tls
    - https://github.com/jetstack/cert-manager
    - https://medium.com/@maninder.bindra/auto-provisioning-of-letsencrypt-tls-certificates-for-kubernetes-services-deployed-to-an-aks-52fd437b06b0

Notes:
While installing cert-manager itself If you are running kubectl v1.12 or below, you will need to add the --validate=false flag to your kubectl apply.
```sh
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/cert-manager.yaml --validate=false
```