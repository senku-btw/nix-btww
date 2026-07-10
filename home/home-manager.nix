{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # System-wide Home Manager settings
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.admin = { pkgs, ... }: {
    
    # Import your structural package modules here
    imports = [
      ../packages/environment-packages.nix
    ];

    # User Profile Definition
    home.username = "admin";
    home.homeDirectory = "/home/admin";

    # Dotfiles & File management
    home.file.".config/mango/config.conf".source = /home/admin/dotfiles/config/mango/config.conf;

    # Programs & Services
    programs.git = {
      enable = true;
    };

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "26.05"; 
  };
}
