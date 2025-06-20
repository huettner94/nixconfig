{ config, pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Generally we use network manager, but in some cases not
  networking.networkmanager.enable = lib.mkDefault true;

  time.timeZone = "Europe/Berlin";

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.huettner94 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # No sudo password prompt
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    ethtool
    tcpdump
    conntrack-tools
  ];

}
