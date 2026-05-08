-- ~/.config/nvim/lua/plugins/blink.lua

return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",

    dependencies = {
      "rafamadriz/friendly-snippets",
    },

    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "super-tab",

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },

        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = vim.env.WW_NVIM_ICONS == "1" and "mono" or "normal",
      },

      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },

        documentation = {
          auto_show = false,
        },

        ghost_text = {
          enabled = true,
        },
      },

      signature = {
        enabled = true,
      },

      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
        },
      },

      fuzzy = {
        implementation = "lua",
      },
    },

    opts_extend = {
      "sources.default",
    },
  },
}
