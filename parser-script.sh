#!/bin/bash
set -e
# declare STRING variable
STRING="Initializing dependency parser"
# print variable on a screen
echo $STRING

if [ $# -lt 2 ]
  then
    echo "Please provide devstack label and namespace as args. ex -
    devspace list-deps <devstack_label> <namespace>"
    exit 1
fi

DEVSTACK_LABEL=$1
NAMESPACE=$2

CONFIGMAP_NAME=$(kubectl get job -n ${NAMESPACE} -l devstack_label=${DEVSTACK_LABEL} -l psvh=true -o yaml \
| yq eval '.items[0].spec.template.spec.volumes[0].configMap.name')


kubectl get configmap ${CONFIGMAP_NAME} -n pg-router -o yaml | yq eval '.data'
