# ~/nixbtww/configuration.nix
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      # Hardware & Boot
      ./machines/nix-btw/hardware-configuration.nix
      ./boot/initrd.nix
      ./drivers/nvidia-graphics.nix
      
      # Environment & Display
      ./services/greetd.nix
      ./sessions/mangowm.nix
      
      # Users & Home Management
      ./home/home-manager.nix
      ./users/nyx/user-profile.nix
    ];

  # Swap space configuration
  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Networking
  networking.hostName = "prometheus";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Localization
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Input & XServer
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
     };
  };

  # Remote Access
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Core system state version. Do not alter without verifying breaking changes.
  system.stateVersion = "26.05"; 
}
