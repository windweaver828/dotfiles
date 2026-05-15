-- ~/.config/nvim/lua/plugins/mini.lua

local function ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")

  if ai_type == "i" then
    -- Skip first and last blank lines for `ig`
    local first_nonblank = vim.fn.nextnonblank(start_line)
    local last_nonblank = vim.fn.prevnonblank(end_line)

    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end

    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)

  return {
    from = { line = start_line, col = 1 },
    to = { line = end_line, col = to_col },
  }
end

local function register_mini_ai_which_key(opts)
  local ok, wk = pcall(require, "which-key")
  if not ok or not wk.add then
    return
  end

  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block / conditional / loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} block with ws" },
  }

  local mappings = vim.tbl_extend("force", {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})

  -- These are motions, not text-object prefixes.
  mappings.goto_left = nil
  mappings.goto_right = nil

  local spec = {
    mode = { "o", "x" },
  }

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")

    spec[#spec + 1] = {
      prefix,
      group = name,
    }

    for _, obj in ipairs(objects) do
      local desc = obj.desc

      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end

      spec[#spec + 1] = {
        prefix .. obj[1],
        desc = desc,
      }
    end
  end

  wk.add(spec, { notify = false })
end

return {
  -- Extends the a & i text objects.
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")

      return {
        n_lines = 500,
        custom_textobjects = {
          -- code block
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),

          -- function
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),

          -- class
          c = ai.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }),

          -- tags
          t = {
            "<([%p%w]-)%f[^<%w][^<>]->.-</%1>",
            "^<.->().*()</[^/]->$",
          },

          -- digits
          d = { "%f[%d]%d+" },

          -- word with case
          e = {
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },

          -- whole buffer / inside buffer
          g = ai_buffer,

          -- function call / usage
          u = ai.gen_spec.function_call(),

          -- function call without dot in function name
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      -- Register text object descriptions with which-key.
      -- Schedule it so which-key has a chance to finish loading on VeryLazy too.
      vim.schedule(function()
        register_mini_ai_which_key(opts)
      end)
    end,
  },

  -- Add, delete, replace, find, highlight surrounding.
  {
    "nvim-mini/mini.surround",
    keys = {
      { "gsa", desc = "Add surrounding", mode = { "n", "x" } },
      { "gsd", desc = "Delete surrounding" },
      { "gsf", desc = "Find right surrounding" },
      { "gsF", desc = "Find left surrounding" },
      { "gsh", desc = "Highlight surrounding" },
      { "gsr", desc = "Replace surrounding" },
      { "gsn", desc = "Update surrounding lines" },
    },
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
    end,
  },

  -- Auto pairs.
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = {
        insert = true,
        command = true,
        terminal = false,
      },
    },
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
}
