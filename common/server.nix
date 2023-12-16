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

}
