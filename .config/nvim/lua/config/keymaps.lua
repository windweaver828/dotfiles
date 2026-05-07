-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Enable tmux navigator keybindings
vim.api.nvim_set_keymap("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true })

-- Escape insert mode easily
vim.keymap.set("i", "kj", "<Esc>", { remap = false })
vim.keymap.set("i", "jk", "<Esc>", { remap = false })

-- Indent/unindent with Tab/Shift-Tab
vim.keymap.set("n", "<Tab>", ">>", { remap = false })
vim.keymap.set("n", "<S-Tab>", "<<", { remap = false })
vim.keymap.set("i", "<S-Tab>", "<Esc><<i", { remap = false })
vim.keymap.set("v", "<Tab>", ">gv", { remap = false })
vim.keymap.set("v", "<Tab>", ">gv", { remap = false })
vim.keymap.set("v", "<S-Tab>", "<gv", { remap = false })

-- Copy & cut to system clipboard
-- vim.keymap.set("v", "<C-c>", '"+y', { remap = false })
-- vim.keymap.set("v", "<C-x>", '"+c', { remap = false })
vim.keymap.set("v", "<C-c>", '"+y', { remap = true })
vim.keymap.set("v", "<C-x>", '"+c', { remap = true })

--  Fuzzy search files for text and open file
vim.keymap.set("n", "<leader>fs", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep search" })
