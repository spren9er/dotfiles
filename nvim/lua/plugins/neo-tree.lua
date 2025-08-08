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
        open_in_finder = function(state)
          local node = state.tree:get_node()
          if node.type == 'message' then
            return
          end
          vim.fn.jobstart({ 'open', '-R', node.path }, { detach = true })
        end,
      },
      use_git_status = true,
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          -- File operations
          ['a'] = { 'add', desc = 'Add file' },
          ['A'] = { 'add_directory', desc = 'Add directory' },
          ['d'] = { 'delete', desc = 'Delete file/directory' },
          ['r'] = { 'rename', desc = 'Rename file/directory' },
          ['b'] = { 'rename_basename', desc = 'Rename basename only' },
          ['c'] = { 'copy', desc = 'Copy file/directory' },
          ['m'] = { 'move', desc = 'Move file/directory' },
          ['x'] = { 'cut_to_clipboard', desc = 'Cut to clipboard' },
          ['y'] = { 'copy_to_clipboard', desc = 'Copy to clipboard' },
          ['p'] = { 'paste_from_clipboard', desc = 'Paste from clipboard' },
          ['<C-r>'] = { 'open_in_finder', desc = 'Reveal in Finder' },

          -- Navigation and view
          ['<cr>'] = { 'open', desc = 'Open file/directory' },
          ['<C-x>'] = { 'open_split', desc = 'Open in horizontal split' },
          ['<C-v>'] = { 'open_vsplit', desc = 'Open in vertical split' },
          ['<C-t>'] = { 'open_tabnew', desc = 'Open in new tab' },
          ['S'] = { 'open_split', desc = 'Open in horizontal split' },
          ['s'] = { 'open_vsplit', desc = 'Open in vertical split' },
          ['t'] = { 'open_tabnew', desc = 'Open in new tab' },
          ['w'] = { 'open_with_window_picker', desc = 'Open with window picker' },

          -- Tree operations
          ['C'] = { 'close_node', desc = 'Close node' },
          ['z'] = { 'close_all_nodes', desc = 'Close all nodes' },
          ['Z'] = { 'expand_all_nodes', desc = 'Expand all nodes' },
          ['R'] = { 'refresh', desc = 'Refresh tree' },

          -- View toggles
          ['H'] = { 'toggle_hidden', desc = 'Toggle hidden files' },
          ['P'] = { 'toggle_preview', desc = 'Toggle preview' },
          ['l'] = { 'focus_preview', desc = 'Focus preview window' },
          ['e'] = { 'toggle_auto_expand_width', desc = 'Toggle auto expand width' },

          -- Information and help
          ['i'] = { 'show_file_details', desc = 'Show file details' },
          ['?'] = { 'show_help', desc = 'Show help' },
          ['o'] = { 'show_help', desc = 'Show order options' },

          -- Cancel/escape operations
          ['<esc>'] = { 'cancel', desc = 'Cancel operation' },

          -- Filtering and search
          ['f'] = { 'filter_on_submit', desc = 'Filter on submit' },
          ['<c-x>'] = { 'clear_filter', desc = 'Clear filter' },
          ['D'] = { 'fuzzy_finder_directory', desc = 'Fuzzy finder directory' },
          ['#'] = { 'fuzzy_sorter', desc = 'Fuzzy sorter' },

          -- Navigation and sources
          ['>'] = { 'next_source', desc = 'Next source' },
          ['<'] = { 'prev_source', desc = 'Previous source' },
          ['<bs>'] = { 'navigate_up', desc = 'Navigate up' },

          -- Preview scrolling
          ['<c-b>'] = { 'scroll_preview', desc = 'Scroll preview up' },
          ['<c-f>'] = { 'scroll_preview', desc = 'Scroll preview down' },

          -- Sorting options (accessible via 'o' prefix)
          ['oc'] = { 'order_by_created', desc = 'Order by created time' },
          ['od'] = { 'order_by_diagnostics', desc = 'Order by diagnostics' },
          ['og'] = { 'order_by_git_status', desc = 'Order by git status' },
          ['om'] = { 'order_by_modified', desc = 'Order by modified time' },
          ['on'] = { 'order_by_name', desc = 'Order by name' },
          ['os'] = { 'order_by_size', desc = 'Order by size' },
          ['ot'] = { 'order_by_type', desc = 'Order by type' },

          -- Window management
          ['q'] = { 'close_window', desc = 'Close neo-tree window' },
          ['\\'] = { 'close_window', desc = 'Close neo-tree window' },

          -- Disable keys
          ['<space>'] = 'none',
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
    
    -- 🧨 Patch all nvim-web-devicons definitions to use unified colors
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
