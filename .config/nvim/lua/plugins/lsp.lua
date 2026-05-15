-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  {
    "neovim/nvim-lspconfig",

    -- Only load for Python files.
    ft = { "python" },

    config = function()
      local function has(cmd)
        return vim.fn.executable(cmd) == 1
      end

      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ww_lsp_attach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if not client then
            return
          end

          -- Prefer Pyright hover when both Ruff and Pyright are attached.
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
              buffer = bufnr,
              silent = true,
              desc = desc,
            })
          end

          map("n", "gd", vim.lsp.buf.definition, "Goto definition")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        end,
      })

      if has("ruff") then
        vim.lsp.config("ruff", {
          cmd = { "ruff", "server" },
          filetypes = { "python" },
          root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
        })

        vim.lsp.enable("ruff")
      end

      if has("pyright-langserver") then
        vim.lsp.config("pyright", {
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
          root_markers = {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
          },
          settings = {
            pyright = {
              -- Ruff/Conform handles import organization.
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,

                -- Keep Pyright useful but quiet.
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "off",

                -- Ruff is the diagnostic/lint source.
                -- Pyright still provides completion/navigation/hover/rename.
                ignore = { "*" },
              },
            },
          },
        })

        vim.lsp.enable("pyright")
      end
    end,
  },
}
