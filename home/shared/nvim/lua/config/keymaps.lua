-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map("n", "<leader>ga", function()
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
end, { desc = "GitGraph - Draw" })

-- lvim.builtin.which_key.mappings["F"] = {
--   name = "Flutter",
--   r = { "<cmd>FlutterRun<CR>", "Run Flutter" },
--   q = { "<cmd>FlutterQuit<CR>", "Stop existing flutter" },
--   c = { "<cmd>FlutterLogClear<CR>", "Clear flutter log" },
--   t = { "<cmd>FlutterLogToggle<CR>", "Toggle flutter log" },
-- }

vim.keymap.set({"n", "i", "v", "s"}, "<C-z>", "<Nop>", { silent = true })
