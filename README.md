# auth-cilogon

## Purpose

This container recipe allows a webapp to be reversed proxied and to be authenticated against [CILogon](https://cilogon.org). This basically follows the instructions of using [mod_auth_openidc](https://github.com/zmartzone/mod_auth_openidc) as described in this [example](https://www.cilogon.org/oidc).

## Usage

- Register your webapp at https://cilogon.org/oauth2/register, append /oidc/redirect as your callback URL. This will enable you to use federated logon with your webapp.
- Setup your [kubernetes](https://kubernetes.io/) (see [kubeadm](https://github.com/kubernetes/kubeadm) for quick installation) cluster.
- Edit the environment variables under kubernetes/ENVIRONMENT - you should enter your webapp URI and the pertinent CILogon information from above.
- Deploy this container with its Service and Deployment:

kubectl [-n mynamespace] apply -f kubernetes/auth.yaml

- Deploy the example webapp Deployment and Service:

kubectl [-n mynamespace] apply -f kubernetes/app.yaml

- Deploy the Ingress:

kubectl [-n mynamespace] apply -f kubernetes/ingress.yaml


