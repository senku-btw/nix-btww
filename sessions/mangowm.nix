# /etc/nixos/sessions/mangowm.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.services.mangowm-session;

  mangoSessionStartup = pkgs.writeShellScriptBin "mangowm-session" ''
    # --- Systemd Session Bootstrapping ---
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    fi

    # --- Hardware & Renderer Pipeline Hardening (NVIDIA Focus) ---
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_DRM_NO_ATOMIC=0 

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
    # NOTE: If the binary is named something else, change 'mangowc' to the exact name of the executable.
    exec systemd-cat --identifier=mangowm ${cfg.package}/bin/mangowc
  '';

  mangowmDesktopSession = pkgs.writeTextDir "share/wayland-sessions/mangowm.desktop" ''
    [Desktop Entry]
    Name=MangoWM
    Comment=Production-Grade High Performance Tile/Grid Window Manager
    Exec=${mangoSessionStartup}/bin/mangowm-session
    Type=Application
    DesktopNames=MangoWM
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
    # Provide system-wide session registration so Greetd can see it at boot
    environment.systemPackages = [
      cfg.package
      mangoSessionStartup
      mangowmDesktopSession
    ];

    # Explicitly register the desktop session package into the global NixOS display manager data fields
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
