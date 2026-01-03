{ ... }:

{
  programs.nixvim = {
    opts = {
      # LazyVim provides sensible defaults, minimal customization here
      # Add any custom options if needed in the future
    };

    # Disable some RTP plugins (from lazy.lua config)
    performance.combinePlugins.enable = true;
  };
}
