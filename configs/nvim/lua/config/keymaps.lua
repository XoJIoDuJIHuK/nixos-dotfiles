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

-- Rename current file with LSP import updates
vim.keymap.set("n", "<leader>rf", function()
  local old_name = vim.fn.expand("%:t")
  local new_name = vim.fn.input("New filename: ", old_name, "file")
  if new_name and new_name ~= "" and new_name ~= old_name then
    local old_path = vim.fn.expand("%:p")
    local new_path = vim.fn.expand("%:p:h") .. "/" .. new_name
    vim.fn.rename(old_path, new_path)
    vim.cmd("edit " .. new_path)
    vim.notify("Renamed to: " .. new_name)
  end
end, { desc = "Rename file (update imports)" })
