{ config, lib, pkgs, ... }:

{
  users.users.nyx = {
    isNormalUser = true;
    
    # Group Access
    extraGroups = [ "wheel" "networkmanager" ]; 
    
    # Credential Management
    hashedPasswordFile = "/etc/secrets/admin-password"; 
  };
}
