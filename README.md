# k8s-bootstrapping
An experiment to bootstrap a k8s cluster from another one with just the k8s api

Terraform apply bootstrap-cluster

```
cd bootstrap-cluster
terraform apply
```

Create the role:

```
kubectl create -f roles/sub-cluster1.yml
kubectl create -f roles/sub-cluster1-rolebinding.yml
```

Once role is create, create a serviceaccount for auth:

```
kubectl create serviceaccount sub-cluster1
```

And get the secret:

```
kubectl get serviceaccounts sub-cluster1 -o yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2016-08-14T13:38:14Z
  name: sub-cluster1
  namespace: default
  resourceVersion: "67"
  selfLink: /api/v1/namespaces/default/serviceaccounts/sub-cluster1
  uid: 59996716-6224-11e6-be1b-0adb7d8b0aff
secrets:
- name: sub-cluster1-token-m3hto
```

Use this secret to get the token:

```
kubectl get secret sub-cluster1-token-m3hto -o yaml
apiVersion: v1
data:
  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQxRENDQXJ5Z0F3SUJBZ0lVUEtub1AvOEsrOWQ5WVlURnM2VWYrRTc1YjlFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2NERUxNQWtHQTFVRUJoTUNUa3d4RmpBVUJnTlZCQWdURFU1dmIzSmtJRWh2Ykd4aGJtUXhFakFRQmdOVgpCQWNUQ1VGdGMzUmxjbVJoYlRFVE1CRUdBMVVFQ2hNS1MzVmlaWEp1WlhSbGN6RUxNQWtHQTFVRUN4TUNRMEV4CkV6QVJCZ05WQkFNVENrdDFZbVZ5Ym1WMFpYTXdIaGNOTVRZd09ERTBNVE14TlRBd1doY05NakV3T0RFek1UTXgKTlRBd1dqQndNUXN3Q1FZRFZRUUdFd0pPVERFV01CUUdBMVVFQ0JNTlRtOXZjbVFnU0c5c2JHRnVaREVTTUJBRwpBMVVFQnhNSlFXMXpkR1Z5WkdGdE1STXdFUVlEVlFRS0V3cExkV0psY201bGRHVnpNUXN3Q1FZRFZRUUxFd0pEClFURVRNQkVHQTFVRUF4TUtTM1ZpWlhKdVpYUmxjekNDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0MKQVFvQ2dnRUJBTkVGelpSdVlnVzNCaVowQ3RwYTAvMnFnR3R2ZWxXbW0vY1AvMGRkTEdRcWpTWU4vNEVPVTAzTgp0WGwzWlZVTEhjOEI1SnZCTnA2SkdvWjJ1bzJUbDFROGFXZ21iOFBsaVdBY0YxcGV3aUE2UU9aOGR3T2hSUkJXCnNLQ00vdC9oYWJIczlBVmJBUTdxZFJWR1cvWGErNVZIbW05T0c3TkorTkVoMTE4cWhOVE45ekxDWGNvUmtEVDIKbUgxZHNxZHFzT0JIbGl4eGltMEcyWXpPODJqRGJ3a0N6d3IwM0dCV1JXTGdPNmYvazV5WkYwS1lBQTM4ZHloYgpXNWYydUV1VHJCai9JQjNTOUsxQjREZUxIV3NOMTRVWTRoU3B0S2dHV2tVUFF3c0hsVmRtODgvZUdFY0Vjb2NTCklOQ3poSElKb2FTZW5UcC9yMlFDNEFxVjNXK0tsNTBDQXdFQUFhTm1NR1F3RGdZRFZSMFBBUUgvQkFRREFnRUcKTUJJR0ExVWRFd0VCL3dRSU1BWUJBZjhDQVFJd0hRWURWUjBPQkJZRUZOeEltM2ExSWxXc2F1N0J1R3NCbWJnNgpLVFc2TUI4R0ExVWRJd1FZTUJhQUZOeEltM2ExSWxXc2F1N0J1R3NCbWJnNktUVzZNQTBHQ1NxR1NJYjNEUUVCCkN3VUFBNElCQVFETlhIbTVLU2NaVFV5NTNhQzFxSS9xclBhMGxydFN1cWV4Ky9mblpnby9HRXdWc0MwR0kwN20Kc1daVlJ3YUJNT3N4MjlYcjQ2MUJ0MHE4USs0MnAzT3NrMUZJMXRZOVFsbVBSVzMybm9rK01JSXp0aW1venNuZgo5TVRmNVBpLzFPSGMyQVIwdWJWUkdBcHpPclVRNXRPTm9nMmtCcU03U290d21lYkI5QnpNeWtxYXRMbldxeVRoCjU4QlgrWXJva0lHRkJhL0Vja0k0OTZ2UXZOQ0ErRHZFUG9QRHFtTldPVDJWeForRFZGUlNkWnZCK3ZlSmdBcysKZkNva2t3K2hHUmZ0ODFucVBzbkI0MUtEM0dlM0E4ZWg2dWV4cnJUQXJ6Zm5lQXVZeEJmRGw2TG1vNXZvNmJpbApIMS9UR1Z1OTE5TytHY1pCR3RXMXVSdTh2UElQU0NueQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  namespace: ZGVmYXVsdA==
  token: ZXlKaGJHY2lPaUpTVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKcmRXSmxjbTVsZEdWekwzTmxjblpwWTJWaFkyTnZkVzUwSWl3aWEzVmlaWEp1WlhSbGN5NXBieTl6WlhKMmFXTmxZV05qYjNWdWRDOXVZVzFsYzNCaFkyVWlPaUprWldaaGRXeDBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5elpXTnlaWFF1Ym1GdFpTSTZJbk4xWWkxamJIVnpkR1Z5TVMxMGIydGxiaTF0TTJoMGJ5SXNJbXQxWW1WeWJtVjBaWE11YVc4dmMyVnlkbWxqWldGalkyOTFiblF2YzJWeWRtbGpaUzFoWTJOdmRXNTBMbTVoYldVaU9pSnpkV0l0WTJ4MWMzUmxjakVpTENKcmRXSmxjbTVsZEdWekxtbHZMM05sY25acFkyVmhZMk52ZFc1MEwzTmxjblpwWTJVdFlXTmpiM1Z1ZEM1MWFXUWlPaUkxT1RrNU5qY3hOaTAyTWpJMExURXhaVFl0WW1VeFlpMHdZV1JpTjJRNFlqQmhabVlpTENKemRXSWlPaUp6ZVhOMFpXMDZjMlZ5ZG1salpXRmpZMjkxYm5RNlpHVm1ZWFZzZERwemRXSXRZMngxYzNSbGNqRWlmUS5XSGJXd2pWYzlYcnp4LVJya1VLRUd6bHp2eURMUk9DclFHWW5hdlJtamJPbWlmalNsQ1JkVmhEME9yVld3eVNnMXYtUmtoWnpESHNqeFp2b0NJck9leGt6dGRuR0hlRVVVTDZHbG9uTzBkU19UcUk4VnZLeHd3OU1kRWI3YzRGS1hmZTlmenJDaUNnVzlMX2hCUVpUN0lkRDMwaUs4bmlfYzZHWERXRTFWRktPbVFUOWJkay1VVXBXMnAtQUVPTEwwcF93Zi1iM0xQYmN3WjVEb1c5QlpScWZfOTFtWXJKVldlUkJzNVRkbWtJY0JNQ1dNLVNjV0hrRk1QV0ZYU1UxN1VPQjY2TDhVT3RzSlc1RlphWlZscmxTeEo5OUxKdkFMb3EwX0JvbGphSTNGLXVXUlgzWS1UbkhhdEF3NExzMXg5ajAzYnZWcW9GOEtacjBpcjB1Z3c=
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: sub-cluster1
    kubernetes.io/service-account.uid: 59996716-6224-11e6-be1b-0adb7d8b0aff
  creationTimestamp: 2016-08-14T13:38:14Z
  name: sub-cluster1-token-m3hto
  namespace: default
  resourceVersion: "66"
  selfLink: /api/v1/namespaces/default/secrets/sub-cluster1-token-m3hto
  uid: 599aece5-6224-11e6-be1b-0adb7d8b0aff
type: kubernetes.io/service-account-token
```

