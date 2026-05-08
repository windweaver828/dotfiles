-- ~/.config/nvim/lua/plugins/fzf.lua
--
-- fzf-lua picker setup.
--
-- This keeps fzf-lua focused and understandable:
--   - nice centered picker UI
--   - preview window controls
--   - mini.icons support
--   - your existing <leader>f mappings
--   - a few useful top-level/search/git mappings

local function fzf(command, opts)
  return function()
    local ok, fzf_lua = pcall(require, "fzf-lua")

    if not ok then
      vim.notify("fzf-lua is not installed", vim.log.levels.WARN)
      return
    end

    fzf_lua[command](opts or {})
  end
end

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",

    dependencies = {
      "nvim-mini/mini.icons",
    },

    opts = {
      -- Nice titles in picker windows.
      "default-title",

      -- Overall popup layout.
      winopts = {
        height = 0.85,
        width = 0.85,
        row = 0.5,
        col = 0.5,

        -- Preview layout:
        --   flex = automatically chooses vertical/horizontal based on space
        --   vertical = preview below when narrow
        --   horizontal = preview right when wide
        preview = {
          default = "bat",
          layout = "flex",
          vertical = "down:45%",
          horizontal = "right:55%",
        },
      },

      -- File picker behavior.
      files = {
        prompt = "Files> ",
        git_icons = true,
        file_icons = true,
        color_icons = true,

        -- Include hidden files, follow symlinks, skip .git.
        -- Requires fd/fdfind for best behavior.
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      },

      -- Grep behavior.
      grep = {
        prompt = "Grep> ",
        git_icons = true,
        file_icons = true,
        color_icons = true,

        -- Search hidden files, skip .git.
        -- Requires ripgrep.
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git'",
      },

      -- Buffer picker behavior.
      buffers = {
        prompt = "Buffers> ",
        sort_mru = true,
        sort_lastused = true,
      },

      oldfiles = {
        prompt = "Recent> ",
      },

      -- Controls while inside fzf-lua.
      keymap = {
        builtin = {
          -- fzf-lua wrapper/window controls.
          ["<F1>"] = "toggle-help",
          ["<F2>"] = "toggle-fullscreen",
          ["<F3>"] = "toggle-preview-wrap",
          ["<F4>"] = "toggle-preview",

          -- Preview scrolling.
          ["<C-f>"] = "preview-page-down",
          ["<C-b>"] = "preview-page-up",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },

        fzf = {
          -- fzf prompt controls.
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-u"] = "half-page-up",
          ["ctrl-d"] = "half-page-down",
          ["ctrl-f"] = "preview-page-down",
          ["ctrl-b"] = "preview-page-up",
        },
      },
    },

    keys = {
      ----------------------------------------------------------------------
      -- High-value top-level picker keys
      ----------------------------------------------------------------------

      -- These are LazyVim-ish and very useful.
      { "<leader>,", fzf("buffers", { sort_mru = true, sort_lastused = true }), desc = "Switch buffer" },
      { "<leader>:", fzf("command_history"), desc = "Command history" },

      ----------------------------------------------------------------------
      -- Your existing <leader>f mappings
      ----------------------------------------------------------------------

      { "<leader>ff", fzf("files"), desc = "Find files" },
      { "<leader>fg", fzf("git_files"), desc = "Find git files" },
      { "<leader>fr", fzf("oldfiles"), desc = "Recent files" },
      { "<leader>fo", fzf("oldfiles"), desc = "Recent files" },

      {
        "<leader>fb",
        fzf("buffers", { sort_mru = true, sort_lastused = true }),
        desc = "Buffers",
      },

      { "<leader>fB", fzf("builtin"), desc = "Fzf Built-in Commands" },

      { "<leader>f/", fzf("live_grep"), desc = "Grep files" },
      { "<leader>fs", fzf("live_grep"), desc = "Grep files" },

      { "<leader>fw", fzf("grep_cword"), desc = "Grep word" },
      { "<leader>fw", fzf("grep_visual"), mode = "x", desc = "Grep selection" },

      {
        "<leader>fc",
        fzf("files", { cwd = vim.fn.stdpath("config") }),
        desc = "Find config files",
      },

      { "<leader>fC", fzf("command_history"), desc = "Command history" },
      { "<leader>fh", fzf("help_tags"), desc = "Help tags" },
      { "<leader>fk", fzf("keymaps"), desc = "Keymaps" },
      { "<leader>fR", fzf("resume"), desc = "Resume fzf" },

      ----------------------------------------------------------------------
      -- Extra search group
      ----------------------------------------------------------------------

      { "<leader>sb", fzf("lines"), desc = "Buffer lines" },
      { "<leader>sB", fzf("blines"), desc = "Current buffer lines" },
      { "<leader>sd", fzf("diagnostics_workspace"), desc = "Workspace diagnostics" },
      { "<leader>sD", fzf("diagnostics_document"), desc = "Buffer diagnostics" },
      { "<leader>sh", fzf("help_tags"), desc = "Help pages" },
      { "<leader>sk", fzf("keymaps"), desc = "Keymaps" },
      { "<leader>sm", fzf("marks"), desc = "Marks" },
      { "<leader>sj", fzf("jumps"), desc = "Jumps" },
      { "<leader>sq", fzf("quickfix"), desc = "Quickfix" },
      { "<leader>sl", fzf("loclist"), desc = "Location list" },
      { "<leader>sR", fzf("resume"), desc = "Resume fzf" },

      ----------------------------------------------------------------------
      -- Extra git group
      ----------------------------------------------------------------------

      { "<leader>gs", fzf("git_status"), desc = "Git status" },
      { "<leader>gc", fzf("git_commits"), desc = "Git commits" },
      { "<leader>gb", fzf("git_branches"), desc = "Git branches" },
      { "<leader>gS", fzf("git_stash"), desc = "Git stash" },
    },

    config = function(_, opts)
      -- Use mini.icons as the icon provider when installed.
      -- fzf-lua can use nvim-web-devicons and can also fall back to mini.icons;
      -- this shim makes plugins expecting devicons work through mini.icons.
      local ok_icons, mini_icons = pcall(require, "mini.icons")
      if ok_icons then
        mini_icons.mock_nvim_web_devicons()
      end

      require("fzf-lua").setup(opts)
    end,
  },
}
