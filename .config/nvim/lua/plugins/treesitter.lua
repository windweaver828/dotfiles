-- ~/.config/nvim/lua/plugins/treesitter.lua
--
-- Treesitter is installed only when explicitly running :Lazy install.
-- Parser installs are allowed once the plugin itself has intentionally been installed.

return {
  {
    "nvim-treesitter/nvim-treesitter",

    -- Use the classic branch for now.
    -- It supports the stable nvim-treesitter.configs API and works well
    -- on current Nvim 0.10/0.11 systems.
    branch = "master",

    -- Runs during explicit :Lazy install / :Lazy update actions.
    build = ":TSUpdate",

    event = { "BufReadPost", "BufNewFile" },

    opts = {
      ensure_installed = {
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

      sync_install = false,

      -- Since nvim-treesitter itself is only installed intentionally,
      -- allow it to install missing configured parsers when needed.
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
    },

    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
