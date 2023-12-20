{ config, pkgs, ... }:

{
    services.openssh = {
        enable = true;
        # require public key authentication for better security
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        #settings.PermitRootLogin = "yes";
    };

    users.users."huettner94".openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPUsGGyHPV3taUC7fc92vKKJmBLL8tcMAfN6NZkQf3g"
    ];

    boot.initrd.kernelModules = [
        "dm-raid" # lvmraid
    ];

    # Lets save power, not sure on the performance impact
    powerManagement.cpuFreqGovernor = "powersave";

    # To spinn down hdds after some time
    environment.systemPackages = with pkgs; [
        hdparm
    ];
    services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"
    '';

}
