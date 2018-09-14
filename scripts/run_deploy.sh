#!/usr/bin/env bash

set -e

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export PROJECT_PATH=$(dirname "$SCRIPT_PATH")

source "${SCRIPT_PATH}/functions.sh"

cp -R ${PROJECT_PATH}/openstack_deploy /etc
pushd ${PROJECT_PATH}/openstack-ansible
scripts/bootstrap-ansible.sh

if [ "$LSN_RUN_ARA" == true ]; then
    setup_ara
fi
popd

pushd ${PROJECT_PATH}/openstack-ansible/playbooks
openstack-ansible openstack-hosts-setup.yml
exit 0
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
popd

pushd ${PROJECT_PATH}/network_bootstrap
openstack-ansible bootstrap-neutron.yml
popd

pushd ${PROJECT_PATH}/openstack-ansible-ops/elk_metrics_6x
source bootstrap-embedded-ansible.sh || true
ansible-playbook site.yml ${USER_VARS} -e 'elk_package_state="latest"'
deactivate
popd
