{ config, pkgs, username, hostname, inputs, self, caelestia-shell, ... }:
let
  dotfilesDir = "/home/${username}/.dotfiles";
in {
  imports = [
    ./configs/mail.nix
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
    chroma # for syntax highlighting in ccat
    python3  # for waybar scripts
    wget # for mason
    unzip
    brightnessctl
    hyprpicker  # color picker
    pulseaudio
    grimblast # for screenshots
    pinta # for screenshot editing
    # dunst # notifications - replaced by caelestia-shell
    numbat # tui calculator
    qbittorrent
    uv
    tmux
    lazydocker
    lazygit
    lazysql
    telegram-desktop
    vesktop # discord community wrapper for noise suppression support
    yazi
    claude-code
    opencode
    thunderbird
    pdftk
    nodejs_25  # just for npm for nvim plugins. what a waste
    yt-dlp
    ffmpeg

    # office suites
    wpsoffice
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.uk_UA
    onlyoffice-desktopeditors

    # fonts
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

  xdg = {
    # creates cascade of symlinks. to check if everything works fine, use `realpath` on a symlink
    configFile = {
      "btop".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/btop";
      "caelestia".source     = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/caelestia";
      "foot".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/foot";
      "hypr".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/hypr";
      "kitty".source         = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/kitty";
      "nvim".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/nvim";
      "rofi".source          = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/rofi";
      "waybar".source        = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/waybar";
      "waypaper".source      = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/waypaper";
      "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/starship.toml";
    };

    # for consistency in file pickers
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk     # The file picker we want
        pkgs.xdg-desktop-portal-hyprland # Needed for screen sharing
      ];

      # This is the critical part: tell the system WHICH portal to use for what.
      config = {
        common = {
          default = [ "gtk" ];
          # Force Hyprland for screen sharing/screenshots
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        };
      };
    };
  };

  # theming
  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "hicolor";
      package = pkgs.hicolor-icon-theme;
    };

    # Ensure gtk-4.0 uses the theme (for "modern" libadwaita apps)
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Also set Qt to use the GTK style so Qt apps match
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
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
        "colorize"       # syntax highlighting for file contents when using cat: `ccat file.py`
        "copybuffer"     # press Ctrl+O to copy current command
        "copyfile"       # provides `copyfile` binary to copy file contents to clipboard
        "dotenv"         # auto-loads .env files when cd'ing into directories
        "dirhistory"     # navigate directory history with Alt+Left/Right(back/forth)/Up/Down(to parent/to child)
        "docker"         # auto-completion for docker commands
        "docker-compose" # auto-completion for docker-compose commands
        "git"            # git aliases (gst, gco, etc.) and completion
        "pip"            # auto-completion for pip commands
        "ssh"            # auto-completion for ssh hosts
        "ssh-agent"      # automatically manages ssh-agent and loads keys
        "sudo"           # press Esc twice to prefix current command with sudo
        "ufw"            # auto-completion for ufw firewall commands
        "vi-mode"        # vim-style keybindings in zsh (one Esc to enter, i to exit)
      ];
    };

    # 1. High-level options for the most common plugins
    # Home Manager handles the installation and sourcing automatically.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      l = "eza -l -h";
      v = "nvim";
      update = "sudo nixos-rebuild switch --flake /home/aleh/.dotfiles#${hostname}";
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

    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 2000;

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
    cli.enable = true;
    systemd.enable = true;
    systemd.target = "default.target";
  };

  home.stateVersion = "25.05";
}
