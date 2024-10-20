# Computer Config

## NixOS Configuration

To update the computer, run the below with the right profile (`#alderaan` below):

```bash
sudo nixos-rebuild switch --flake ~/computer-config#alderaan
```

### First Time Setup

Note: I ran into issues (where to put the sops secret, clone the config too, the default ssh blocking root) having just a root user. There is a dependency problem since this config sets up the user and their password. This can be solved with ad-hoc steps (get the config as root, generate a secret as root, build with the user but without ssh steps, then migrate the config to the users directory and clean up). But that's not clean. A future option might be to create a user with a default password or with an empty password to start with, then do these steps. Need to investigate further.

This may not be needed going forward, but I did need this to use experimental features (nix command and flakes) in CLI ad hoc:

```bash
nix-shell -p git 
git clone https://github.com/mirdaki/computer-config.git

nix run home-manager/master --extra-experimental-features nix-command --extra-experimental-features flakes -- init
```

If you need to create age keys for secrets, [follow these steps](https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example), but use the below commands to not need to install `age-keygen`:
```bash
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
# or to get the public key if it already exists
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

[Setting up a user password with sops-nix](https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password). Note: The value you put in the secrets file is a hash of the password from `mkpasswd`, not the password itself.

### Updating Secrets

Regular secrets
```bash
nix-shell -p sops --run "sops hosts/alderaan/secrets/secret.yaml"
```

Binary files. With separate encrypt and decrypt stages
```bash
nix-shell -p sops --run "sops -e /etc/krb5/krb5.keytab > krb5.keytab"
nix-shell -p sops --run "sops -d krb5.keytab > /tmp/krb5.keytab"
```

### Cleaning Tables

If you want to drop a table (for instances, to remove testing data)
```bash
sudo -u postgres psql
\l
DROP DATABASE <name>;
\q
```
