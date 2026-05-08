-- ~/.config/nvim/lua/core/keymaps.lua

local function search_center()
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype == "/" or cmdtype == "?" then
    return "<CR>zz"
  end
  return "<CR>"
end

local function fzf(command, opts)
  return function()
    local ok, fzf_lua = pcall(require, "fzf-lua")
    if not ok then
      vim.notify("fzf-lua is not installed", vim.log.levels.WARN)
      return
    end
    fzf_lua[command](opts or {})
  end
end

local function netrw_toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      if #vim.api.nvim_list_wins() > 1 then
        vim.api.nvim_win_close(win, true)
      else
        vim.cmd("bprevious")
      end
      return
    end
  end
  vim.cmd("Lexplore")
end

local function buffers_listed()
  local buffers = vim.tbl_filter(function(buf)
    return buf.listed == 1
      and vim.api.nvim_buf_is_valid(buf.bufnr)
      and vim.bo[buf.bufnr].buflisted
  end, vim.fn.getbufinfo({ buflisted = 1 }))
  -- Match the usual lualine "buffers" component order: buffer number order.
  table.sort(buffers, function(a, b)
    return a.bufnr < b.bufnr
  end)
  return buffers
end

local function buffer_go_to(position)
  local buffers = buffers_listed()
  local target = buffers[position]
  if target then
    vim.api.nvim_set_current_buf(target.bufnr)
  else
    vim.notify("No buffer at position " .. position, vim.log.levels.WARN)
  end
end

local map = vim.keymap.set

-- Unmap spacebar in normal mode and set the leader key to space
map("n", "<Space>", "", { silent = true, remap = false })
vim.g.mapleader = " "

-- Basic commands.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>wa<CR><cmd>q<CR>", { desc = "Write all and quit" })
map("n", "<leader>qq", "<cmd>quitall!<CR>", { desc = "Quit all" })
map("n", "<leader>/", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Built-in file explorer.
map("n", "<leader>e", netrw_toggle, { desc = "Toggle file explorer" })

-- Window splits
-- Match tmux-style split keys:
--   <leader>| and <leader>% = vertical split / side-by-side
--   <leader>- and <leader>" = horizontal split / stacked
map("n", "<leader>|", "<cmd>rightbelow vsplit<CR>", { desc = "Split window right" })
map("n", "<leader>%", "<cmd>rightbelow vsplit<CR>", { desc = "Split window right" })
map("n", "<leader>-", "<cmd>rightbelow split<CR>", { desc = "Split window below" })
map("n", '<leader>"', "<cmd>rightbelow split<CR>", { desc = "Split window below" })

-- Window management
map("n", "<leader>x", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })

-- Insert line above or below
map("n", "<leader>o", "o<Esc>k", { desc = "Insert line below" })
map("n", "<leader>O", "O<Esc>j", { desc = "Insert line above" })

-- Buffers
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader><space>", "<C-^>", { desc = "Alternate buffer" })
map("n", "<leader>dd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
-- Allow leader 1-9 to jump to buffer
for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    buffer_go_to(i)
  end, {
    desc = "Go to buffer position " .. i,
  })
end

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

-- Center the first jump after / or ? search.
map("c", "<CR>", search_center, { expr = true, remap = false, desc = "Enter command/search" })

-- Center word-search jumps.
map("n", "*", "*zz", { remap = false, desc = "Search word forward" })
map("n", "#", "#zz", { remap = false, desc = "Search word backward" })
map("n", "g*", "g*zz", { remap = false, desc = "Search partial word forward" })
map("n", "g#", "g#zz", { remap = false, desc = "Search partial word backward" })

-- Clipboard helpers.
map("v", "<C-c>", '"+y', { remap = true, desc = "Copy to system clipboard, familiar shortcut" })
map("v", "<C-x>", '"+c', { remap = true, desc = "Cut to system clipboard, familiar shortcut" })
map({ "n", "v" }, "<leader>y", '"+y', { remap = false, desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { remap = false, desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { remap = false, desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { remap = false, desc = "Paste before from system clipboard" })

-- Diagnostics.
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

map("n", "<leader>cD", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
end, { desc = "Toggle inline diagnostics" })

--  Fuzzy search files for text and open file
map("n", "<leader>ff", fzf("files"), { desc = "Find files" })
map("n", "<leader>fg", fzf("git_files"), { desc = "Find git files" })
map("n", "<leader>fr", fzf("oldfiles"), { desc = "Recent files" })
map("n", "<leader>fo", fzf("oldfiles"), { desc = "Recent files" })
map("n", "<leader>fb", fzf("buffers", { sort_mru = true, sort_lastused = true }), { desc = "Buffers" })
map("n", "<leader>fB", fzf("builtin"), { desc = "Fzf Built-in Commands" })
map("n", "<leader>f/", fzf("live_grep"), { desc = "Grep files" })
map("n", "<leader>fs", fzf("live_grep"), { desc = "Grep files" })
map("n", "<leader>fw", fzf("grep_cword"), { desc = "Grep word" })
map("x", "<leader>fw", fzf("grep_visual"), { desc = "Grep selection" })
map("n", "<leader>fc", fzf("files", { cwd = vim.fn.stdpath("config") }), { desc = "Find config files" })
map("n", "<leader>fC", fzf("command_history"), { desc = "Command history" })
map("n", "<leader>fh", fzf("help_tags"), { desc = "Help tags" })
map("n", "<leader>fk", fzf("keymaps"), { desc = "Keymaps" })
map("n", "<leader>fR", fzf("resume"), { desc = "Resume fzf" })
