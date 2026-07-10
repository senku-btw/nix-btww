# ~/nix-btww/packages/environment-packages.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bemenu  # The application launcher
    foot    # The terminal emulator
  ];
}
