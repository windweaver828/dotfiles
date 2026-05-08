-- ~/.config/nvim/lua/plugins/lualine.lua

return {
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
      options = {
        theme = "tokyonight",
        icons_enabled = true,
        globalstatus = true,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            path = 1,
            file_status = true,
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },

      tabline = {
        lualine_a = { "buffers" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "tabs" },
      },
    },
  },
}
