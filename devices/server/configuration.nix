{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disko-config.nix
    ../../common/configuration.nix
    ../../common/server.nix
  ];

  networking = {
    hostName = "serverle";
    interfaces = {
        enp0s31f6.ipv4.addresses = [{
          address = "192.168.0.14";
          prefixLength = 24;
        }];
    };
    defaultGateway4 = {
        address = "192.168.0.14";
        interface = "enp0s31f6";
    };
    nameservers = [ "192.168.0.1" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

