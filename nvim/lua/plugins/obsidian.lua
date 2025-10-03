return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    disable_frontmatter = true,
    legacy_commands = false,
    preferred_link_style = 'wiki',
    ui = {
      enable = false,
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },
    workspaces = {
      {
        name = 'Notes',
        path = '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes',
      },
    },
  },
}
