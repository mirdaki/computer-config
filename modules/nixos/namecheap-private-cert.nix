# DNS provider list and settings https://go-acme.github.io/lego/dns/
# Important! The IP address associated with the private domain is the tailscale IP address of the server you're connecting to

# Expects the acme module to have already run

# TODO: See if I can pull out the "extra_records" extra DNS rules per service, like authelia OIDC

{
  self,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.namecheap-private-cert;
in
{
  options = {
    namecheap-private-cert.enable = lib.mkEnableOption "enable namecheap-private-cert module";

    namecheap-private-cert.domainName = lib.mkOption { type = lib.types.str; };
    namecheap-private-cert.credentialsFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      certs.${cfg.domainName} = {
        domain = "*.${cfg.domainName}";
        dnsProvider = "namecheap";
        # Ran into issues with the check never succeeding, even though the records were created
        dnsPropagationCheck = false;
        credentialsFile = cfg.credentialsFile;
      };
    };

    # So nginx can access the credentialsFile
    users.users.nginx.extraGroups = [ "acme" ];

# TODO: Separate out for testing sake
    # services = {
    #   nginx = {
    #     enable = true;
    #     virtualHosts."test.internal.codecaptured.com" = {
    #       # enableAuthelia = true;
    #       forceSSL = true;
    #       useACMEHost = cfg.domainName;
    #       locations."/" = {
    #         proxyPass = "http://127.0.0.1:8123";
    #       };
    #     };
    #   };
    # };
  };
}
