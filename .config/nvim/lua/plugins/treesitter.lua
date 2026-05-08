-- Treesitter config.
-- No parser auto-installs.

local ok, configs = pcall(require, "nvim-treesitter.configs")

if not ok then
  return
end

configs.setup({
  ensure_installed = {},
  sync_install = false,
  auto_install = false,

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
