{ config, pkgs, ... }:

let
  # The Command to fetch passwords from KeePassXC via Secret Service
  # We look up by the attribute 'username' we set in Step 1
  passCmd = user: "${pkgs.libsecret}/bin/secret-tool lookup username ${user}";
in
{
  home.packages = with pkgs; [
    neomutt
    libsecret     # For secret-tool
    isync         # For mbsync
    msmtp         # For sending
    lynx          # To view HTML mail
    notmuch       # For indexing/searching (optional but recommended)
    catimg        # for images in terminal
  ];

  # 2. Configure Accounts
  accounts.email = {
    maildirBasePath = "Mail"; # Mail will live in ~/Mail
    
    accounts = {
      
      # ACCOUNT 1: Personal
      tochiloYandexBy = {
        primary = true;
        address = "tochilo.oleg@yandex.by";
        userName = "tochilo.oleg@yandex.by";
        realName = "Aleh Tachyla";
        
        # IMAP (Receive)
        imap.host = "imap.yandex.by";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        
        # SMTP (Send)
        smtp.host = "smtp.yandex.ru";
        msmtp.enable = true;

        # Password Logic
        passwordCommand = passCmd "tochilo.oleg@yandex.by";

        # Enable NeoMutt for this account
        neomutt = {
          enable = true;
          mailboxName = "Personal";
          extraConfig = ''
            # Account specific colors or settings could go here
          '';
        };
      };

      # ACCOUNT 2: XoJIoDuJIHuK
      xojiodujihukYandexBy = {
        address = "xojiodujihuk@yandex.by";
        userName = "xojiodujihuk@yandex.by";
        realName = "Aleh Tachyla";
        
        # IMAP (Receive)
        imap.host = "imap.yandex.by";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        
        # SMTP (Send)
        smtp.host = "smtp.yandex.ru";
        msmtp.enable = true;

        # Password Logic
        passwordCommand = passCmd "xojiodujihuk@yandex.by";

        # Enable NeoMutt for this account
        neomutt = {
          enable = true;
          mailboxName = "Personal XoJIoDuJIHuK";
          extraConfig = ''
            # Account specific colors or settings could go here
          '';
        };
      };
    };
  };

      # 3. Enable the Programs
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  # 4. The Daemon (Background Sync)
  services.mbsync = {
    enable = true;
    frequency = "*:0/10"; # Run every 10 minutes
    # specific post-sync commands (like notifications) can go here:
    # postExec = "${pkgs.libnotify}/bin/notify-send 'New Mail' 'Check NeoMutt'";
  };

  # 5. NeoMutt Customization (UI & Tokyonight)
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sidebar = {
      enable = true;
      width = 30;
      shortPath = true; # Shows "INBOX" instead of "/home/user/Mail/Account/INBOX"
    };

    sort = "threads";

    extraConfig = ''
      # Default index colors:
      color index white default '.*'
      color index_author green default '.*'
      color index_number white default
      color index_subject blue default '.*'
      
      # New mail is boldened:
      color index brightwhite black "~N"
      color index_author brightgreen black "~N"
      color index_subject brightblue black "~N"
      
      # Tagged mail is highlighted:
      color index brightblack blue "~T"
      color index_author brightblack blue "~T"
      color index_subject brightblack blue "~T"
      
      # Other colors and aesthetic settings:
      mono bold bold
      mono underline underline
      mono indicator reverse
      mono error bold
      color normal default default
      color indicator brightblack white
      color sidebar_highlight default brightblack
      color sidebar_divider default default
      color sidebar_flagged brightblue default
      color sidebar_new brightyellow default
      color normal brightwhite default
      color error red default
      color tilde black default
      color message white default
      color markers red white
      color attachment white default
      color search brightmagenta default
      color status brightmagenta default
      color hdrdefault brightgreen default
      color quoted green default
      color quoted1 blue default
      color quoted2 cyan default
      color quoted3 yellow default
      color quoted4 red default
      color quoted5 brightred default
      color signature brightblue default
      color bold black default
      color underline black default
      color normal default default
      
      # Regex highlighting:
      color header white default ".*"
      color header brightblue default "^(From)"
      color header brightcyan default "^(Subject)"
      color header brightwhite default "^(CC|BCC)"
      color body brightblue default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
      color body brightmagenta default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
      color body green default "\`[^\`]*\`" # Green text between ` and `
      color body brightblue default "^# \.*" # Headings as bold blue
      color body brightcyan default "^## \.*" # Subheadings as bold cyan
      color body brightgreen default "^### \.*" # Subsubheadings as bold green
      color body cyan default "^(\t| )*(-|\\*) \.*" # List items as yellow
      color body brightcyan default "[;:][-o][)/(|]" # emoticons
      color body brightcyan default "[;:][)(|]" # emoticons
      color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
      color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
      color body red default "(BAD signature)"
      color body cyan default "(Good signature)"
      color body brightblack default "^gpg: Good signature .*"
      color body brightyellow default "^gpg: "
      color body brightyellow red "^gpg: BAD signature from.*"
      mono body bold "^gpg: Good signature"
      mono body bold "^gpg: BAD signature from.*"
      #color body red default "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)?\t\r\n<>\"]"
    '';
  };
}
