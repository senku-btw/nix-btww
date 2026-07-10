# /etc/nixos/sessions/mangowm.nix
# Enterprise-Grade MangoWM Composition & Session Registration Module

{ config, pkgs, lib, ... }:

let
  cfg = config.services.mangowm-session;

  mangoSessionStartup = pkgs.writeShellScriptBin "mangowm-session" ''
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
    export ECOSM_RENDERER=vulkan       # Force Vulkan backend if MangoWM supports it
    export ELECTRON_OZONE_PLATFORM_HINT="wayland" # Modern alternative to just OZONE_WL

    # Fix Java rendering glitches on non-reparenting Wayland window managers
    export _JAVA_AWT_WM_NONREPARENTING=1

    # --- Session Execution ---
    exec ${lib.getExe pkgs.mangowm}
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
      enable = lib.mkEnableOption "Production MangoWM session architecture";
      
      # Enterprise addition: Declarative path variable so you aren't hardcoding strings
      configPath = lib.mkOption {
        type = lib.types.path;
        default = /home/admin/dotfiles/config/mango/mangowm.conf;
        description = "Absolute path to the mutable user configuration file.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Provide core package suite dependencies
    environment.systemPackages = [
      pkgs.mangowm
      mangoSessionStartup
      mangowmDesktopSession
    ];

    # 2. XDG Desktop Portal Pipeline - Fixed for modern portal configuration schemas
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common = {
          default = [ "wlr" "gtk" ];
        };
        # Safe explicit fallback for MangoWM desktop session identification
        MangoWM = {
          default = [ "wlr" "gtk" ];
        };
      };
    };

    # 3. Hardware / Pipeline acceleration infrastructure
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 4. Out-of-Store Dotfile Symlink Mapping
    # Uses the cleanly typed configPath option instead of a hardcoded string literal
    environment.etc."mango/mangowm.conf".source = cfg.configPath;
  };
}
