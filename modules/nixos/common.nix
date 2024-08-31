{ ... }:

{
  imports = [
    ./acme.nix
    ./firewall.nix
    ./linode.nix
    ./lldap.nix
    ./nextcloud.nix
    ./nginx-recommended.nix
    ./postgresql.nix
    ./security.nix
    ./ssh.nix
    ./uptime-kuma.nix
    ./user.nix
    ./vscode-remote-ssh.nix
  ];
}
