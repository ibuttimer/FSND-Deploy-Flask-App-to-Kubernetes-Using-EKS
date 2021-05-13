### Create an EKS (Kubernetes) Cluster in the default region
```shell
$ eksctl create cluster --name simple-jwt-api
```
### Create an IAM Role
#### Get your AWS account id
```shell
$ aws sts get-caller-identity --query Account --output text
```
#### Replace <ACCOUNT_ID> in [trust.json](iam_role/trust.json) with your AWS account id

#### Create a role, 'UdacityFlaskDeployCBKubectlRole', using the [trust.json](iam_role/trust.json) trust relationship:
```shell
$ aws iam create-role --role-name UdacityFlaskDeployCBKubectlRole --assume-role-policy-document file://trust.json --output text --query 'Role.Arn'
```

#### Attach the [iam-role-policy.json](iam_role/iam-role-policy.json) policy to the 'UdacityFlaskDeployCBKubectlRole'
```shell
$ aws iam put-role-policy --role-name UdacityFlaskDeployCBKubectlRole --policy-name eks-describe --policy-document file://iam-role-policy.json
```

### Allow the new role access to the cluster
#### Get the current configmap and save it to a file
```shell
$ kubectl get -n kube-system configmap/aws-auth -o yaml > /tmp/aws-auth-org.yml
```
#### Save a copy of aws-auth-org.yml, and update it as per aws-auth-patch.yml
Remember to replace <ACCOUNT_ID> with your AWS account id.

#### Update the cluster's configmap
```shell
$ kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"
configmap/aws-auth patched
```


