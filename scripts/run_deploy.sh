#!/usr/bin/env bash

set -e

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export PROJECT_PATH=$(dirname "$SCRIPT_PATH")

cp -R ${PROJECT_PATH}/openstack_deploy /etc
pushd ${PROJECT_PATH}/openstack-ansible
scripts/bootstrap-ansible.sh
popd

pushd ${PROJECT_PATH}/openstack-ansible/playbooks
openstack-ansible setup-hosts.yml -vvvvv
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
