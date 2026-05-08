local ok, tokyonight = pcall(require, "tokyonight")

if not ok then
  pcall(vim.cmd.colorscheme, "habamax")
  return
end

tokyonight.setup({
  style = "moon",
  transparent = false,
  terminal_colors = true,
})

vim.cmd.colorscheme("tokyonight")
