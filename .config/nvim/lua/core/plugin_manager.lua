-- ~/.config/nvim/lua/core/plugin_manager.lua
--
-- Tiny manual plugin manager using native Neovim packages.
-- No automatic startup installs.
-- No update checks.
-- Network/git commands only run when explicitly requested.

local manifest = require("core.plugin_manifest")

local M = {}

M.pack_dir = vim.fn.stdpath("data") .. "/site/pack/plugins/start"
M.plugins = manifest.plugins
M.treesitter_parsers = manifest.treesitter_parsers

local function plugin_path(plugin)
  return M.pack_dir .. "/" .. plugin.name
end

local function is_installed(plugin)
  return vim.fn.isdirectory(plugin_path(plugin) .. "/.git") == 1
end

local function ensure_git()
  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is required for Neovim plugin install/update", vim.log.levels.ERROR)
    return false
  end

  return true
end

local function open_output_buffer(title)
  vim.cmd("botright 15new")

  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "log"

  vim.api.nvim_buf_set_name(buf, title)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  return buf
end

local function append(buf, lines)
  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { plain = true })
  end

  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

local function run(buf, args)
  append(buf, "$ " .. table.concat(args, " "))

  local output = vim.fn.system(args)
  local code = vim.v.shell_error

  if output and output ~= "" then
    append(buf, vim.split(output, "\n", { plain = true }))
  end

  if code ~= 0 then
    append(buf, "Command failed with exit code: " .. code)
    append(buf, "")
    return false
  end

  append(buf, "")
  return true
end

local function clear_config_modules()
  for module, _ in pairs(package.loaded) do
    if module == "plugins"
      or module:match("^plugins%.")
      or module:match("^core%.")
    then
      package.loaded[module] = nil
    end
  end
end

local function reload_nvim_config()
  -- Make newly cloned native packages available in the current session.
  pcall(vim.cmd, "packloadall")

  -- Clear our own modules dynamically.
  -- This avoids maintaining a manual module list as plugins/config grow.
  clear_config_modules()

  local init = vim.fn.stdpath("config") .. "/init.lua"
  dofile(init)

  vim.notify("Neovim config reloaded", vim.log.levels.INFO)
end

local function install_treesitter_parsers(buf)
  if vim.fn.exists(":TSInstallSync") ~= 2 then
    append(buf, "Treesitter command :TSInstallSync is not available. Skipping parser install.")
    append(buf, "")
    return
  end

  if not M.treesitter_parsers or vim.tbl_isempty(M.treesitter_parsers) then
    append(buf, "No Treesitter parsers configured. Skipping parser install.")
    append(buf, "")
    return
  end

  append(buf, "Installing configured Treesitter parsers:")
  append(buf, "  " .. table.concat(M.treesitter_parsers, " "))
  append(buf, "")

  local command = "TSInstallSync " .. table.concat(M.treesitter_parsers, " ")
  local ok, err = pcall(vim.cmd, command)

  if ok then
    append(buf, "Treesitter parser install complete.")
  else
    append(buf, "Treesitter parser install failed:")
    append(buf, tostring(err))
    append(buf, "")
    append(buf, "This usually means build tools are missing.")
    append(buf, "On Fedora, one may need packages like gcc/g++.")
  end

  append(buf, "")
end

function M.check()
  local buf = open_output_buffer("Neovim plugin check")

  append(buf, "Plugin directory:")
  append(buf, "  " .. M.pack_dir)
  append(buf, "")

  for _, plugin in ipairs(M.plugins) do
    if is_installed(plugin) then
      append(buf, "installed  " .. plugin.name)
    else
      append(buf, "missing    " .. plugin.name)
    end
  end

  append(buf, "")

  if vim.fn.exists(":TSInstallSync") == 2 then
    append(buf, "Treesitter command available.")
  else
    append(buf, "Treesitter command not available.")
  end
end

function M.install()
  if not ensure_git() then
    return
  end

  vim.fn.mkdir(M.pack_dir, "p")

  local buf = open_output_buffer("Neovim plugin install")

  append(buf, "Installing missing optional Neovim plugins")
  append(buf, "Plugin directory:")
  append(buf, "  " .. M.pack_dir)
  append(buf, "")

  for _, plugin in ipairs(M.plugins) do
    local dest = plugin_path(plugin)

    if is_installed(plugin) then
      append(buf, plugin.name .. " already installed.")
      append(buf, "")
    else
      run(buf, {
        "git",
        "clone",
        "--depth",
        "1",
        plugin.repo,
        dest,
      })
    end
  end

  append(buf, "Plugin install complete.")
  append(buf, "")

  -- Reload first so newly cloned plugins are available.
  reload_nvim_config()

  -- Then install Treesitter parsers if nvim-treesitter is now available.
  install_treesitter_parsers(buf)

  vim.notify("Neovim plugin install complete", vim.log.levels.INFO)
end

function M.update()
  if not ensure_git() then
    return
  end

  local buf = open_output_buffer("Neovim plugin update")

  append(buf, "Updating installed optional Neovim plugins")
  append(buf, "Plugin directory:")
  append(buf, "  " .. M.pack_dir)
  append(buf, "")

  for _, plugin in ipairs(M.plugins) do
    local dest = plugin_path(plugin)

    if is_installed(plugin) then
      run(buf, {
        "git",
        "-C",
        dest,
        "pull",
        "--ff-only",
      })
    else
      append(buf, plugin.name .. " is missing. Skipping update.")
      append(buf, "")
    end
  end

  append(buf, "Plugin update complete.")
  append(buf, "")

  -- Reload first so updated plugins are active.
  reload_nvim_config()

  -- Then update/install configured Treesitter parsers.
  install_treesitter_parsers(buf)

  vim.notify("Neovim plugin update complete", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("NvimPluginsCheck", function()
  M.check()
end, {
  desc = "Check optional Neovim plugin install status",
})

vim.api.nvim_create_user_command("NvimPluginsInstall", function()
  M.install()
end, {
  desc = "Install missing optional Neovim plugins",
})

vim.api.nvim_create_user_command("NvimPluginsUpdate", function()
  M.update()
end, {
  desc = "Update installed optional Neovim plugins",
})

vim.api.nvim_create_user_command("NvimReload", function()
  reload_nvim_config()
end, {
  desc = "Reload Neovim config",
})

return M
