-- ~/.config/nvim/init.lua
--
-- Small, secure-friendly Neovim config.
-- No LazyVim, no Mason, no plugin auto-installs, no update checks.

require("core.options")
require("core.keymaps")
require("core.lsp")
require("core.plugin_manager")
require("plugins")

-- Optional local machine-specific config.
-- Keep this untracked.
local uv = vim.uv or vim.loop
local local_config = vim.fn.stdpath("config") .. "/lua/local.lua"

if uv.fs_stat(local_config) then
  dofile(local_config)
end
