{ ... }:

{
  imports = [
    ./acme.nix
    ./authelia-nginx.nix
    ./authelia.nix
    ./firewall.nix
    ./foundryvtt-router.nix
    ./foundryvtt.nix
    ./headscale.nix
    ./jellyfin-oidc.nix
    ./jellyfin.nix
    ./linode.nix
    ./lldap.nix
    ./miniflux-oidc.nix
    ./miniflux.nix
    ./namecheap-private-cert.nix
    ./nextcloud-oidc.nix
    ./nextcloud.nix
    ./nginx-recommended.nix
    ./ntfy.nix
    ./protonvpn-exit-node-losangeles.nix
    ./protonvpn-exit-node-miami.nix
    ./protonvpn-exit-node-seattle.nix
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
