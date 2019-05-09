# This file is meant to be sourced into various scripts in this directory and provides
# some common settings.

# Cluster directory name where the deployment files will be stored
CLUSTER=clear-kvm

# The container runtime that is meant to be used inside Clear Linux.
# Possible values are "docker" and "crio".
#
# Docker is the default for two reasons:
# - survives killing the VMs while cri-o doesn't (https://github.com/kubernetes-sigs/cri-o/issues/1742#issuecomment-442384980)
# - Docker mounts /sys read/write while cri-o read-only. pmem-csi needs it in writable state.
TEST_CRI=docker

# Additional insecure registries (for example, my-registry:5000),
# separated by spaces.
TEST_INSECURE_REGISTRIES=""

# Additional Clear Linux bundles.
TEST_CLEAR_LINUX_BUNDLES="storage-utils"

# Post-install command for each virtual machine. Called with the
# current image number (0 to n-1) as parameter.
TEST_CLEAR_LINUX_POST_INSTALL=

# Called after Kubernetes has been configured and started on the master node.
TEST_CONFIGURE_POST_MASTER=

# Called after Kubernetes has been configured and started on all nodes.
TEST_CONFIGURE_POST_ALL=

# PMEM NVDIMM configuration.
#
# See https://github.com/qemu/qemu/blob/bd54b11062c4baa7d2e4efadcf71b8cfd55311fd/docs/nvdimm.txt
# for details about QEMU simulated PMEM.
TEST_MEM_SLOTS=2
TEST_NORMAL_MEM_SIZE=2048 # 2GB
TEST_PMEM_MEM_SIZE=32768 # 32GB
TEST_PMEM_SHARE=on
TEST_PMEM_LABEL_SIZE=2097152

# Kubernetes feature gates to enable/disable
# featurename=true,feature=false
TEST_FEATURE_GATES="CSINodeInfo=true,CSIDriverRegistry=true"

# DeviceMode to be used during testing.
# Allowed values: lvm, direct
# This string is used as part of deployment file name.
TEST_DEVICEMODE=lvm

# allow overriding the configuration in additional file(s)
if [ -d test/test-config.d ]; then
    for i in $(ls test/test-config.d/*.sh 2>/dev/null | sort); do
        . $i
    done
fi
