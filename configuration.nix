{ config, pkgs, lib, enableNvidia ? false, hostname ? "nixos", ... }:

{
  imports = [
    ./homes/${hostname}/hardware-configuration.nix
    ./configs/sysc-greet.nix
  ] ++ lib.optional enableNvidia ./configs/nvidia.nix;

  # Bootloader (Assumes UEFI)
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "console=tty1" ];
  };


  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.blueman.enable = true;

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

  # Networking
  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall = {
      trustedInterfaces = [ "singbox-tun" ];  # it seems this is needed for sing-box to run
      checkReversePath = "loose";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Locale
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";  # 24-hour time format
      LC_MEASUREMENT = "en_GB.UTF-8";  # Celsius
    };
  };

  environment = {
    systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      bluez
      bluez-tools
    ];

    sessionVariables = {
      UV_PYTHON_PREFERENCE = "only-managed";
      # Forces GTK apps to use the portal (and thus the consistent file picker)
      GTK_USE_PORTAL = "1";

      # Hints Electron apps (Discord, VS Code, Obsidian) to use Wayland/Portal
      NIXOS_OZONE_WL = "1";
    };
  };
# Enable Sound (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users.aleh = {
    isNormalUser = true;
    description = "Aleh";
    extraGroups = [ "networkmanager" "wheel" "video" "bluetooth" "docker"];
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  users.users.aleh.shell = pkgs.zsh;

  programs.hyprland.enable = true;

  # Allow unfree packages (Drivers, Chrome, VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  time.hardwareClockInLocalTime = true;  # for windows time issue

  # fix for binary programs not being able to see nixos libraries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib # needed for factorio
    libGL
    zlib
    glib
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libXext
    libxkbcommon
    wayland
    alsa-lib
    libpulseaudio
    zenity  # This fixes the "zenity reported error"
    # WeasyPrint dependencies
    fontconfig
    pango
    cairo
    libffi
  ];

  services.netbird.enable = true;
  systemd.services.netbird.environment = {
    NB_MANAGEMENT_URL = "https://ra.internal.whitesnake.by:33073/";
    NB_ADMIN_URL = "https://ra.internal.whitesnake.by/";
  };

  services.tailscale.enable = true;  # single `sudo tailscale up` is needed afterwards

  # Do not change this value
  system.stateVersion = "25.05";

  virtualisation.docker = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "aleh" ];
    };
  };
}
