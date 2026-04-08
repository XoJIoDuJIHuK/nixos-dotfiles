# Usage: run `rbw login` once after update to enter master password
# It seems master password input is needed after each reboot

{ config, pkgs, ... }:

let
  # A custom script to fetch mail manually, index it, and notify you.
  # This solves the "I don't know if messages were fetched" problem.
  mailSyncScript = pkgs.writeShellScriptBin "mail-sync" ''
    echo "Starting mail synchronization..."
    # Run mbsync for all accounts, print output to terminal
    ${pkgs.isync}/bin/mbsync -aV
    
    echo "Indexing new mail with notmuch..."
    ${pkgs.notmuch}/bin/notmuch new
    
    echo "Done!"
    ${pkgs.libnotify}/bin/notify-send "Mail Sync Complete" "New mail has been fetched and indexed."
  '';
in
{
  # 1. Base Packages
  home.packages = with pkgs;[
    mailSyncScript # Our custom manual sync script
    lynx           # For rendering HTML in emails
    catimg         # For images in terminal
    w3m            # Alternative HTML pager heavily used by Aerc
  ];

  # 2. Bitwarden CLI (rbw)
  programs.rbw = {
    enable = true;
    settings = {
      email = "tochilo.oleg@gmail.com";
      base_url = "https://nix-enjoyers.site:8443";
      lock_timeout = 2592000;
      # Optionally set pinentry so it prompts nicely if locked
      pinentry = pkgs.pinentry-curses; 
    };
  };

  # 3. Account Configuration
  accounts.email = {
    maildirBasePath = "Mail";
    
    accounts = {
      "Tochilo-Oleg" = {
        primary = true;
        address = "tochilo.oleg@gmail.com";
        userName = "tochilo.oleg@gmail.com";
        realName = "Aleh Tachyla";
        flavor = "gmail.com"; # Home manager auto-fills IMAP/SMTP hosts for popular providers

        # Bitwarden lookup. Assumes the item in Bitwarden is named "your.email@gmail.com"
        passwordCommand = "${pkgs.rbw}/bin/rbw get 'tochilo.oleg@gmail.com application password'";

        # Enable the backend for this account
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
        };
        msmtp.enable = true;
        notmuch.enable = true;

        # Enable ALL THREE clients for this account so you can test them
        neomutt.enable = true;
        aerc.enable = true;
        himalaya.enable = true;
      };
      
      # Add more accounts here following the same structure...
    };
  };

  # 4. Enable Backend Daemons & Indexer
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    # notmuch needs to know where your mail is
    new.tags = [ "new" ];
  };

  # 5. Background Sync Daemon (Reliability fix)
  services.mbsync = {
    enable = true;
    frequency = "*:0/10"; # Run every 10 minutes
    # Automatically index mail immediately after fetching in the background
    postExec = "${pkgs.notmuch}/bin/notmuch new";
  };

  # 6. Enable the 3 TUI Clients
  
  # CLIENT 1: Himalaya
  programs.himalaya.enable = true;

  # CLIENT 2: Aerc
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true; # Required because we pass password commands
      ui = {
        # Aerc looks much more modern than NeoMutt out of the box
        index-columns = "date<20,name<20,flags>4,subject<*";
        sidebar-width = 20;
      };
      viewer = {
        # Automatically use w3m/lynx to parse HTML emails
        pager = "less -R";
        alternatives = "text/html,text/plain";
      };
    };
  };

  # CLIENT 3: NeoMutt (Your previous config, kept for comparison)
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sidebar = {
      enable = true;
      width = 30;
      shortPath = true;
    };
    sort = "threads";
    # I kept a shortened version of your color config here for brevity,
    # you can paste your massive regex color blocks back into here.
    extraConfig = ''
      color index white default '.*'
      color index_author green default '.*'
      color index_subject blue default '.*'
      color index brightwhite black "~N"
      color sidebar_divider default default
      color sidebar_flagged brightblue default
      color sidebar_new brightyellow default
    '';
  };
}
