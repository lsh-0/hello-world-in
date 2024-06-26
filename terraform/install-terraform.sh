#!/bin/bash
# installs 'tfenv', a Terraform version manager: https://github.com/tfutils/tfenv
# this allows us to migrate projects between versions of Terraform.

set -e

if [ ! -d .tfenv ]; then
    wget https://github.com/tfutils/tfenv/archive/refs/tags/v3.0.0.tar.gz \
        --output-document=tfenv.tar.gz \
        --quiet
    tar -xzf tfenv.tar.gz
    mv tfenv-3.0.0 .tfenv
    rm tfenv.tar.gz
fi

#.tfenv/bin/tfenv uninstall 0.11.15 || true
#.tfenv/bin/tfenv uninstall 0.13.7 || true
#.tfenv/bin/tfenv uninstall 0.14.11 || true
#.tfenv/bin/tfenv uninstall 0.15.5 || true
#.tfenv/bin/tfenv uninstall 1.0.11 || true

# see: https://releases.hashicorp.com/terraform/
# note: values should match `projects/elife.yaml` under 'defaults.terraform.version'.
.tfenv/bin/tfenv install 1.8.4

# activate the default version.
# "this is used when not overridden by '.terraform-version' or 'TFENV_TERRAFORM_VERSION'"
# - https://github.com/tfutils/tfenv#tfenv-install-version
.tfenv/bin/tfenv use 1.8.4
