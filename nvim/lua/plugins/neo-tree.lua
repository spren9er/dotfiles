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
    { '\\', ':Neotree toggle<CR>', desc = 'Toggle neo-tree', silent = true },
    { '<leader>e', ':Neotree reveal<CR>', desc = '[E]xplore file in neo-tree', silent = true },
  },
  opts = {
    filesystem = {
      commands = {
        delete = function(state)
          local node = state.tree:get_node()
          if node.type == 'message' then
            return
          end
          vim.fn.delete(node.path, 'rf')
          require('neo-tree.sources.manager').refresh(state.name)
        end,
      },
      confirm = {
        delete = false,
      },
      use_git_status = true,
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ['<C-x>'] = 'open_split',
          ['<C-v>'] = 'open_vsplit',
          ['<C-t>'] = 'open_tabnew',
          ['\\'] = 'close_window',
          -- Disable space key completely to allow which-key
          ['<space>'] = 'none',
          -- Disable double-click mouse event
          ['<2-LeftMouse>'] = 'none',
        },
      },
    },
    default_component_configs = {
      git_status = {
        symbols = {
          added = 'A',
          modified = 'M',
          deleted = 'D',
          renamed = 'R',
          untracked = 'U',
          ignored = 'I',
          unstaged = '*',
          staged = 'S',
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
