# /etc/nixos/sessions/mangowm.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.services.mangowm-session;

  mangoSessionStartup = pkgs.writeShellScriptBin "mangowm-session" ''
    # --- Systemd Session Bootstrapping ---
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    fi

    # --- NixOS Keyboard Location Pipeline ---
    # Fixes: xkbcommon: ERROR: Couldn't find file "symbols/us"
    export XKB_CONFIG_ROOT="${pkgs.xkeyboard_config}/share/X11/xkb"

    # --- Hardware & Renderer Pipeline Hardening (NVIDIA Focus) ---
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1

    # --- Environment Hardening & Sanitization ---
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=MangoWM
    export XDG_SESSION_DESKTOP=MangoWM

    export NIXOS_OZONE_WL="1"
    export MOZ_ENABLE_WAYLAND="1"
    export QT_QPA_PLATFORM="wayland;xcb"
    export SDL_VIDEODRIVER="wayland"
    export CLUTTER_BACKEND="wayland"
    export ECOSM_RENDERER=vulkan       
    export ELECTRON_OZONE_PLATFORM_HINT="wayland"
    export _JAVA_AWT_WM_NONREPARENTING=1

    # --- Session Execution via explicit package binary path ---
    exec systemd-cat --identifier=mangowm ${cfg.package}/bin/mango
  '';

  mangowmDesktopSession = pkgs.runCommand "mangowm-desktop-session" {
    passthru.providedSessions = [ "mangowm" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat <<EOF > $out/share/wayland-sessions/mangowm.desktop
    [Desktop Entry]
    Name=MangoWM
    Comment=Production-Grade High Performance Tile/Grid Window Manager
    Exec=${mangoSessionStartup}/bin/mangowm-session
    Type=Application
    DesktopNames=MangoWM
    EOF
  '';
in
{
  options = {
    services.mangowm-session = {
      enable = lib.mkEnableOption "Production MangoWM session architecture" // {
        default = true;
      };
      
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.mangowc; 
        description = "The MangoWM package or derivation to deploy.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      mangoSessionStartup
      mangowmDesktopSession
    ];

    services.displayManager.sessionPackages = [ mangowmDesktopSession ];

    # XDG Desktop Portal Pipeline
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [ "wlr" "gtk" ];
        MangoWM.default = [ "wlr" "gtk" ];
      };
    };

    # Hardware / Pipeline acceleration infrastructure
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    };

    security.polkit.enable = true;
    services.dbus.enable = true;
  };
}
