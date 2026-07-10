{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Desktop Environment / Window Manager tools
    bemenu  # The application launcher
    foot    # The terminal emulator
    wget
    curl
    git
    nano
    btop
    tree
    fastfetch
  ];
}
