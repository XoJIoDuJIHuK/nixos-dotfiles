{ config, pkgs, lib, self, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${self}/configs/greetd.nix"
  ];

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

   # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
  };

  # Networking
  networking = {
    hostName = "nixos"; # Must match flake.nix
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
  time.timeZone = "UTC"; # Change to your timezone (e.g., "America/New_York")

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # --- GNOME CONFIGURATION ---
  # services.xserver = {
  #   enable = true;
  #   displayManager.gdm.enable = true;
  #   desktopManager.gnome.enable = true;
  #
  #   # Configure keymap in X11
  #   xkb.layout = "us";
  # };

  # greetd configuration moved to ./configs/greetd.nix

  # Debloat GNOME (Remove default games, tour, help, etc.)
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit # We will use a better text editor if needed
    cheese  # webcam tool
    gnome-music
    gnome-terminal # We will use a shell via Home Manager
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # game
    iagno # game
    hitori # game
    atomix # game
  ]) ++ (with pkgs.gnome; [

  ]);

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

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
    extraGroups = [ "networkmanager" "wheel" "video"];
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
    stdenv.cc.cc.lib
    libGL
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
  ];

  # Do not change this value
  system.stateVersion = "25.05";
}
