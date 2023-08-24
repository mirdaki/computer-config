#!/bin/bash
# pulls in ansible vault password from bitwarden
# 
# From theorangeone
# https://theorangeone.net/posts/ansible-vault-bitwarden/

set -e

bw get password "20d5c00a-ba04-4372-ac47-b064003d7d13"
