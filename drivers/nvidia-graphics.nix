# /etc/nixos/drivers/nvidia-graphics.nix
{ config, pkgs, lib, ... }:

{
  # Permit proprietary binaries (Mandatory for proprietary Nvidia drivers)
  nixpkgs.config.allowUnfree = true;

  boot = {
    # Mandate kernel-level modesetting and explicit framebuffers for Wayland stability
    kernelParams = [
      "nvidia-drm.modeset=1" 
      "nvidia-drm.fbdev=1"
    ];
    
    tmp.cleanOnBoot = lib.mkDefault true;
  };

  # Production-grade Global System Variables for Wayland & XWayland Stability
  environment.variables = {
    # Force Chromium/Electron apps (VS Code, Discord, Slack) to use native Wayland
    NIXOS_OZONE_WL = "1";
    
    # Direct GBM and GLX mapping to the Nvidia hardware pipeline
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # Fixes invisible/flickering hardware cursors on legacy Pascal (GTX 10 series) GPUs under Wayland
    WLR_NO_HARDWARE_CURSORS = "1"; 
    
    # Hardware accelerated video decode routing
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
  };

  hardware = {
    enableRedistributableFirmware = true;
    
    # Modern NixOS graphics configuration
    graphics = { 
      enable = true; 
      enable32Bit = true; # Necessary for 32-bit application compatibility (Steam/Wine/Legacy tools)
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        nvidia-vaapi-driver
        egl-wayland             # CRITICAL: Bridges OpenGL/EGL applications straight to Wayland
      ];
    };

    nvidia = {
      # Pinned to your required functional branch for your specific hardware layout
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      
      open = false; # Must remain false for Pascal architecture stability
      modesetting.enable = true;
      nvidiaSettings = true;
      
      # Enterprise Persistence Daemon: Keeps GPU warm to prevent Wayland compositor drops
      nvidiaPersistenced = true;
      
      # Natively handles systemd power management hooks safely without manual overrides
      powerManagement = {
        enable = true;
        finegrained = false; # Keep false for dedicated desktop workstations to maximize performance stability
      };
    };
  };

  # Ensures the display manager loads the correct kernel modules on startup
  services.xserver.videoDrivers = [ "nvidia" ];
}
