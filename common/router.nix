{ config, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
    #"net.ipv6.conf.mypubinterface.accept_ra" = 1;
    #"net.ipv6.conf.mypubinterface.autoconf" = 1;
  };
}
