{ pkgs, config, ... }:
let
  # Define a custom ASCII art greeting
  myAsciiArt = ''
     _   _  _          ____   ____
    | \ | |(_)__  __ / __ \ / ___|
    |  \| || |\ \/ /| |  | |\___ \
    | |\  || | >  < | |__| | ___) |
    |_| \_||_|/_/\_\ \____/ |____/
  '';
in
{
  # High-resolution console font for better TUI appearance
  console = {
    earlySetup = true;
    font = "ter-v32n"; # Large, clean Terminus font
    packages = with pkgs; [ terminus_font ];
  };

  # Create the logo file for tuigreet
  environment.etc."greetd/logo.txt".text = myAsciiArt;

  # Configure greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # --issue points to our logo file
        # --time displays the clock
        # --theme sets the colors
        command = "${pkgs.tuigreet}/bin/tuigreet --time --issue /etc/greetd/logo.txt --cmd start-hyprland --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions --remember --remember-user-session --container-padding 2 --window-padding 2 --greet-align center --theme 'border=magenta;text=cyan;prompt=green;time=red;action=blue;button=white;container=black;input=red'";
        user = "greeter";
      };
    };
  };

  # Note: boot.kernelParams = [ "console=tty1" ]; is already set in configuration.nix
}
