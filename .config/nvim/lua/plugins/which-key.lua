-- ~/.config/nvim/lua/plugins/which-key.lua

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",

      -- Show the popup quickly after pressing leader.
      -- This is independent of vim.opt.timeoutlen in current which-key.
      delay = 300,

      icons = {
        mappings = vim.env.WW_NVIM_ICONS == "1",
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
