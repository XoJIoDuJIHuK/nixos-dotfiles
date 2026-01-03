{ ... }:

{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>s.";
        action = ''
          function()
            local custom_cwd = vim.fn.input({
              prompt = "Grep in dir: ",
              default = vim.fn.getcwd() .. "/",
              completion = "dir",
            })
            if custom_cwd == "" then
              return
            end
            require("telescope.builtin").live_grep({ cwd = custom_cwd })
          end
        '';
        options = {
          desc = "Grep (custom dir)";
          expr = false;
        };
      }
    ];
  };
}
