-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Grep in custom directory (prompts for path with dir completion)
vim.keymap.set("n", "<leader>s.", function()
  local custom_cwd = vim.fn.input({
    prompt = "Grep in dir: ",
    default = vim.fn.getcwd() .. "/",
    completion = "dir",
  })
  if custom_cwd == "" then
    return
  end -- Cancel if empty
  require("telescope.builtin").live_grep({ cwd = custom_cwd })
end, { desc = "Grep (custom dir)" })
