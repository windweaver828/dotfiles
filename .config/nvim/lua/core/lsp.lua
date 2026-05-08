-- ~/.config/nvim/lua/core/lsp.lua
--
-- Built-in LSP only.
-- No Mason. No auto-installing language servers.
-- Servers are enabled only if their executable already exists.

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local function root_dir(bufnr, markers)
  local name = vim.api.nvim_buf_get_name(bufnr)

  if name == "" then
    return vim.fn.getcwd()
  end

  local start = vim.fs.dirname(name)

  if not start or start == "" then
    return vim.fn.getcwd()
  end

  local found = vim.fs.find(markers, {
    path = start,
    upward = true,
  })[1]

  if found then
    return vim.fs.dirname(found)
  end

  return vim.fn.getcwd()
end

local function start_lsp_for_filetype(opts)
  local name = opts.name
  local cmd = opts.cmd
  local filetypes = opts.filetypes
  local markers = opts.markers or { ".git" }
  local settings = opts.settings

  if not executable(cmd[1]) then
    return
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function(event)
      vim.lsp.start({
        name = name,
        cmd = cmd,
        root_dir = root_dir(event.buf, markers),
        settings = settings,
      }, {
        bufnr = event.buf,
      })
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = event.buf,
        desc = desc,
      })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

    -- Keep your old easy code-action key too.
    map("n", "ca", vim.lsp.buf.code_action, "Code action")
  end,
})

-- Lua.
start_lsp_for_filetype({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".stylua.toml",
    "stylua.toml",
    ".git",
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Bash / shell.
start_lsp_for_filetype({
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  markers = { ".git" },
})

-- Python.
start_lsp_for_filetype({
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
})
