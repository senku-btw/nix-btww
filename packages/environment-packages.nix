{ pkgs, ... }:

{
  home.packages = [
    pkgs.bemenu        # Dynamic menu and application launcher
    pkgs.foot          # Fast, lightweight Wayland terminal emulator
    pkgs.awww          # Animated wallpaper daemon for Wayland
    pkgs.btop          # Interactive system resource monitor
    pkgs.tree          # Directory structure visualizer
    pkgs.fastfetch     # System information display client
  ];
}
