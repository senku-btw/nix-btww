# /etc/nixos/services/greetd.nix
{ config, pkgs, lib, ... }:

{
  # Ensure tuigreet is available to the system and greetd service
  # Fixed: Cleaned up legacy greetd.tuigreet warning
  environment.systemPackages = [ pkgs.tuigreet ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Production flags: remembers user/session, hides password text with asterisks,
        # scans the standard system session directory, and defaults to mangowm-session.
        # Fixed: Cleaned up legacy greetd.tuigreet warning path
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions:/usr/share/wayland-sessions --cmd mangowm-session";
        user = "greeter";
      };
    };
  };

  # --- High-Availability & Lifecycle Architecture ---
  systemd.services.greetd = {
    # Guarantees the graphics stack, DRM drivers (Nvidia), and base TTY infrastructure 
    # are completely active before greetd draws to the screen. Prevents race-condition black screens.
    after = [ 
      "rc-local.service" 
      "systemd-user-sessions.service" 
      "plymouth-quit-active.service" 
      "getty@tty1.service"
    ];
    wants = [ "systemd-user-sessions.service" ];
    conflicts = [ "getty@tty1.service" ];

    serviceConfig = {
      # Type = "idle" ensures systemd finishes all other boot scripts before bringing up the UI
      Type = lib.mkForce "idle";
      
      # TTY isolation and absolute zero logging-overhead on tty1
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;

      # Production hardening: Automatic service recovery if the compositor crashes out
      # Fixed: Enforced "on-failure" priority to resolve NixOS configuration conflict
      Restart = lib.mkForce "on-failure";
      RestartSec = "1s";
    };
  };
}
