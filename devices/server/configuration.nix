{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/server.nix
    ../../common/k3s.nix
  ];

  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    label = "boot";
    fsType = "vfat";
  };

  networking = {
    hostName = "serverle";
    useDHCP = false;
    bridges = {
      "br-int" = { interfaces = [ "enp4s0" "enp5s0" "enp6s0" "enp7s0" ]; };
    };
    interfaces = {
      enp0s31f6.ipv4.addresses = [{
        address = "192.168.0.14";
        prefixLength = 24;
      }];
      "br-int".ipv4.addresses = [{
        address = "192.168.0.13";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.0.1";
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

