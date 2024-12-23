# Computer Config

## NixOS Configuration

To update the computer, run the below with the right profile (`#alderaan` below):

```bash
sudo nixos-rebuild switch --flake ~/computer-config#alderaan
```

### First Time Setup

Install nixos using [these instructions](https://nixos.org/manual/nixos/stable/#sec-installation-manual). Create the main user and su to them for cloning this repo (to keep file permissions sane). Create the new host (copy config from /etx/nixos/, add to flake, etc) and configure files as needed.

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

### Creating OIDC Info

Per the [Authelia docs](https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#how-do-i-generate-a-client-identifier-or-client-secret)

```bash
# For the ID
nix-shell -p authelia --run "authelia crypto rand --length 72 --charset rfc3
986"

# For the secret
nix-shell -p authelia --run "authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986"
```

### Cleaning Tables

If you want to drop a table (for instances, to remove testing data)
```bash
sudo -u postgres psql
\l
DROP DATABASE <name>;
\q
```

### Manually Cleaning NixOS

```bash
sudo nix-collect-garbage -d
```

### Upgrading NixOS

Update the input URLs in the `flake.nix` file. Then run
```bash
nix flake update
sudo nixos-rebuild switch --flake ~/computer-config#alderaan
```
