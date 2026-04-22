{
  # Power Management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "auto";
  };

  # UPower - Power management daemon for battery monitoring
  services.upower = {
    enable = true;
  };

  # Power profiles daemon - Power profile switching
  services.power-profiles-daemon = {
    enable = true;
  };
}
