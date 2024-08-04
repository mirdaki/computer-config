{ ... }:

{
  imports = [
    ./user.nix
    ./ssh.nix
    ./firewall.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./security.nix
  ];
}
