{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # --time shows a clock, --remember remembers your last user, --cmd launches your desktop environment
        # Replace 'Hyprland' at the end with your specific DM/WM command if you use something else (e.g., sway, startwfx)
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # High-performance console tuning for greetd to prevent race conditions with your rapid boot & Nvidia drivers
  systemd.services.greetd = {
    unitConfig = {
      After = [ "rc-local.service" "systemd-user-sessions.service" "plymouth-quit-active.service" "getty@tty1.service" ];
      Conflicts = [ "getty@tty1.service" ];
    };
    serviceConfig = {
      Type = "idle";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
