{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ppp ];

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br-int";
      cache-size = 10000;
      domain = "int.eurador.de";

      # disable dns, as that is done by adguard.
      port = 0;

      # the default gateway and dns server
      dhcp-option = [ "3,192.168.0.1" "6,192.168.0.1" ];

      # default dhcp range
      dhcp-range = "192.168.0.40,192.168.0.200,24h";
      # APSystems ECU-B (balkonkraftwerk)
      dhcp-host = "b4:8a:0a:ee:91:16,192.168.0.31";
    };
  };

  services.adguardhome = {
    enable = true;
    host = "192.168.0.1";
    port = "3000";
  };

  services.resolved = { enable = false; };

  networking = {
    hostName = "serverle";
    useDHCP = false;
    nat.enable = false;
    firewall.enable = false;
    networkmanager.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain output {
            type filter hook output priority 100; policy accept;
          }

          chain input {
            type filter hook input priority filter; policy accept;

            ct state established,related accept
            iif lo accept

            # Allow trusted networks to access the router
            iifname {
              "br-int",
            } counter accept

            # deny access from outside (connections are already allowed)
            iifname "enp0s31f6" counter drop
          }

          chain forward {
            type filter hook forward priority filter; policy accept;
            ct state established,related accept

            # Allow trusted network WAN access
            iifname {
                    "br-int",
            } oifname {
                    "enp0s31f6",
            } counter accept

            # deny access from outside (connections are already allowed)
            iifname "enp0s31f6" counter drop
          }
        }

        table ip nat {
          chain prerouting {
            type nat hook prerouting priority filter; policy accept;
          }

          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
          }
        }
      '';
    };
    nameservers = [ "192.168.10.1" ];
  };

  systemd.network = {
    enable = true;

    netdevs = {
      "20-br-int" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-int";
        };
      };
    };

    networks = {
      # bridge ports
      "30-enp1s0f0" = {
        matchConfig.Name = "enp1s0f0";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f1" = {
        matchConfig.Name = "enp1s0f1";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f2" = {
        matchConfig.Name = "enp1s0f2";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f3" = {
        matchConfig.Name = "enp1s0f3";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # fritzbox upstream
      "30-enp0s31f6" = {
        matchConfig.Name = "enp0s31f6";
        address = [ "192.168.10.10/24" ];
        gateway = [ "192.168.10.1" ];
        linkConfig.RequiredForOnline = "routable";
      };

      # internal
      "40-br-int" = {
        matchConfig.Name = "br-int";
        bridgeConfig = { };
        address = [ "192.168.0.1/24" ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

