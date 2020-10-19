# Analysis

## AWS infrastructure
- EKS is not recommended as it is very locked to AWS platform, such role, policy, network, persistent volumes, etc. Which means you cannot use Kubernetes native tools to manage the cluster.
- KOPS could be a good solution however it will not use Terraform a lot. Which Terraform is the requirement for this challenge.
- Certmanager is not deployed due to the time constraints.
- A proper DNS name should be attached to the ELB.


## Jenkins pipelines
- Security scan is not included in the pipeline.
- Testing is not included in the pipeline.
- Jenkins admin login is hardcoded for testing convenience.
- Provision Jenkins on Kubernetes is a challenging task, which a lot of work is yet to be done, such as setting up credentials by groovy scripts, using vault along with Jenkins to secure secrets, etc.
- It could be much simpler to use Jenkins master to build however master pod has to install all the build/deploy dependencies, which is not recommended.
- Or use dedicated Jenkins platform outside of Kubernetes cluster.

## Golang application
- This is an old application which I wrote last year. I should have moved the metadata retrieval from Makefile to the source code.
