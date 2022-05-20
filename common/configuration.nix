{ config, pkgs, ... }:

{
  imports = [ ./home.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.huettner94 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # No sudo password prompt
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    chromium
    git
    zsh
    encfs
    keepassxc
    nixfmt
    ssh-ident
  ];

  fonts.fonts = with pkgs; [ meslo-lgs-nf ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  services = {
    # needed for store VSCode auth token 
    gnome.gnome-keyring.enable = true;

    syncthing = {
      enable = true;
      user = "huettner94";
      dataDir = "/home/huettner94/.syncthing/data";
      configDir = "/home/huettner94/.syncthing/config";
    };
  };
}
