#!/usr/bin/env bash

set -e

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export PROJECT_PATH=$(dirname "$SCRIPT_PATH")
export INSTALL_ARA="${INSTALL_ARA:-false}"

cp -RL ${PROJECT_PATH}/openstack_deploy /etc
pushd ${PROJECT_PATH}/openstack-ansible
source scripts/bootstrap-ansible.sh
if [ "$INSTALL_ARA" == true ]; then
    setup_ara
fi
popd

pushd ${PROJECT_PATH}/openstack-ansible/playbooks
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
popd

pushd ${PROJECT_PATH}/network_bootstrap
openstack-ansible bootstrap-neutron.yml
popd
