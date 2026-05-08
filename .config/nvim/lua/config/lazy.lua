-- ~/.config/nvim/lua/config/lazy.lua
--
-- lazy.nvim plugin manager setup.
--
-- This uses lazy.nvim directly, but does NOT use LazyVim.
-- Background update checks and missing-plugin auto-installs are disabled.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")

if not ok then
  vim.notify("lazy.nvim failed to load", vim.log.levels.ERROR)
  return
end

lazy.setup("plugins", {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",

  install = {
    -- Do not auto-install missing plugins on startup.
    -- Run :Lazy install manually when desired.
    missing = false,
  },

  checker = {
    -- Do not check for updates in the background.
    -- Run :Lazy check manually when desired.
    enabled = false,
    notify = false,
  },

  change_detection = {
    enabled = false,
    notify = false,
  },

  ui = {
    border = "rounded",
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
