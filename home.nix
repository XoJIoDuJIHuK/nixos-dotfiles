{ config, pkgs, username, inputs, self, caelestia-shell, ... }:
let
  dotfilesDir = "/home/${username}/.dotfiles";
in {
  imports = [
    caelestia-shell.homeManagerModules.default
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    firefox
    brave
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

    git
    neovim
    htop
    btop
    fastfetch
    kitty
    foot
    keepassxc
    syncthing
    gcc # for nvim

    hyprland
    hypridle
    hyprlock
    hyprpaper
    hyprshade

    rofi
    waybar
    wlogout
    waypaper

    sing-box
    zsh
    fzf # for nvim
    ripgrep # for nvim
    jq  # for nvim
    eza  # modern ls replacement
    zoxide  # smart cd
    wlogout  # for logging out screen
    killall  # for waybar
    cliphist # speaks for itself
    wl-clipboard
    python3  # for waybar scripts
    wget # for mason
    unzip
    brightnessctl
    hyprpicker  # color picker
    pulseaudio
    grimblast # for screenshots
    # dunst # notifications - replaced by caelestia-shell
    numbat # tui calculator
    qbittorrent
    uv
    tmux
    lazydocker
    lazygit
    lazysql
    telegram-desktop
    discord
    vesktop # discord community wrapper for noise suppression support
    yazi
    claude-code
    wpsoffice
    thunderbird

    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    fira-sans
    nerd-fonts.iosevka
    nerd-fonts.hack
    font-awesome
    corefonts # fonts for wpsoffice

    docker
    docker-compose
  ];

  # services.dunst.enable = true; # replaced by caelestia-shell

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };



  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # creates cascade of symlinks. to check if everything works fine, use `realpath` on a symlink
  xdg.configFile = {
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/starship.toml";
    "foot".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/foot";
    "kitty".source         = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/kitty";
    "btop".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/btop";
    "hypr".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/hypr";
    "nvim".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/nvim";
    "rofi".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/rofi";
    "waybar".source        = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/waybar";
    "waypaper".source      = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/waypaper";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # Replaces: source <(fzf --zsh)
  };

  # 4. Configure Direnv (cleaner than the OMZ plugin)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Optional: Configure Git
  programs.git = {
    enable = true;
    settings.user = {
      name = "Aleh Tachyla";
      email = "tochilo.oleg@yandex.by";
    };
  };


  programs.zsh = {
    enable = true;
    enableCompletion = true; # Auto-compiles completion dumps (performance boost)

    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      append = true;      # setopt appendhistory
      share = false;      # Equivalent to disabling share_history if you want strictly "append" behavior
    };

    oh-my-zsh = {
      enable = true;

      plugins = [
        "colorize"
        "copybuffer"
        "copyfile"
        "dotenv"
        "dirhistory"
        "docker"
        "docker-compose"
        "git"
        "pip"
        "ssh"
        "ssh-agent"
        "sudo"
        "ufw"
        "vi-mode"
      ];
    };

    # 1. High-level options for the most common plugins
    # Home Manager handles the installation and sourcing automatically.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      l = "ls -lah";
      v = "nvim";
      update = "sudo nixos-rebuild switch --flake /home/aleh/.dotfiles";
      lg = "lazygit";
      ld = "lazydocker";
    };

    # Instead of 'source /path/to/plugin' in .zshrc, you define them here.
    plugins = [
    ];

    initContent = ''
      export EDITOR=nvim
    '';
  };

  programs.tmux = {
    enable = true;
    # Using 'pkgs.tmuxPlugins' allows Nix to handle versioning and installation
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          # Resurrect Settings
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'

          # Explicitly define the save directory
          set -g @resurrect-dir '~/.tmux/resurrect'

          # Hook to ensure the directory exists when tmux starts
          # This fixes the issue where saving fails on a fresh install
          run-shell 'mkdir -p ~/.tmux/resurrect'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
          set -g @continuum_save_dir '~/.tmux/resurrect' # This is usually handled by resurrect
          run-shell 'mkdir -p ~/.tmux/resurrect'
        '';
      }
      {
        plugin = tokyo-night-tmux;
        extraConfig = ''
          set -g @theme_variation 'moon'
        '';
      }
    ];

    # This reads your local file and appends it to the generated config
    extraConfig = builtins.readFile ./configs/tmux.conf;
  };

  programs.home-manager.enable = true;

  programs.caelestia = {
    enable = true;
    systemd.enable = true;
    systemd.target = "default.target";
  };

  home.stateVersion = "25.05";
}
