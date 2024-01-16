default:
  just --list

init:
  sudo dnf install ansible
  ./git-init.sh
  git submodule update --init

update:
  ansible-galaxy install -r requirements.yml --force
  git submodule update --remote matrix
  git submodule update --remote mash-playbook
  (cd mash-playbook; just roles)
  (cd matrix; just roles)

workstations:
  ansible-playbook playbook.yml -i hosts --limit workstations --ask-become-pass --tags=setup-all

servers:
  ansible-playbook playbook.yml -i hosts --limit servers --ask-pass --tags=setup-all

# Note: Because I'm storing the vars above the mash playbook, I need to pass in the var files manually. This means they don't adhear to the normal ansible precedence or scoping rules.So to ensure the correct vars are used, I need to run the playbook for each host and pass in different vars for each run.
mash_local_servers:
  (cd mash-playbook; ansible-playbook -i ../hosts setup.yml --ask-pass --ask-become-pass --tags=setup-all,start --extra-vars @../host_vars/alderaan-nextcloud-deps/vars.yml --extra-vars @../host_vars/alderaan-nextcloud-deps/vault.yml --extra-vars target=alderaan-nextcloud-deps)
  (cd mash-playbook; ansible-playbook -i ../hosts setup.yml --ask-pass --ask-become-pass --tags=setup-all,start --extra-vars @../host_vars/alderaan/vars.yml --extra-vars @../host_vars/alderaan/vault.yml --extra-vars target=alderaan)

mash_remote_servers:
  (cd mash-playbook; ansible-playbook -i ../hosts setup.yml --tags=setup-all,start --extra-vars @../host_vars/taris-authentik-deps/vars.yml --extra-vars @../host_vars/taris-authentik-deps/vault.yml --extra-vars target=taris-authentik-deps)
  (cd mash-playbook; ansible-playbook -i ../hosts setup.yml --tags=setup-all,start --extra-vars @../host_vars/taris/vars.yml --extra-vars @../host_vars/taris/vault.yml --extra-vars target=taris)

encrypt:
  ansible-vault encrypt group_vars/workstations/vault.yml
  ansible-vault encrypt group_vars/servers/vault.yml
  ansible-vault encrypt host_vars/taris/vault.yml
  ansible-vault encrypt host_vars/taris-authentik-deps/vault.yml
  ansible-vault encrypt host_vars/alderaan/vault.yml
  ansible-vault encrypt host_vars/alderaan-nextcloud-deps/vault.yml

decrypt:
  ansible-vault decrypt group_vars/workstations/vault.yml
  ansible-vault decrypt group_vars/servers/vault.yml
  ansible-vault decrypt host_vars/taris/vault.yml
  ansible-vault decrypt host_vars/taris-authentik-deps/vault.yml
  ansible-vault decrypt host_vars/alderaan/vault.yml
  ansible-vault decrypt host_vars/alderaan-nextcloud-deps/vault.yml
