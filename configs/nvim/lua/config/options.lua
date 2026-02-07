-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Faster timeout for which-key popup (reduce lag when pressing Esc)
vim.opt.timeoutlen = 10
-- Shorter ttimeoutlen to make Esc register immediately and prevent Alt+j/k
vim.opt.ttimeoutlen = 5
-- Disable auto-formatting on save
vim.g.autoformat = false
