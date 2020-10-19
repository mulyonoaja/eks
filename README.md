# AWS EKS demo

## Prerequisites

- Terraform >= 0.12.5
- An AWS account with sufficient permission to provision an ESK cluster
- Awscli >= 1.16.200
- Aws-iam-authenticator >= 0.4.0
- Helm >= 2.14.0
- Kubernetes-cli >= 1.15.1

## Configuration

- All varables are defined in variables.tf
- Either pre-assign values to variables in vars.tf, or assign them on the fly when running the script
- Variable 'env' accpets three values: dev, prod, and test


## Usage

Initialize the working directory containing Terraform configuration files

```
terraform init
```

Do a dry run to check the resources will be provisioned/changed.

```
terraform plan

```
- You need to supply AWS access key, AWS secret key, region, and account ID.
- Feel free to replace any variables' value defined in variables.tf file.
- You can specify the instance type by modifying the instance-type default value, however AWS has Pod budget on each type of EC2 instances. Please refer to this link: https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt. You need to make sure you node has enough budget for pods.

Deploy the resources

```
terraform apply

```

Destroy the resources

```
terraform destroy

```
## State file

'terraform.tfstate' holds the state of the resources that has been deployed. It should be carefully preserverd, please refer to https://www.terraform.io/docs/state/ for more information

## Joining worker nodes to the cluster
- Terraform scripts export two files: kubeconfig, aws_auth-configmap.yaml
- Switch to ESK cluster context

```
export KUBECONFIG=./kubeconfig
```

- Apply aws_auth-configmap.yaml

```
kubectl apply -f aws_auth-configmap.yaml
```

- Watch the status of worker nodes, until they become READY

```
kubectl get no -w
```

## Install Helm
- Apply tiller RBAC

```
kubectl apply -f tiller/rbac.yaml
```

-  Init Helm and install tiller

```
helm init
```

- Test Helm is ready to run

```
helm ls
```

## Deploy ingress controller
- Deploy Nginx ingress controller by using Helm chart

```
helm install stable/nginx-ingress --name my-nginx --set rbac.create=true
```

- Grab the Nginx Loadbalancer's external IP info

```
kubectl get svc
```

## Deploy Jenkins
- Deploy Jenkins by using Helm chart and the values.yaml from jenkins folder

```
helm install -f values.yaml --name jenkins stable/jenkins
```

Note: Currently the git source repo is set in the values.yaml file, from line 263 to 288. You can change the repo info from there, or comment out this block and add it manually from Jenkins UI. Make sure you include Jenkinsfile in your source code root folder, or you can specify the path for Jenkinsfile.

- Apply role to Jenkins service account

```
kubectl apply -f jenkins/sa.yaml
```

- Deploy jenkins ingress

```
kubectl apply -f ingress/jenkins-ingress.yaml
```

- Add Jenkins kubernetes service account from Jenkins UI

- Test if Jenkins works properly at:
```
  https://<ELB DNS>/jenkins/
```
- Jenkins pipeline is defined in Jenkinsfile, basically it performs the following tasks:
  1. Build go source code to a docker image by using ouyannz/golang-build:dev docker container
  2. Push the docker image to docker hub (or any other repository)
  3. Deploy the service by using alpine/helm:dev docker container, which contains helm to deploy the charts from the repo (./src/simplewebapp)

## Deploy simplewebapp ingress

```
kubectl apply -f ingress/webapp-ingress.yaml
```

- Test if the simplewebapp service is accessible at:
```
  https://<ELB DNS>/simplewebapp
```
## Simplewebapp source code folder

- root folder contains the go source code, Dockerfile to build 'simplewebapp' docker image, and Jenkinsfile for the pipeline definition
- build folder contains the Dockerfile to build 'golang-build' docker image
- simplewebapp folder contains the helm chart for 'simplewebapp' deployment
