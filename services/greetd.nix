# /etc/nixos/services/greetd.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.tuigreet ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Dynamically grabs the accurate NixOS XDG session paths
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd mangowm-session";
        user = "greeter";
      };
    };
  };

  # --- High-Availability & Lifecycle Architecture ---
  systemd.services.greetd = {
    after = [ 
      "rc-local.service" 
      "systemd-user-sessions.service" 
      "plymouth-quit-active.service" 
      "getty@tty1.service"
    ];
    wants = [ "systemd-user-sessions.service" ];
    conflicts = [ "getty@tty1.service" ];

    serviceConfig = {
      Type = lib.mkForce "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
      Restart = lib.mkForce "on-failure";
      RestartSec = "1s";
    };
  };
}
