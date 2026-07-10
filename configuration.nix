# ~/nixbtww/configuration.nix
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
      ./home/home-manager.nix
    ];

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Define your hostname.
  networking.hostName = "nix-btw";

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
  programs.ssh.startAgent = true;

  # Disable the firewall altogether.
  networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine.
  # Do NOT change this value unless you have manually inspected all the changes it would make.
  system.stateVersion = "26.05"; 
}
