return {
  -- Easy tmux + vim navigation (Ctrl hjkl)
  { "christoomey/vim-tmux-navigator" },
  -- Repeat some tpope commands
  { "tpope/vim-repeat" },
  -- Ctrl + A/X to increment dates and times etc..
  { "tpope/vim-speeddating" },
  -- Add unix commands for Remove, Delete, Move, Copy, Chmod, Mkdir, SudoWrite, SudoEdit
  { "tpope/vim-eunuch" },
  {
  "nvim-mini/mini.pairs",
  event = "VeryLazy",
  opts = {
    modes = { insert = true, command = true, terminal = false },
    -- skip autopair when next character is one of these
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    -- skip autopair when the cursor is inside these treesitter nodes
    skip_ts = { "string" },
    -- skip autopair when next character is closing pair
    -- and there are more closing pairs than opening pairs
    skip_unbalanced = true,
    -- better deal with markdown code blocks
    markdown = true,
  },
  config = function(_, opts)
    LazyVim.mini.pairs(opts)
  end,
}
}

