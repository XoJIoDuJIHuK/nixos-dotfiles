{ config, lib, pkgs, ... }:
{
  services.printing = {     # http://localhost:631/admin
    enable = true;          # CUPS service for document frinting
    browsed.enable = false; # disable cups-browsed (security vulns in 2024 + prevents buggy auto-queues that point to /dev/null)
    drivers = with pkgs; [  # just in case of missing drivers issues
      gutenprint            # very broad support
      # hplip               # HP printers
      # brlaser             # some Brother lasers
    ];
  };
  # mDNS / .local discovery (required for most network printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;   # IPv4 .local resolution (avoids IPv6 issues)
    openFirewall = true;  # allows UDP 5353 for discovery
  };
}
