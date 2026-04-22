{ config, pkgs, lib, enableNvidia ? false, hostname ? "nixos", ... }:

{
  imports = [
    ./homes/${hostname}/hardware-configuration.nix
    ./modules/sysc-greet.nix
    ./modules/sing-box.nix
    ./modules/printing.nix
    ./modules/power.nix
  ] ++ lib.optional enableNvidia ./modules/nvidia.nix;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  zramSwap.enable = true;
  # Ensure /tmp isn't silently filling up your RAM
  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true;

  # Bootloader (Assumes UEFI)
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "console=tty1" ];
    kernel.sysctl = {
      "net.ipv4.ip_default_ttl" = 65;
      "net.ipv6.conf.all.hop_limit" = 65;
      "net.ipv6.conf.default.hop_limit" = 65;
    };
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

  services.udisks2.enable = true;
  services.gvfs.enable = true;

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
      allowedTCPPorts = [ 22 ];
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
      udiskie
    ];

    sessionVariables = {
      UV_PYTHON_PREFERENCE = "only-managed";
      # Forces GTK apps to use the portal (and thus the consistent file picker)
      GTK_USE_PORTAL = "1";

      # Hints Electron apps (Discord, VS Code, Obsidian) to use Wayland/Portal
      NIXOS_OZONE_WL = "1";
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
           action.id == "org.freedesktop.udisks2.encrypted-unlock-system" ||
           action.id == "org.freedesktop.udisks2.eject-media" ||
           action.id == "org.freedesktop.udisks2.power-off-drive") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Enable Sound (Pipewire)
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
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "video"
      "bluetooth"
      "docker"
      "lpadmin"  # for printing without sudo
    ];
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

  programs.appimage = {  # to be able to run appimages as regular binaries
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [ 
        pkgs.webkitgtk_4_1
      ];
    };
  };

  services.tailscale.enable = true;  # single `sudo tailscale up` is needed afterwards

  services.x2goserver.enable = true; # for nomachine server


  # Do not change this value
  system.stateVersion = "25.05";

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features.cdi = true;
      data-root = "/nix/var/lib/docker";
    };
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

  # TODO: remove
  services.open-webui = {
    enable = true;
    port = 3000;
    environment = {
      # Point it to your vLLM server
      OPENAI_API_BASE_URL = "http://127.0.0.1:8000/v1";
      OPENAI_API_KEY = "none";
      # Optional: Disable local Ollama if only using vLLM
      ENABLE_OLLAMA = "False";
    };
  };
}
