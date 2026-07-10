{ config, pkgs, ... }:

{
  # 1. Home Manager basics
  home.username = "admin";
  home.homeDirectory = "/home/admin";

  # 2. User Packages (Merged from your systemPackages and user packages)
  home.packages = with pkgs; [
    # System utilities you wanted
    wget
    curl
    git
    nano
    btop
    tree
    fastfetch
  ];

  # 3. Environment Variables & Session management
  home.file.".config/mango/mangowm.conf".source = /home/admin/dotfiles/config/mango/mangowm.conf;

  # 4. Programs & Services (User-level equivalents)
  programs.git = {
    enable = true;
  };

  programs.gpg = {
    enable = true;
  };

  # GPG Agent / SSH Support at the user level
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  home.stateVersion = "26.05"; 

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
