-- ~/.config/nvim/lua/plugins/init.lua
--
-- lazy.nvim plugin spec imports.
-- This file lists optional plugins only.
-- lazy.nvim handles install/update/lockfile behavior.

return {
  { import = "plugins.tokyonight" },
  { import = "plugins.lualine" },
  { import = "plugins.treesitter" },
  { import = "plugins.gitsigns" },
}
