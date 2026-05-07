return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      icons_enabled = true, -- Enable icons for a modern look
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {}, -- Filetypes where lualine is disabled
      always_show_tabline = true,
      theme = "tokyonight",
    },
    -- sections = {
    --   lualine_a = { "mode" }, -- Mode (e.g., NORMAL, INSERT)
    --   lualine_b = { "branch", "diff", "diagnostics" }, -- Optional extras
    --   lualine_c = { { "filename", file_status = true, path = 1 } }, -- Filename, with readonly/modified status
    --   lualine_x = { "fileformat", "fileencoding", "filetype" }, -- File details
    --   lualine_y = { "progress" }, -- Percent progress
    --   lualine_z = { "location" }, -- Line and column numbers
    -- },
    -- inactive_sections = {
    --   lualine_a = {},
    --   lualine_b = {},
    --   lualine_c = { { "filename", file_status = true, path = 1 } },
    --   lualine_x = { "location" },
    --   lualine_y = {},
    --   lualine_z = {},
    -- },
    tabline = {
      lualine_a = { "buffers" },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "tabs" },
    },
    -- extensions = {}, -- Add plugin-specific extensions if needed
  },
}