Now decode the token:

```
kubectl get secret sub-cluster1-token-m3hto -o go-template='{{index .data "token"}}' | base64 -D

eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InN1Yi1jbHVzdGVyMS10b2tlbi1tM2h0byIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJzdWItY2x1c3RlcjEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1OTk5NjcxNi02MjI0LTExZTYtYmUxYi0wYWRiN2Q4YjBhZmYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpzdWItY2x1c3RlcjEifQ.WHbWwjVc9Xrzx-RrkUKEGzlzvyDLROCrQGYnavRmjbOmifjSlCRdVhD0OrVWwySg1v-RkhZzDHsjxZvoCIrOexkztdnGHeEUUL6GlonO0dS_TqI8VvKxww9MdEb7c4FKXfe9fzrCiCgW9L_hBQZT7IdD30iK8ni_c6GXDWE1VFKOmQT9bdk-UUpW2p-AEOLL0p_wf-b3LPbcwZ5DoW9BZRqf_91mYrJVWeRBs5TdmkIcBMCWM-ScWHkFMPWFXSU17UOB66L8UOtsJW5FZaZVlrlSxJ99LJvALoq0_BoljaI3F-uWRX3Y-TnHatAw4Ls1x9j03bvVqoF8KZr0ir0ugw
```

Create a namespace for our sub-cluster:

