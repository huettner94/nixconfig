{ config, pkgs, ... }:

{
  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;
    layout = "de";
    xkbOptions = "eurosign:e";

    desktopManager = { xterm.enable = false; };

    displayManager = { defaultSession = "none+i3"; };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ dmenu i3status i3lock i3blocks ];
    };

    displayManager.sessionCommands = ''
      xrdb "${
        pkgs.writeText "xrdb.conf" ''
          UXTerm*faceName:            MesloLGS NF
          UXTerm*vt100.translations: #override \
            Shift Ctrl <Key> C: copy-selection(CLIPBOARD) \n\
            Shift Ctrl <Key> V: insert-selection(CLIPBOARD)
        ''
      }"
    '';

  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [ lxappearance ];
}
