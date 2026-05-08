-- ~/.config/nvim/lua/plugins/which-key.lua

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- LazyVim-like placement/style
      preset = "helix",

      -- Show the popup quickly after pressing leader.
      -- This is independent of vim.opt.timeoutlen in current which-key.
      delay = 300,

      icons = {
        mappings = vim.env.WW_NVIM_ICONS == "1",
      },

      win = {
        -- Keep it pinned instead of jumping around to avoid the cursor.
        no_overlap = false,

        -- Helix/LazyVim-ish: compact popup near the bottom/right.
        width = { min = 30, max = 60 },
        height = { min = 4, max = 0.75 },
        col = -1,
        row = -1,

        border = "rounded",
        padding = { 0, 1 },
        title = true,
        title_pos = "left",

        zindex = 1000,
        wo = {
          winblend = 0,
        },
      },

      layout = {
        width = { min = 30 },
        spacing = 3,
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
  },
}
