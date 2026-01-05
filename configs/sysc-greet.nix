{
  services.sysc-greet = {
    enable = true;
    compositor = "hyprland";  # or "hyprland" or "sway"
  };

  # Optional: Set initial session for auto-login
  services.sysc-greet.settings.initial_session = {
    command = "start-hyprland";
    user = "aleh";
  };
}
