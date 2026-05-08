return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Setup mason-lspconfig to automatically install the desired LSP servers
    require("mason-lspconfig").setup({
      ensure_installed = {
        "bashls",
        "html",
        "jsonls",
        "lua_ls",
        "ts_ls",
        "yamlls",
        "pyright",
      },
    })

    local lspconfig = require("lspconfig")
    lspconfig.ansiblels.setup({})
    lspconfig.bashls.setup({})
    lspconfig.cssls.setup({})
    lspconfig.emmet_language_server.setup({})
    lspconfig.html.setup({})
    lspconfig.htmx.setup({})
    lspconfig.jinja_lsp.setup({})
    lspconfig.jsonls.setup({})
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })
    lspconfig.powershell_es.setup({})
    lspconfig.sqlls.setup({})
    lspconfig.tailwindcss.setup({})
    lspconfig.ts_ls.setup({})
    lspconfig.lemminx.setup({})
    lspconfig.yamlls.setup({})

    -- Use windows python and add site-packages to pyright lspconfig if it exists
    local windows_python_path = "/mnt/c/Users/Keith/AppData/Local/Programs/Python/Python312/python.exe"
    if vim.fn.filereadable(windows_python_path) == 1 then
      lspconfig.pyright.setup({
        cmd = { "pyright-langserver", "--stdio" },
        settings = {
          python = {
            pythonPath = windows_python_path,
            analysis = {
              extraPaths = {
                "/mnt/c/Users/Keith/AppData/Local/Programs/Python/Python312/Lib/site-packages",
              },
            },
          },
        },
      })
    else
      lspconfig.pyright.setup({
        cmd = { "pyright-langserver", "--stdio" },
      })
    end

    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
    local function toggle_virtual_text()
      local current_value = vim.diagnostic.config().virtual_text
      vim.diagnostic.config({ virtual_text = not current_value })
    end
    vim.keymap.set("n", "<leader>cD", toggle_virtual_text, { desc = "Toggle Inline Diagnostics" })
  end,
}
