{ config, pkgs, ... }:

{
  imports = [ ./home.nix ./development.nix ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    chromium
    zsh
    encfs
    keepassxc
    nixfmt
    ssh-ident
  ];

  fonts.fonts = with pkgs; [ meslo-lgs-nf ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.users.huettner94 = { shell = pkgs.zsh; };

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
