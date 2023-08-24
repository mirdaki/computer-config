default:
  just --list

workstations:
  ansible-playbook playbook.yml -i hosts --limit workstations --ask-become-pass --tags=setup-all

encrypt:
  ansible-vault encrypt group_vars/workstations/vault.yml

decrypt:
  ansible-vault decrypt group_vars/workstations/vault.yml

update:
  ansible-galaxy collection install -r requirements.yml --force
