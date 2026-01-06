-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Faster timeout for which-key popup (reduce lag when pressing Esc)
vim.opt.timeoutlen = 150
-- Longer ttimeoutlen to prevent Esc+j/k from registering as Alt+j/k
vim.opt.ttimeoutlen = 100
