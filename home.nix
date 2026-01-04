{ config, pkgs, username, inputs, self, caelestia-shell, nixvim, ... }:

{
  imports = [
    caelestia-shell.homeManagerModules.default
    nixvim.homeModules.nixvim
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
    dunst # notifications
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

    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    fira-sans
    nerd-fonts.iosevka
    nerd-fonts.hack
    font-awesome

    docker
    docker-compose
  ];

  services.dunst.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh"; # Optional: set your default shell
    terminal = "tmux-256color";
    historyLimit = 2000;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;

    # This replaces TPM. Nix will download and source these automatically.
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      {
        plugin = tokyo-night-tmux;
        extraConfig = ''
          # Any specific variables for the theme go here
          set -g @theme_variation 'moon'
        '';
      }
    ];

    extraConfig = ''
      # --- General Settings ---
      # Without this reloading config will not unbind old keys
      unbind-key -a -T root
      set -g pane-border-lines double
      setw -g pane-base-index 1
      set -g focus-events on

      # Fix Colors
      set -ag terminal-overrides ",xterm-256color:RGB,*256col*:RGB,alacritty:RGB,kitty:RGB"

      # --- Keybindings ---
      # Reload config (Note: Home Manager places the config at ~/.config/tmux/tmux.conf)
      bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      bind -n M-s choose-tree -s

      # Window Navigation
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Pane Navigation
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Copy Mode / Scrolling
      bind -n C-S-Up copy-mode \; send -X cursor-up
      bind -n C-S-Down copy-mode \; send -X cursor-down
      bind -n C-S-PgUp copy-mode -u
      bind -n C-S-PgDn copy-mode \; send -X page-down
      bind -n C-S-Home copy-mode \; send -X history-top
      bind -n C-S-End copy-mode \; send -X history-bottom

      # Splits and Windows
      bind -n M-h split-window -v
      bind -n M-v split-window -h
      bind -n M-Enter new-window
      bind -n M-c kill-pane
      bind -n M-q kill-window
      bind -n M-d detach
      bind -n M-Q confirm-before -p "Kill entire session? (y/n)" kill-session

      # Vi Copy Mode Logic
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy || xclip -in -selection clipboard"
      bind -n M-/ copy-mode \; command-prompt -p "(search down)" "send -X search-forward '%%%'"
      bind -n M-? copy-mode \; command-prompt -p "(search up)"   "send -X search-backward '%%%'"

      # Plugin Settings
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
    '';
  };


  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = "${self}/configs/starship.toml";
  xdg.configFile."foot/foot.ini".source = "${self}/configs/foot/foot.ini";
  xdg.configFile."kitty/kitty.conf".source = "${self}/configs/kitty/kitty.conf";

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

  programs.kitty = {
    enable = true;
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
      # We do NOT set a theme here because Oh-My-Posh handles it.

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

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Caelestia Shell (Quickshell sidebar)
  programs.caelestia = {
    enable = true;
    systemd.enable = true;
    systemd.target = "default.target";
  };

  home.stateVersion = "25.05";
}
