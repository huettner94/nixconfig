{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ppp ];

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
            iifname "ppp0" counter drop
            iifname "dgn-aftr" counter drop
          }

          chain forward {
            type filter hook forward priority filter; policy accept;
            ct state established,related accept

            # MSS Clamping towards DGN
            tcp flags syn oifname {
                    "ppp0",
                    "dgn-aftr"
            } tcp option maxseg size set rt mtu

            # Allow trusted network WAN access
            iifname {
                    "br-int",
            } oifname {
                    "enp0s31f6",
                    "ppp0",
                    "dgn-aftr",
            } counter accept

            # deny access from outside (connections are already allowed)
            iifname "enp0s31f6" counter drop
            iifname "ppp0" counter drop
            iifname "dgn-aftr" counter drop
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
      "30-dgn-vlan7" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "dgn-vl7";
        };
        vlanConfig = {
          Id = 7;
        };
      };
      "70-dgn-aftr" = {
        netdevConfig = {
          Kind = "ip6tnl";
          Name = "dgn-aftr";
        };
        tunnelConfig = {
          Mode = "ipip6";
          Remote = "2a01:41e3:ffff:cafe:face::3";
        };
      };
    };

    networks = {
      # bridge ports
      "40-enp1s0f0" = {
        matchConfig.Name = "enp1s0f0";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-enp1s0f1" = {
        matchConfig.Name = "enp1s0f1";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-enp1s0f2" = {
        matchConfig.Name = "enp1s0f2";
        networkConfig.Bridge = "br-int";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # DGN Upstream
      "40-enp1s0f3" = {
        matchConfig.Name = "enp1s0f3";
        networkConfig = {
          VLAN = "dgn-vl7";
          DHCP = "no";
        };
      };

      # fritzbox upstream
      "40-enp0s31f6" = {
        matchConfig.Name = "enp0s31f6";
        address = [ "192.168.10.10/24" ];
        gateway = [ "192.168.10.1" ];
        linkConfig.RequiredForOnline = "routable";
      };

      # internal
      "50-br-int" = {
        matchConfig.Name = "br-int";
        bridgeConfig = { };
        address = [ "192.168.0.1/24" ];
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          IPv6AcceptRA = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
          DHCPServer = "yes";
        };
        dhcpServerConfig = {
          PoolOffset = 40;
          PoolSize = 160;
          EmitDNS = "yes";
          DNS = "192.168.0.1";
          EmitRouter = "yes";
          Router = "192.168.0.1";
        };
        dhcpServerStaticLeases = [
          {
            Address = "192.168.0.31";
            MACAddress = "b4:8a:0a:ee:91:16";
          }
        ];
        ipv6SendRAConfig = {
          EmitDNS = "yes";
          DNS = "fe80::1";
        };
      };

      # DGN PPP
      "60-ppp-dgn" = {
        matchConfig = {
          Name = "ppp0";
          Type = "ppp";
        };
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = "yes";
          IPv6PrivacyExtensions = "yes";
          KeepConfiguration = "yes";
        };
        dhcpV6Config = {
          UseDelegatedPrefix = "yes";
          WithoutRA = "solicit";
        };
      };

      # DGN AFTR
      "80-dgn-aftr" = {
        matchConfig = {
          Name = "dgn-aftr";
        };
        addresses = [
          {
            Address = "192.0.0.2/29";
            Peer = "192.0.0.1";
          }
        ];
        #gateway = [ "192.0.0.1" ];
        #linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # PPPoE for DGN
  services.pppd = {
    enable = true;
    peers = {
      dgn = {
        autostart = true;
        enable = true;
        config = ''
          plugin rp-pppoe.so dgn-vl7
          
          # pppd supports multiple ways of entering credentials,
          # this is just 1 way
          name "P2004329@dgn.digital"
          password "53261N5GNVDBa3N9"

          noipdefault
          # defaultroute
          # replacedefaultroute
          hide-password
          lcp-echo-interval 20
          lcp-echo-failure 3
          connect /bin/true
          noauth
          persist
          noaccomp
          default-asyncmap

          nodetach
          persist

        '';
      };
    };
  };
}

