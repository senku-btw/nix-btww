# /etc/nixos/sessions/mangowm.nix
# Enterprise-Grade MangoWM Composition & Session Registration Module

{ config, pkgs, lib, ... }:

let
  mangoSessionStartup = pkgs.writeShellScriptBin "mangowm-session" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=MangoWM
    export XDG_SESSION_DESKTOP=MangoWM

    export NIXOS_OZONE_WL="1"
    export MOZ_ENABLE_WAYLAND="1"
    export QT_QPA_PLATFORM="wayland;xcb"
    export SDL_VIDEODRIVER="wayland"
    export CLUTTER_BACKEND="wayland"
    
    export _JAVA_AWT_WM_NONREPARENTING=1

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
    services.mangowm-session.enable = lib.mkEnableOption "Production MangoWM session architecture";
  };

  config = lib.mkIf config.services.mangowm-session.enable {
    environment.systemPackages = [
      pkgs.mangowm
      mangoSessionStartup
      mangowmDesktopSession
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "wlr" "gtk" ];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 4. Out-of-Store Dotfile Symlink Mapping
    environment.etc."mango/mangowm.conf".source = "/home/admin/dotfiles/config/mango/mangowm.conf";
  };
}
