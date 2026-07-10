# /etc/nixos/boot/initrd.nix
{ config, lib, pkgs, ... }:

{
  # --- Bootloader Architecture ---
  boot.loader.systemd-boot.enable = true;      # Lightweight EFI bootloader (faster than GRUB).
  boot.loader.systemd-boot.editor = false;     # Disables editing kernel params at boot for security.
  boot.loader.efi.canTouchEfiVariables = true; # Allows the installer to modify NVRAM variables to set the default boot entry.
  
  # Forces the UEFI framebuffer to utilize your monitor's native max resolution 
  boot.loader.systemd-boot.consoleMode = "max";
  
  # Reduced to 1 second for fast handoff (Spam arrow keys to catch it if needed).
  # Bypasses the standard 5-second wait time to jump straight into init.
  boot.loader.timeout = 1; 

  # --- LUKS Encrypted Container Initialization ---
  boot.initrd.luks.devices."enc-pv" = {
    device = "/dev/disk/by-uuid/a4232927-3a94-4f36-aad6-caca4af1bada";
    allowDiscards = true;    # Passes TRIM requests through LUKS to maintain native NVMe write performance.
    bypassWorkqueues = true; # Bypasses kernel crypto queues for synchronous, zero-latency inline decryption.
  };

  # LTS Kernel for absolute stability (Enterprise requirement)
  boot.kernelPackages = pkgs.linuxPackages;
  
  # --- Initrd & Systemd Streamlining ---
  boot.initrd.systemd.enable = true; # Allows for parallel device initialization and service starting.
  boot.initrd.compressor = "zstd";   # Uses Zstandard compression for the initrd image.
  boot.initrd.compressorArgs = [ "-1" ]; # Uses compression level 1 for rapid initialization.
  
  # Fixed: Corrected missing prefix option name so default dependencies pull in cleanly
  boot.initrd.includeDefaultModules = true; 

  # Keep your high-priority hardware list so it gets fast-tracked at early boot
  boot.initrd.kernelModules = [ 
    "aesni_intel"  
    "cryptd"       
    "nvme"         
    "xhci_pci"     
    "usbhid"       
    "hid_generic"  
    "evdev"        
    "btrfs"        
  ];

  # --- Systemd Service Optimizations ---
  systemd.services.NetworkManager-wait-online.enable = false; # Stops the boot process from blocking while waiting for an IP address.
  systemd.services.systemd-udev-settle.enable = false;        # Disables legacy service waiting for all hardware device processing.
  
  # Prevents hanging services from indefinitely stalling the boot/shutdown process.
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
  };

  # Limits journal size. Reading massive log files on startup can cause minor IO delays.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=20M
    Storage=persistent
  '';

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # --- Advanced Kernel Parameters ---
  boot.kernelParams = [
    "quiet"                       # Suppresses non-critical kernel messages during early boot phases.
    "loglevel=3"                  # Limits console logging to errors and critical warnings only.
    "printk.devkmsg=off"          # Disables early kernel logging to /dev/kmsg to prevent display overhead.
    "systemd.show_status=auto"    # Dynamically hides systemd status lines unless a service failure occurs.
    "rd.systemd.show_status=auto" # Enforces dynamic, error-only systemd status reporting inside the initrd.
    "systemd.log_level=err"       # Sets the systemd service manager log output strictly to errors.
    "udev.log_level=3"            # Mitigates systemd-udevd noise by suppressing non-error logs.
    "rd.udev.log_level=3"         # Suppresses udev logging inside the initial ramdisk environment.
    "acpi.log_errors=0"           # Disables non-fatal ACPI firmware compliance and parsing errors.
    "fastboot"                    # Skips unnecessary boot-time hardware and file system integrity checks.
    "lp=0"                        # Disables parallel port polling to eliminate hardware timeout delays.
    "noresume"                    # Bypasses checking block devices for a hibernation/suspend-to-disk image.
    "vconsole.setup=0"            # Defers virtual console styling initialization to optimize runtime transition.
    "vt.global_cursor_default=0"  # Prevents display refresh overhead by hiding the early flashing text cursor.
    "zswap.enabled=1"             # Intercepts memory eviction pages before hitting disk to protect Btrfs performance.
    "zswap.compressor=zstd"       # Forces zswap to use high-throughput Zstandard compression engine.
    "zswap.max_pool_percent=20"   # Caps zswap dynamic allocation to a maximum of 20% of physical system RAM.
    "video=efifb:decor=0"         # Simplifies early EFI framebuffer mappings to minimize mode-setting latency.
  ];

  # --- High-Performance Runtime Storage ---
  fileSystems."/" = {
    fsType = "btrfs";
    options = [ 
      "subvol=@root"     
      "noatime"          # Eliminates access timestamp writes, significantly reducing I/O overhead.
      "discard=async"    # Offloads SSD TRIM operations to the background to sustain high IOPS.
      "compress=zstd:1"  # Applies rapid transparent compression, trading I/O bottlenecks for CPU cycles.
    ];
  };  
}
