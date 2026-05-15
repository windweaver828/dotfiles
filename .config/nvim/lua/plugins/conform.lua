-- ~/.config/nvim/lua/plugins/conform.lua

return {
  "stevearc/conform.nvim",

  -- Load early enough for format-on-save.
  event = { "BufReadPre", "BufNewFile" },

  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({
          async = false,
          timeout_ms = 5000,
          lsp_format = "fallback",
        })
      end,
      mode = { "n", "v" },
      desc = "Format buffer/range",
    },
    {
      "<leader>cF",
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("format-on-save: " .. (vim.g.disable_autoformat and "off" or "on"))
      end,
      desc = "Toggle format-on-save",
    },
  },

  init = function()
    -- Format-on-save enabled by default.
    vim.g.disable_autoformat = false

    vim.api.nvim_create_user_command("Format", function()
      require("conform").format({
        async = false,
        timeout_ms = 5000,
        lsp_format = "fallback",
      })
    end, {
      desc = "Format current buffer",
    })

    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
        vim.notify("format-on-save disabled for this buffer")
      else
        vim.g.disable_autoformat = true
        vim.notify("format-on-save disabled globally")
      end
    end, {
      desc = "Disable format-on-save",
      bang = true,
    })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
      vim.notify("format-on-save enabled")
    end, {
      desc = "Enable format-on-save",
    })
  end,

  opts = {
    notify_on_error = true,
    notify_no_formatters = false,

    default_format_opts = {
      timeout_ms = 5000,
      lsp_format = "fallback",
    },

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end

      if vim.bo[bufnr].buftype ~= "" then
        return nil
      end

      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- Avoid formatting vendored/generated/dependency trees.
      if
        bufname:match("/node_modules/")
        or bufname:match("/%.venv/")
        or bufname:match("/venv/")
        or bufname:match("/__pycache__/")
        or bufname:match("/%.git/")
      then
        return nil
      end

      return {
        timeout_ms = 5000,
        lsp_format = "fallback",
      }
    end,

    formatters = {
      shfmt = {
        prepend_args = {
          "-i",
          "2", -- 2-space indent
          "-ci", -- indent switch case bodies
          "-bn", -- binary operators may start a line
          "-sr", -- space after redirect operators
          "-kp", -- keep column alignment padding
        },
      },
    },

    formatters_by_ft = {
      -- Python:
      -- Organize/sort imports, then format.
      -- Do NOT include ruff_fix here; unused imports should stay diagnostics/fixes.
      python = { "ruff_organize_imports", "ruff_format" },

      -- Shell:
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- Web:
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },

      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },

      -- Config/docs:
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      yml = { "prettier" },
      markdown = { "prettier" },
      ["markdown.mdx"] = { "prettier" },
    },
  },
}
