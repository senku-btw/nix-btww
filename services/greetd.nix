{ config, pkgs, lib, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Production flags: remembers user/session, hides password text with asterisks,
        # scans the correct Wayland session path, and defaults to mangowm-session.
        command = "${lib.getExe pkgs.tuigreet} --time --asterisks --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions --cmd mangowm-session";
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
      "display-manager.service"
    ];
    conflicts = [ "getty@tty1.service" ];
    provides = [ "display-manager.service" ];

    serviceConfig = {
      Type = lib.mkForce "idle";
      
      # TTY isolation and absolute zero logging-overhead on tty1
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;

      # Production hardening: Automatic service recovery if the compositor crashes out
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
