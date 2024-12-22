# Partly auto-generated using compose2nix v0.3.2-pre.

# To login to Tailscale with SSO:
# 1. You'll need to run this, have it register the node, but not do auth
# 2. Then get the node key from headscale via `headscale nodes list -o json` and use that to manually login with this URL
# https://net.codecaptured.com:443/oidc/register/nodekey:XXXXX
# 3. Then to make it useable, see these headscale instructions
# https://headscale.net/stable/ref/exit-node/#on-the-control-server

# References
# - https://lemmy.world/post/7281194
# - https://github.com/qdm12/gluetun/discussions/2201

# If there start being issues loading pages, it might be the Proton VPN DNS server has moved IPs. In that case, it might be worth it to just switch to a DOT provider gluetun supports, even though it's not as private
# See https://github.com/qdm12/gluetun-wiki/blob/main/setup/options/dns.md

# TODO: Look into making this rootless. I tried once and kept running into issues. I had done:
# - Created a system user with linger, it's own home in /var/lib, and UID and GID subranges
# - Added that user and group to the systemd services as well as create a StateDirectory under the user home
# - A bunch of "tmpfiles" that weren't being created automatically in the home directory

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.protonvpn-exit-node-seattle;
  identifier = "seattle";
  city = "Seattle";
in
{
  options = {
    protonvpn-exit-node-seattle.enable = lib.mkEnableOption "enable protonvpn-exit-node-seattle module";

    protonvpn-exit-node-seattle.wireguardPrivateKeyFile = lib.mkOption { type = lib.types.str; };
    protonvpn-exit-node-seattle.tailscaleAuthKeyFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    # Runtime
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
    };

    # Enable container name DNS for non-default Podman networks.
    # https://github.com/NixOS/nixpkgs/issues/226365
    networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

    virtualisation.oci-containers.backend = "podman";

    # Create base directory
    systemd.tmpfiles.rules = [
      "d /var/lib/protonvpn-exit-node-${identifier}/gluetun"
      "d /var/lib/protonvpn-exit-node-${identifier}/tailscale/state"
      "d /var/lib/protonvpn-exit-node-${identifier}/tailscale/var/lib"
    ];

    virtualisation.oci-containers.containers = {

      "gluetun-${identifier}" = {
        image = "ghcr.io/qdm12/gluetun:v3.39.1";
        environment = {
          "SERVER_CITIES" = city;
          "UPDATER_PERIOD" = "24h";
          "TZ" = "America/Los_Angeles";
          "VPN_SERVICE_PROVIDER" = "protonvpn";
          "VPN_TYPE" = "wireguard";
          "WIREGUARD_PRIVATE_KEY_SECRETFILE" = "WIREGUARD_PRIVATE_KEY_SECRETFILE";
          "FIREWALL_OUTBOUND_SUBNETS" = "100.64.0.0/10";
          # Using ProtonVPN DNS
          "DNS_ADDRESS" = "10.2.0.1";
        };
        volumes = [
          "/var/lib/protonvpn-exit-node-${identifier}/gluetun:/gluetun:rw"
          "${cfg.wireguardPrivateKeyFile}:/WIREGUARD_PRIVATE_KEY_SECRETFILE:ro"
        ];
        log-driver = "journald";
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun:/dev/net/tun:rwm"
          "--network-alias=gluetun-${identifier}"
          "--network=protonvpn-exit-node-${identifier}_default"
        ];
      };

      "tailscale-${identifier}" = {
        image = "ghcr.io/tailscale/tailscale:v1.76.6";
        environment = {
          "TS_AUTHKEY" = "file:/TS_AUTHKEY";
          "TS_EXTRA_ARGS" = "--login-server=https://net.codecaptured.com --advertise-exit-node";
          "TS_HOSTNAME" = "protonvpn-${identifier}";
          "TS_STATE_DIR" = "/state";
          "TS_ROUTES" = "100.64.0.0/10";
        };
        volumes = [
          "/dev/net/tun:/dev/net/tun:rw"
          "/var/lib/protonvpn-exit-node-${identifier}/tailscale/state:/state:rw"
          "/var/lib/protonvpn-exit-node-${identifier}/tailscale/var/lib:/var/lib:rw"
          "${cfg.tailscaleAuthKeyFile}:/TS_AUTHKEY:ro"
        ];
        dependsOn = [ "gluetun-${identifier}" ];
        log-driver = "journald";
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--network=container:gluetun-${identifier}"
        ];
      };
    };

    systemd.services = {
      "podman-gluetun-${identifier}" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [ "podman-network-protonvpn-exit-node-${identifier}_default.service" ];
        requires = [ "podman-network-protonvpn-exit-node-${identifier}_default.service" ];
        partOf = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
        wantedBy = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
      };

      "podman-tailscale-${identifier}" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        partOf = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
        wantedBy = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
      };

      "podman-network-protonvpn-exit-node-${identifier}_default" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f protonvpn-exit-node-${identifier}_default";
        };
        script = ''
          podman network inspect protonvpn-exit-node-${identifier}_default || podman network create protonvpn-exit-node-${identifier}_default
        '';
        partOf = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
        wantedBy = [ "podman-compose-protonvpn-exit-node-${identifier}-root.target" ];
      };
    };

    # When started, this will automatically create all resources and start
    # the containers. When stopped, this will teardown all resources.
    systemd.targets."podman-compose-protonvpn-exit-node-${identifier}-root" = {
      unitConfig = {
        Description = "Root target generated by compose2nix.";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
