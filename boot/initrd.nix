# /etc/nixos/boot/initrd.nix
{ config, lib, pkgs, ... }:

{
  # --- Bootloader Architecture ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Forces the UEFI framebuffer to utilize your monitor's native max resolution 
  # right at the boot menu, ensuring a pixel-perfect handoff to the LUKS screen.
  boot.loader.systemd-boot.consoleMode = "max";
  
  # Reduced to 1 second for fast handoff (Spam arrow keys to catch it if needed)
  boot.loader.timeout = 1; 

  # --- LUKS Encrypted Container Initialization ---
  boot.initrd.luks.devices."enc-pv" = {
    device = "/dev/disk/by-uuid/a4232927-3a94-4f36-aad6-caca4af1bada";
    allowDiscards = true;      
    bypassWorkqueues = true;   
  };

  # LTS Kernel for absolute stability
  boot.kernelPackages = pkgs.linuxPackages;
  
  # --- Initrd & Systemd Streamlining ---
  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-1" ];
  
  # RESTORED: Must be true so NixOS includes base input, bus, and HID drivers for your keyboard
  boot.initrd.includeDefaultModules = true; 

  # Pull in hardware-accelerated crypto modules to unlock the NVMe immediately
  boot.initrd.kernelModules = [ "aesni_intel" "cryptd" ];

  boot.initrd.availableKernelModules = [
    "nvme"          
    "xhci_pci"      
    "usbhid"        
    "usb_storage"   
    "btrfs"         
  ];

  # --- Systemd Service Optimizations ---
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;
  
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=20M
    Storage=persistent
  '';

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # --- Advanced Kernel Parameters ---
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "printk.devkmsg=off"
    "systemd.show_status=auto"
    "rd.systemd.show_status=auto"
    "systemd.log_level=err"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "acpi.log_errors=0"
    "fastboot"
    "lp=0"
    "noresume"
    "vconsole.setup=0"
    "vt.global_cursor_default=0" # Hides the flashing text cursor that triggers display refreshes
  ];

  # --- High-Performance Runtime Storage ---
  fileSystems."/" = {
    fsType = "btrfs";
    options = [ 
      "subvol=@root"     
      "noatime"          
      "discard=async"   
      "compress=zstd:1"  
    ];
  };  
}
