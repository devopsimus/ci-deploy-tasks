#!/bin/sh

if [  "$CI_BUILD_REF_SLUG" = "prerelease"  ]; then
   ${K8S_NAMESPACE}=${K8S_NAMESPACE_STAGING}
fi

if [  "$CI_BUILD_REF_SLUG" = "master"  ]; then
   ${K8S_NAMESPACE}=${K8S_NAMESPACE_PROD}
fi

# check if chart already exists
#DEPLOYS="$(helm ls --all ${RELEASE_NAME} --namespace=${K8S_NAMESPACE} | grep -v NAME | awk '{print $1}' | wc -l)"
DEPLOYS="$(helm ls --all ${RELEASE_NAME} | grep -v NAME | awk '{print $1}' | wc -l)"

HELM_PATH="${HELM_PATH:-.helm}"
HELM_SET_ARGS=""
HELM_VALUES_ARGS="-f values.yaml"


usage()
{
    echo "usage: sysinfo_page [[[-s key=value ] [-n name ] [-ns namespace]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --set )            shift
                                HELM_SET_ARGS="$HELM_SET_ARGS --set $1"
                                ;;

        -n | --name )           shift
                                K8S_RELEASE_NAME=$1
                                ;;

        -ns | --namespace )     shift
                                K8S_NAMESPACE=$1
                                ;;

        -h | --help )           usage
                                exit
                                ;;

        * )                     usage
                                exit 2
    esac
    shift
done

if [ ! -d "$HELM_PATH" ]; then
   echo "chart directory does't exists"
   exit 2
fi

if [ -z "$K8S_NAMESPACE" ]; then
   echo "Project namespace not defined!"
   exit 2
fi

if [ -z "$K8S_RELEASE_NAME" ]; then
   echo "Project name not defined!"
   exit 2
fi

if [ -z "$DEPLOYS" ]; then
   echo "Deploys not defined"
   exit 2
fi

if [ -z $CI_BUILD_REF_SLUG = "prerelease"  ]; then
   ${K8S_NAMESPACE}=${K8S_NAMESPACE_STAGING}
fi

if [ -z $CI_BUILD_REF_SLUG = "master"  ]; then
   ${K8S_NAMESPACE}=${K8S_NAMESPACE_PROD}
fi

# add configmaps if defined
if [ -f "$HELM_PATH/$CI_BUILD_REF_SLUG.yaml" ]; then
   HELM_VALUES_ARGS="$HELM_VALUES_ARGS -f $CI_BUILD_REF_SLUG.yaml"
fi

# Install
if [ ${DEPLOYS} -eq 0 ]; then
   # Install helm chart
   cd $HELM_PATH
   echo "I am install helm chart"
   echo "Command: helm install --name=${K8S_RELEASE_NAME} --namespace=${K8S_NAMESPACE} $HELM_SET_ARGS $HELM_VALUES_ARGS ."
   helm version
   helm dep up
   helm install --name=${K8S_RELEASE_NAME} --namespace=${K8S_NAMESPACE} $HELM_SET_ARGS $HELM_VALUES_ARGS .

# upgrade
elif [ ${DEPLOYS} -gt 0 ]; then
   # Upgrade helm chart
   cd $HELM_PATH
   echo "I am upgrade helm chart"
   echo "Command: helm upgrade ${K8S_RELEASE_NAME} --namespace=${K8S_NAMESPACE} $HELM_SET_ARGS $HELM_VALUES_ARGS ."
   helm version
   helm dep up
   helm upgrade ${K8S_RELEASE_NAME} --namespace=${K8S_NAMESPACE} $HELM_SET_ARGS $HELM_VALUES_ARGS .
fi
