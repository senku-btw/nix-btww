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

  # Changed from 'admin' to 'nyx'
  home-manager.users.nyx = { pkgs, ... }: {
    
    imports = [
      ../packages/environment-packages.nix
      ../packages/desktop-applications.nix
    ];

    # User Profile Definition
    home.username = "nyx";
    home.homeDirectory = "/home/nyx";

    home.file.".config/mango/config.conf".source = ../config/mango/config.conf;

    # Programs & Services
    programs.git.enable = true;
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "26.05"; 
  };
}
