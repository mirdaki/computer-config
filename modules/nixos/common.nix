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
    ./namecheap-private-cert.nix
    ./nextcloud-oidc.nix
    ./nextcloud.nix
    ./nginx-recommended.nix
    ./ntfy.nix
    ./postgresql.nix
    ./security.nix
    ./silverbullet.nix
    ./ssh.nix
    ./tailscale.nix
    ./uptime-kuma.nix
    ./user.nix
    ./vscode-remote-ssh.nix
  ];
}