```
kubectl create namespace sub-cluster1
```

And create all my secrets for my sub-cluster (create files from https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md or from multi-tenancy repo):

```
kubectl --namespace=sub-cluster1 create secret generic tokens --from-file=tokens.csv
kubectl --namespace=sub-cluster1 create secret generic auth --from-file=auth-policy.json
kubectl --namespace=sub-cluster1 create secret generic ca.pem --from-file=ca.pem
kubectl --namespace=sub-cluster1 create secret generic kubernetes.pem --from-file=kubernetes.pem
kubectl --namespace=sub-cluster1 create secret generic kubernetes-key.pem --from-file=kubernetes-key.pem
kubectl --namespace=sub-cluster1 create secret generic kube-serviceaccount.key --from-file=kube-serviceaccount.key
```

Confirm I can see them:

```
curl -k -v -XGET  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InN1Yi1jbHVzdGVyMS10b2tlbi1tM2h0byIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJzdWItY2x1c3RlcjEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1OTk5NjcxNi02MjI0LTExZTYtYmUxYi0wYWRiN2Q4YjBhZmYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpzdWItY2x1c3RlcjEifQ.WHbWwjVc9Xrzx-RrkUKEGzlzvyDLROCrQGYnavRmjbOmifjSlCRdVhD0OrVWwySg1v-RkhZzDHsjxZvoCIrOexkztdnGHeEUUL6GlonO0dS_TqI8VvKxww9MdEb7c4FKXfe9fzrCiCgW9L_hBQZT7IdD30iK8ni_c6GXDWE1VFKOmQT9bdk-UUpW2p-AEOLL0p_wf-b3LPbcwZ5DoW9BZRqf_91mYrJVWeRBs5TdmkIcBMCWM-ScWHkFMPWFXSU17UOB66L8UOtsJW5FZaZVlrlSxJ99LJvALoq0_BoljaI3F-uWRX3Y-TnHatAw4Ls1x9j03bvVqoF8KZr0ir0ugw" -H "Accept: application/json, */*" https://52.209.146.137:6443/api/v1/namespaces/sub-cluster1/secrets/
```

From the output of the terraform above, I know my master IP is https://52.209.146.137:6443

```
terraform apply
var.clustername
  Enter a value: sub-cluster1

var.host_account_token
  Enter a value: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InN1Yi1jbHVzdGVyMS10b2tlbi1tM2h0byIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJzdWItY2x1c3RlcjEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1OTk5NjcxNi02MjI0LTExZTYtYmUxYi0wYWRiN2Q4YjBhZmYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpzdWItY2x1c3RlcjEifQ.WHbWwjVc9Xrzx-RrkUKEGzlzvyDLROCrQGYnavRmjbOmifjSlCRdVhD0OrVWwySg1v-RkhZzDHsjxZvoCIrOexkztdnGHeEUUL6GlonO0dS_TqI8VvKxww9MdEb7c4FKXfe9fzrCiCgW9L_hBQZT7IdD30iK8ni_c6GXDWE1VFKOmQT9bdk-UUpW2p-AEOLL0p_wf-b3LPbcwZ5DoW9BZRqf_91mYrJVWeRBs5TdmkIcBMCWM-ScWHkFMPWFXSU17UOB66L8UOtsJW5FZaZVlrlSxJ99LJvALoq0_BoljaI3F-uWRX3Y-TnHatAw4Ls1x9j03bvVqoF8KZr0ir0ugw

var.host_cluster_name
  Enter a value: https://52.209.146.137:6443

##
lots of stuff going on here
##


Apply complete! Resources: 5 added, 2 changed, 5 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

  addresses = Master IP addresses are 52.48.95.145 and worker IP addresses are 52.210.58.75
```

Confirm working:

```
kubectl -s https://52.48.95.145:6443 --user admin get nodes
NAME        STATUS    AGE
10.0.1.46   Ready     17m
``` 

# Behind the scenes:

Terraform is using the variables provided to download secrets onto the master node here: https://github.com/Seth-Karlo/k8s-bootstrapping/blob/master/sub-cluster1/master.yaml.tpl#L24

# To DO:

- Make multi-master
- Add Kubelet certs
- Create a pod or job that will generate the secrets for you rather than it being a manual process
