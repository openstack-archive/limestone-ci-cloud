#!/usr/bin/env bash

LSN_RUN_ARA="${LSN_RUN_ARA:-false}"

# The vars used to prepare the Ansible runtime venv
PIP_COMMAND="/opt/ansible-runtime/bin/pip"

# NOTE(logan): Remove once https://review.openstack.org/#/c/602461/
# has merged.
function setup_ara {
  # Install ARA and add it to the callback path provided by bootstrap-ansible.sh/openstack-ansible.rc
  # This is added *here* instead of bootstrap-ansible so it's used for CI purposes only.
  ARA_SRC_HOME="${HOME}/src/git.openstack.org/openstack/ara"
  if [[ -d "${ARA_SRC_HOME}" ]]; then
    # This installs from a git checkout
    # PIP_COMMAND and PIP_OPTS are exported by the bootstrap-ansible script.
    # PIP_OPTS contains the whole set of constraints that need to be applied.
    ${PIP_COMMAND} install --isolated ${PIP_OPTS} ${ARA_SRC_HOME} "${ANSIBLE_PACKAGE:-ansible}"
  else
    # This installs from pypi
    # PIP_COMMAND and PIP_OPTS are exported by the bootstrap-ansible script.
    # PIP_OPTS contains the whole set of constraints that need to be applied.
    ${PIP_COMMAND} install --isolated ${PIP_OPTS} ara==0.14.0 "${ANSIBLE_PACKAGE:-ansible}"
  fi
  # Dynamically retrieve the location of the ARA callback so we are able to find
  # it on both py2 and py3
  ara_location=$(/opt/ansible-runtime/bin/python -c "import os,ara; print(os.path.dirname(ara.__file__))")
  export ANSIBLE_CALLBACK_PLUGINS="/etc/ansible/roles/plugins/callback:${ara_location}/plugins/callbacks"
}
