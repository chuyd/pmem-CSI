#!/bin/bash

set -o errexit
set -o pipefail
set -x

CLUSTER=${CLUSTER:-clear-kvm}
REPO_DIRECTORY="${REPO_DIRECTORY:-$(dirname $(dirname $(readlink -f $0)))}"
WORK_DIRECTORY="${WORK_DIRECTORY:-${REPO_DIRECTORY}/_work/${CLUSTER}}"
KUBECTL="${KUBECTL:-${WORK_DIRECTORY}/ssh-clear-kvm kubectl}"
KUBERNETES_VERSION="$(${KUBECTL} version --short | grep 'Server Version' | \
	sed -e 's/.*: v\([0-9]*\)\.\([0-9]*\)\..*/\1.\2/')"
TEST_DEVICEMODE=${TEST_DEVICEMODE:-lvm}
DEPLOYMENT_DIRECTORY="${REPO_DIRECTORY}/deploy/kubernetes-$KUBERNETES_VERSION"
REGISTRY_IP=${REGISTRY_IP:-$(awk '{NF=NF-1;gsub(".*@","");print $NF}' ${WORK_DIRECTORY}/ssh-clear-kvm)}
TEMPLATE_IP=${TEMPLATE_IP:-$(grep "image:.*5000" ${DEPLOYMENT_DIRECTORY}/*  | awk '{gsub (":5000.*","");print $NF; exit}')}
DEPLOYMENT_FILES=(
        pmem-csi-${TEST_DEVICEMODE}-testing.yaml
        pmem-storageclass-ext4.yaml
        pmem-storageclass-xfs.yaml
        pmem-storageclass-cache.yaml
)

for deployment_file in ${DEPLOYMENT_FILES[@]}; do
	sed "s|${TEMPLATE_IP}|${REGISTRY_IP}|g" ${DEPLOYMENT_DIRECTORY}/${deployment_file} | ${KUBECTL} apply -f -
done
