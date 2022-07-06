#!/bin/bash
# declare STRING variable
STRING="Initializing dependency parser"
# print variable on a screen
echo $STRING

DEVSTACK_LABEL=$1

CONFIGMAP_NAME=$(kubectl get job -n pg-router -l devstack_label=${DEVSTACK_LABEL} -l psvh=true -o yaml \
| yq eval '.items[0].spec.template.spec.volumes[0].configMap.name')


kubectl get configmap ${CONFIGMAP_NAME} -n pg-router -o yaml | yq eval '.data'
