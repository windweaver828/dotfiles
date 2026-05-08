-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  {
    "nvim-treesitter/nvim-treesitter",

    -- Important for Neovim 0.11.x.
    -- The new main branch is a rewrite aimed at Neovim 0.12+.
    branch = "master",

    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },

    opts = {
      ensure_installed = {
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "python",
        "yaml",
        "json",
        "toml",
        "markdown",
        "markdown_inline",
      },

      auto_install = false,
      sync_install = false,

      highlight = {
        enable = true,

        -- Use normal Vim regex highlighting too only when needed.
        -- Keeping this false avoids double-highlighting slowdowns.
        additional_vim_regex_highlighting = false,

        -- Bail out on big files.
        disable = function(_, buf)
          local max_filesize = 1024 * 1024 -- 1MB
          local name = vim.api.nvim_buf_get_name(buf)
          local ok, stats = pcall(vim.loop.fs_stat, name)
          return ok and stats and stats.size > max_filesize
        end,
      },

      -- Keep this OFF. Tree-sitter indent is the feature most likely
      -- to do weird things, and normal Neovim indent is fine.
      indent = {
        enable = false,
      },
    },

    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
