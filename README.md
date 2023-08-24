# Server Configuration

Some Ansible scripts to automate setting up, installing, and updating a server to my preferences. 

## Setup

### Git Stuff

The repo makes use of git submodule, to clone:

```bash
git clone --recursive https://github.com/mirdaki/server-config.git
```

and to update from repo:

```bash
git submodule update
```

or if updating form upstream:

```bash
git submodule update --remote <path>
```

### Software

Install ansible:

```bash
sudo dnf install ansible
```

Get and setup [Bitwarden CLI](https://bitwarden.com/help/cli/#download-and-install):

```bash
export PATH="/bw:$PATH"
export BW_SESSION=$(bw unlock --raw)
```

### Files to modify

- Workstation
  - group_vars/workstations/vars.yml
- Matrix
	- [matrix/inventory/hosts](./matrix/inventory/hosts)
	- inventory/host_vars/matrix.*/vars.yml

### Run

Setup workstation (may need to manually run to get just):

```bash
just update
just workstations
```

To toggle encryption:

```bash
just decrypt
just encrypt
```

### Old, to be updated
- Setup Ubuntu 18.04
	- `ansible-playbook -l coruscant -i initial-config/hosts -u root initial-config/setup_ubuntu1804/playbook.yml`
		- May need to change user on subsequent runs
	- Reboot (Must be separate command, because root connections no longer work)
		- `ansible coruscant -i initial-config/hosts -u matthew -m reboot -b`
- Install Docker Ubuntu 18.04
	- `ansible-playbook -l coruscant -i initial-config/hosts -u matthew initial-config/docker_ubuntu1804/playbook.yml`
- Install Matrix
	- Initial install
		- `ansible-playbook -i matrix/inventory/hosts matrix/setup.yml --tags=setup-all --skip-tags=setup-mx-puppet-discord`
	- Start services
		- `ansible-playbook -i matrix/inventory/hosts matrix/setup.yml --tags=start`
	- Check install
		- `ansible-playbook -i matrix/inventory/hosts matrix/setup.yml --tags=self-check`
	- Add users
		- `ansible-playbook -i matrix/inventory/hosts matrix/setup.yml --extra-vars='username=<name> password=<your-password> admin=yes' --tags=register-user`
	- Uncomment Dimension and add it
	- Send invite to new users
		- `ansible-playbook -i matrix/inventory/hosts setup.yml --tags=generate-matrix-registration-token --extra-vars="one_time=yes ex_date=2021-12-31"`
		- Send the user that token and direct them to https://matrix.DOMAIN/matrix-registration/register

### Problems

- If a container fails to run properly on `start`, try restarting docker `sudo systemctl restart docker` and running the command again


## Resources

- [Matrix](https://github.com/spantaleev/matrix-docker-ansible-deploy)
- Vault
  - [Setup](https://blog.ktz.me/secret-management-with-docker-compose-and-ansible/)
  - [Bitwarden integration](https://theorangeone.net/posts/ansible-vault-bitwarden/)
