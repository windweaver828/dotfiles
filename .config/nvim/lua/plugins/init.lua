-- Plugin config loader.
-- Missing plugins are silently ignored.

local plugin_modules = {
  "plugins.tokyonight",
  "plugins.lualine",
  "plugins.treesitter",
  "plugins.gitsigns",
}

for _, module in ipairs(plugin_modules) do
  pcall(require, module)
end
