-- ~/.config/nvim/lua/plugins/treesitter.lua
--
-- Treesitter config.
-- The plugin itself is optional.
-- Parsers are managed only after nvim-treesitter is intentionally installed.

local ok, configs = pcall(require, "nvim-treesitter.configs")

if not ok then
  return
end

local manifest_ok, manifest = pcall(require, "core.plugin_manifest")
local parsers = {}

if manifest_ok then
  parsers = manifest.treesitter_parsers or {}
end

configs.setup({
  -- Since nvim-treesitter itself is only installed intentionally,
  -- let it keep this small approved parser list installed.
  ensure_installed = parsers,
  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,

    disable = function(_, bufnr)
      local max_filesize = 512 * 1024
      local filename = vim.api.nvim_buf_get_name(bufnr)

      if filename == "" then
        return false
      end

      local uv = vim.uv or vim.loop
      local ok_stat, stats = pcall(uv.fs_stat, filename)

      return ok_stat and stats and stats.size > max_filesize
    end,
  },

  indent = {
    enable = true,
  },
})
