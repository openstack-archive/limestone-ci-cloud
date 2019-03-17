#!/usr/bin/env bash

set -e

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export PROJECT_PATH=$(dirname "$SCRIPT_PATH")
export SETUP_ARA="${SETUP_ARA:-false}"

cp -RL ${PROJECT_PATH}/openstack_deploy /etc
pushd ${PROJECT_PATH}/openstack-ansible
source scripts/bootstrap-ansible.sh
popd

pushd ${PROJECT_PATH}/openstack-ansible/playbooks
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
popd

pushd ${PROJECT_PATH}/network_bootstrap
openstack-ansible bootstrap-neutron.yml
popd

pushd ${PROJECT_PATH}/elk_bootstrap
openstack-ansible bootstrap-elk-infra.yml
popd

pushd ${PROJECT_PATH}/openstack-ansible-ops/elk_metrics_6x
source bootstrap-embedded-ansible.sh || true
# Workaround until https://review.openstack.org/#/c/643758/ is merged
export ANSIBLE_STRATEGY_PLUGINS="${HOME}/ansible_venv/repositories/roles/plugins/strategy"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY},${PROJECT_PATH}/elk_bootstrap/inventory"
ansible-playbook "${PROJECT_PATH}/elk_bootstrap/install.yml" ${USER_VARS} -e 'elk_package_state="latest"'
deactivate
popd
