-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'Explore file in neo-tree', silent = true },
    { '<leader>e', ':Neotree reveal<CR>', desc = '[E]xplore file in neo-tree', silent = true },
  },
  filesystem = {
    use_git_status = true,
  },
  opts = {
    filesystem = {
      use_git_status = true,
      window = {
        mappings = {
          ['<C-x>'] = 'open_split',
          ['<C-v>'] = 'open_vsplit',
          ['<C-t>'] = 'open_tabnew',
          ['\\'] = 'close_window',
        },
      },
    },
    default_component_configs = {
      git_status = {
        symbols = {
          added = '✚',
          modified = '●',
          deleted = '✖',
          renamed = '➜',
          untracked = '★',
          ignored = '◌',
          unstaged = '✗',
          staged = '✓',
          conflict = '⚠',
        },
      },
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)

    -- Rosé Pine Moon colors for git
    vim.api.nvim_set_hl(0, 'NeoTreeGitAdded', { fg = '#31748f' }) -- foam
    vim.api.nvim_set_hl(0, 'NeoTreeGitModified', { fg = '#c4a7e7' }) -- iris
    vim.api.nvim_set_hl(0, 'NeoTreeGitDeleted', { fg = '#eb6f92' }) -- love
    vim.api.nvim_set_hl(0, 'NeoTreeGitRenamed', { fg = '#9ccfd8' }) -- pine
    vim.api.nvim_set_hl(0, 'NeoTreeGitUntracked', { fg = '#f6c177' }) -- gold
    vim.api.nvim_set_hl(0, 'NeoTreeGitIgnored', { fg = '#6e6a86' }) -- muted
    vim.api.nvim_set_hl(0, 'NeoTreeGitUnstaged', { fg = '#f6c177' }) -- gold
    vim.api.nvim_set_hl(0, 'NeoTreeGitStaged', { fg = '#31748f' }) -- foam
    vim.api.nvim_set_hl(0, 'NeoTreeGitConflict', { fg = '#eb6f92' }) -- love

    -- Minimalistic icon color for generic folder/file icons
    vim.api.nvim_set_hl(0, 'NeoTreeFileIcon', { fg = '#dfdef4' })
    vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = '#dfdef4' })

    -- 🧨 Patch all nvim-web-devicons definitions
    local devicons = require 'nvim-web-devicons'
    local icons = devicons.get_icons()

    -- Replace each icon's highlight with a single one (NeoTreeFileIcon)
    for name, icon in pairs(icons) do
      icon.color = nil
      icon.cterm_color = nil
      icon.name = 'NeoTreeFileIcon' -- use unified highlight group
    end

    -- Re-apply patched icons
    devicons.set_icon(icons)
  end,
}
