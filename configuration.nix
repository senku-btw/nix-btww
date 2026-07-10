# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./boot/initrd.nix
      ./drivers/nvidia-graphics.nix
      ./services/greetd.nix
      ./sessions/mangowm.nix
    ];

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  networking.hostName = "nix-btw"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "UTC";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = "/etc/secrets/admin-password";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Disable the firewall altogether.
  networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine.
  # Do NOT change this value unless you have manually inspected all the changes it would make.
  system.stateVersion = "26.05"; 
}
