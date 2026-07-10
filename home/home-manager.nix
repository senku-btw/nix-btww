{ config, pkgs, ... }:

let
  # Dynamically fetches the Home Manager module matching your system version
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # Tells Home Manager to use the global system packages and overwrite conflicts
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # This is where your exact Home Manager configuration gets injected
  home-manager.users.admin = { pkgs, ... }: {
    
    # 1. Imports
    imports = [
      # Points to your new environment packages file
      ./packages/environment-packages.nix 
    ];

    # 2. Home Manager basics
    home.username = "admin";
    home.homeDirectory = "/home/admin";

    # 3. User Packages
    home.packages = with pkgs; [
      wget
      curl
      git
      nano
      btop
      tree
      fastfetch
    ];

    # 4. Environment Variables & Session management
    home.file.".config/mango/config.conf".source = /home/admin/dotfiles/config/mango/config.conf;

    # 5. Programs & Services
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

    # Let Home Manager install and manage itself
    programs.home-manager.enable = true;

    home.stateVersion = "26.05"; 
  };
}
