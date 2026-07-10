# ~/nix-btww/sessions/mangowm.nix
# Enterprise-Grade MangoWM Composition & Session Registration Module

{ config, pkgs, lib, ... }:

let
  cfg = config.services.mangowm-session;

  mangoSessionStartup = pkgs.writeShellScriptBin "mangowm-session" ''
    # --- Systemd Session Bootstrapping ---
    # Import essential environment variables into the systemd user session
    # before execution to ensure user-level systemd units function correctly.
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    fi

    # --- Hardware & Renderer Pipeline Hardening (NVIDIA Focus) ---
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    
    # Anti-flicker and stability flags for modern wlroots / Wayland compositors on Team Green
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_DRM_NO_ATOMIC=0 # Enforce modern atomic modesetting pipeline

    # --- Environment Hardening & Sanitization ---
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=MangoWM
    export XDG_SESSION_DESKTOP=MangoWM

    # Native Wayland routing for main enterprise UI toolkits
    export NIXOS_OZONE_WL="1"
    export MOZ_ENABLE_WAYLAND="1"
    export QT_QPA_PLATFORM="wayland;xcb"
    export SDL_VIDEODRIVER="wayland"
    export CLUTTER_BACKEND="wayland"
    
    # Modern Toolkit Tweaks for Nvidia Stability
    export ECOSM_RENDERER=vulkan       
    export ELECTRON_OZONE_PLATFORM_HINT="wayland"

    # Fix Java rendering glitches on non-reparenting Wayland window managers
    export _JAVA_AWT_WM_NONREPARENTING=1

    # --- Session Execution via Systemd Graphical Target ---
    # Redirects stdout/stderr to journalctl via systemd-cat for structured logging
    exec systemd-cat --identifier=mangowm ${lib.getExe cfg.package}
  '';

  mangowmDesktopSession = pkgs.writeTextDir "share/wayland-sessions/mangowm.desktop" ''
    [Desktop Entry]
    Name=MangoWM
    Comment=Production-Grade High Performance Tile/Grid Window Manager
    Exec=${lib.getExe mangoSessionStartup}
    Type=Application
    DesktopNames=MangoWM
  '';
in
{
  options = {
    services.mangowm-session = {
      enable = lib.mkEnableOption "Production MangoWM session architecture" // {
        # Setting default to true makes the module self-activating upon import
        default = true;
      };
      
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.mangowm;
        description = "The MangoWM package or derivation to deploy.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Provide system-wide session registration so Greetd/GDM can see it at boot
    environment.systemPackages = [
      cfg.package
      mangoSessionStartup
      mangowmDesktopSession
    ];

    # 2. XDG Desktop Portal Pipeline - Explicitly hardened for enterprise integration
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ 
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "wlr" "gtk" ];
        };
        MangoWM = {
          default = [ "wlr" "gtk" ];
        };
      };
    };

    # 3. Hardware / Pipeline acceleration infrastructure
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiNvidia
        nvidia-vaapi-driver
      ];
    };

    # 4. Core dependencies for enterprise workstation plumbing
    security.polkit.enable = true;
    services.dbus.enable = true;
  };
}
