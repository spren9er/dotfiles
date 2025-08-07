-- [[ Load plugins via lazy.vim ]]
require('lazy').setup({
  spec = {
    { import = 'plugins' },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      lazy = '💤 ',
      plugin = '🔌',
      require = '🌙',
      runtime = '💻',
      source = '📄',
      start = '🚀',
      task = '📌',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
