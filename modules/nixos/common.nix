{ ... }:

{
  imports = [
    ./user.nix
    ./ssh.nix
    ./firewall.nix
    ./linode.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./security.nix
    ./vscode-remote-ssh.nix
  ];
}
