{ config, pkgs, ... }:
with pkgs;
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.huettner94 = {
    nixpkgs.config.allowUnfree = true;
    programs = {
      vscode.enable = true;
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
        };
        sessionVariables = {
          COLORTERM = "truecolor";
          TERM = "xterm-256color";
        };
        plugins = [
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource ./p10k-config;
            file = "p10k.zsh";
          }
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }

        ];
        shellAliases = {
          ssh = "ssh-ident";
          scp = "ssh-ident";
        };
        initExtra = "export GIT_SSH=ssh-ident";
      };
    };
  };
}
