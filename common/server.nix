{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
    #settings.PermitRootLogin = "yes";
  };

  users.users."huettner94".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPUsGGyHPV3taUC7fc92vKKJmBLL8tcMAfN6NZkQf3g"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPr5zx/qNbUHWCRtYHge+6ZjrK2kb9REDzGdOpwgb0lN"
  ];

  boot.initrd.kernelModules = [
    "dm-raid" # lvmraid
    "dm-integrity" # lvmraid integrity
    "dm-snapshot" # lvm snapshots
  ];

  # Lets save power, not sure on the performance impact
  powerManagement.cpuFreqGovernor = "powersave";

  environment.systemPackages = with pkgs; [
    xorg.xauth # for x forwarding
    hdparm # To manage hdd configs
  ];

  # Increase max inotifies as limit is quite low otherwise.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_user_watches" = 16384;
  };

  # hdparm -S 120 : lets hdds spin down after 10 minutes
  # med_power_with_dipm : lets the sata link to the disks power down
  # power/control : lets the kernel do power management on pci devices (next line for sata ports and the next for their devices)
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="ata_port", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi", ATTR{power/control}="auto"
  '';

}
