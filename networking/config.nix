{ config, pkgs, ... }:

{
  # 1. Core Kernel / Boot-level IPv6 Disable (Aggressive & Permanent)
  boot.kernelParams = [ "ipv6.disable=1" ];

  # 2. Sysctl Fallbacks (Ensures system-wide configuration overrides)
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;
  };

  networking = {
    # 3. Disable NetworkManager and enable wpa_supplicant
    networkmanager.enable = false;
    wireless.enable = true;

    # 4. Define your Wi-Fi network credentials
    wireless.networks = {
      "Christos iPhone 13" = {
        psk = "your_wifi_password_here"; # Replace with your actual password
      };
    };

    # 5. Completely disable automatic DHCP routing & DNS
    useDHCP = false;           # Disables DHCP globally
    dhcpcd.enable = false;     # Ensures the DHCP client daemon doesn't run at all

    # 6. Disable IPv6 in the NixOS networking module
    enableIPv6 = false;

    # 7. Set your manual DNS server exclusively
    nameservers = [ "192.168.2.1" ];

    # 8. Configure your Wi-Fi interface manually (no DHCP)
    # Note: Replace 'wlan0' with your actual wireless interface name (e.g., wlp3s0)
    interfaces.wlan0 = {
      useDHCP = false; # Explicitly prevent DHCP on this specific interface
      ipv4.addresses = [{
        address = "192.168.2.4";
        prefixLength = 24;
      }];
    };

    # 9. Set your manual default Gateway
    defaultGateway = "192.168.2.1";
  };
}
