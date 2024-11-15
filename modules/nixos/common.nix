{ ... }:

{
  imports = [
    ./acme.nix
    ./authelia-nginx.nix
    ./authelia.nix
    ./firewall.nix
    ./foundryvtt-router.nix
    ./headscale.nix
    ./linode.nix
    ./lldap.nix
    ./nextcloud.nix
    ./nginx-recommended.nix
    ./ntfy.nix
    ./postgresql.nix
    ./security.nix
    ./ssh.nix
    ./tailscale.nix
    ./uptime-kuma.nix
    ./user.nix
    ./vscode-remote-ssh.nix
  ];
}
