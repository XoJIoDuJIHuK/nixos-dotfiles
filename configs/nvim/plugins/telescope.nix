{ ... }:

{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          desc = "Find Files";
        };
        "<leader>fg" = {
          action = "live_grep";
          desc = "Live Grep";
        };
        "<leader>fb" = {
          action = "buffers";
          desc = "Buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          desc = "Help Tags";
        };
      };

      settings.defaults = {
        layout_strategy = "horizontal";
        layout_config = {
          prompt_position = "top";
        };
        sorting_strategy = "ascending";
        winblend = 0;
      };
    };
  };
}
