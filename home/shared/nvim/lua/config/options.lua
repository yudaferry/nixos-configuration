-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "snacks"

vim.cmd("set wrap")
--vim.g.clipboard = {
--  name = "win32yank-wsl",
--  copy = {
--    ["+"] = "/mnt/c/Users/mines/bin/win32yank/win32yank.exe -i --crlf",
--    ["*"] = "/mnt/c/Users/mines/bin/win32yank/win32yank.exe -i --crlf",
--  },
--  paste = {
--    ["+"] = "/mnt/c/Users/mines/bin/win32yank/win32yank.exe -o --lf",
--    ["*"] = "/mnt/c/Users/mines/bin/win32yank/win32yank.exe -o --lf",
--  },
--  cache_enabled = 0,
--}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- Start with folds open

vim.opt.mouse = ""
