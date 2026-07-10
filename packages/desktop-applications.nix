{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pkgs.google-chrome
    pkgs.keepassxc
    pkgs.min
    pkgs.nautilus
    pkgs.obsidian
  ];
}
