-- ~/.config/nvim/lua/core/plugin_manifest.lua
--
-- Optional plugins and parser list.
-- These are installed/updated only when explicitly requested.

return {
  plugins = {
    {
      name = "tokyonight.nvim",
      repo = "https://github.com/folke/tokyonight.nvim.git",
    },
    {
      name = "lualine.nvim",
      repo = "https://github.com/nvim-lualine/lualine.nvim.git",
    },
    {
      name = "nvim-treesitter",
      repo = "https://github.com/nvim-treesitter/nvim-treesitter.git",
    },
    {
      name = "gitsigns.nvim",
      repo = "https://github.com/lewis6991/gitsigns.nvim.git",
    },
  },

  treesitter_parsers = {
    "bash",
    "lua",
    "python",
    "vim",
    "vimdoc",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
  },
}
