{ config, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
    listenAddresses = [ "192.168.0.1:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
    allowInterfaces = [ "br-int" ];
  };
}

