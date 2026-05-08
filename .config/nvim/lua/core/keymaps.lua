-- ~/.config/nvim/lua/core/keymaps.lua

local map = vim.keymap.set

-- 1. Unmap spacebar in normal mode
vim.keymap.set("n", "<Space>", "", { silent = true, remap = false })

-- 2. Set the leader key to space
vim.g.mapleader = " "

-- Basic commands.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quitall<CR>", { desc = "Quit" })
map("n", "<leader>qq", "<cmd>quitall!<CR>", { desc = "Quit all" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Built-in file explorer.
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Open file explorer" })

-- Tmux/window navigation fallback.
map("n", "<C-h>", "<C-w>h", { desc = "Move left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move right" })

-- Escape insert mode.
map("i", "jk", "<Esc>", { remap = false })
map("i", "kj", "<Esc>", { remap = false })

-- Indent helpers.
map("n", "<Tab>", ">>", { remap = false, desc = "Indent line" })
map("n", "<S-Tab>", "<<", { remap = false, desc = "Unindent line" })
map("v", "<Tab>", ">gv", { remap = false, desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { remap = false, desc = "Unindent selection" })

-- Keep cursor centered on search jumps.
map("n", "n", "nzzzv", { remap = false })
map("n", "N", "Nzzzv", { remap = false })

-- Clipboard helpers.
map({ "n", "v" }, "<leader>y", '"+y', { remap = false, desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { remap = false, desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { remap = false, desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { remap = false, desc = "Paste before from system clipboard" })

-- Diagnostics.
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

map("n", "cD", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
end, { desc = "Toggle inline diagnostics" })
