# DevOps Assignment

I used GitlabCI to complete the tasks and created a production ready CI/CD pipeline with Staging and Production clusters support

.helm directory contains all of the helm templates and charts for staging and production clusters. Also, it contains helm-deploy.sh - a small bash script which checks the releases and deploys it to the clusters.
I also added vault block, but commented it for now. If you want to add vars from the vault, you need to uncomment vault block in .helm/prerelease.yaml & .helm/master.yaml

docker directory contains refactored Dockerfile

.gitlab-ci.yml file contains CI pipeline on a Trunk based Development and a Docker Way.

There are 5 stages in pipeline:

stages:
  - build # This stage starts to build a testing image
  - code_quality # This stage tests the testing image with "bundle exec rails test" and for the vulnerabilities with trivy.
  - release # After all tests, this stage builds release image
  - deploy_stage # This stage deploys release image to the staging cluster
  - deploy_prod # This stage deploys release image to the production cluster

To run a pipeline you will need to provide vars for building an image:

$CI_DOCKER_REGISTRY - any docker image registry
$CI_DOCKER_REGISTRY_AUTH - auth config file for the registry

To deploy the images to the clusters:

$K8S_NAMESPACE_STAGING - k8s namespace
$KUBE_DEV_CONFIG - k8s config






