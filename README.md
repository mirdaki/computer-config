# Server Configuration

Some Ansible scripts to automate setting up, installing, and updating a server to my preferences. 

## Setup

### Git Stuff

The repo makes use of git submodule, to clone:

```bash
git clone --recursive https://github.com/mirdaki/server-config.git
```

and to update:

```bash
git submodule update
```

### Files to modify

- Initial Config
	- TODO
- Matrix
	- [matrix/inventory/hosts](./matrix/inventory/hosts)
	- inventory/host_vars/matrix.*/vars.yml
	<!-- - [inventory/host_vars/matrix.*/vars.yml](./inventory/host_vars/matrix.*/vars.yml) -->

## TODO

- Consider using custom original config
- Find way to share hosts
- Find way to not store secrets in git

## Resources

- [Initial Config](https://github.com/do-community/ansible-playbooks)
- [Matrix](https://github.com/spantaleev/matrix-docker-ansible-deploy)