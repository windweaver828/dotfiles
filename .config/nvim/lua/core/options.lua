-- ~/.config/nvim/lua/core/options.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Filetype / syntax.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- Editor behavior.
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Indentation.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Search.
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI / movement.
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.wrap = false
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Completion.
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Files.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.fileformats = { "unix", "mac", "dos" }

-- Do not force system clipboard globally.
-- Use explicit clipboard mappings instead.
vim.opt.clipboard = ""

-- Built-in netrw file browser.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

-- Diagnostics.
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})
