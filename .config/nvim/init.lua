require("core.options")
require("core.keymaps")
require("core.lsp")
require("plugins")

-- Optional local machine-specific config.
-- Keep this untracked.
local uv = vim.uv or vim.loop
local local_config = vim.fn.stdpath("config") .. "/lua/local.lua"

if uv.fs_stat(local_config) then
  dofile(local_config)
end
