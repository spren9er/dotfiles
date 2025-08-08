return {
  'rose-pine/neovim',
  name = 'rose-pine',
  config = function()
    -- File to store the current theme state
    local state_file = vim.fn.stdpath('data') .. '/rose_pine_theme.txt'
    
    -- Function to read the saved theme
    local function read_theme()
      local file = io.open(state_file, 'r')
      if file then
        local theme = file:read('*all'):gsub('%s+', '') -- trim whitespace
        file:close()
        if theme == 'dawn' or theme == 'moon' or theme == 'main' then
          return theme
        end
      end
      return 'moon' -- default fallback
    end
    
    -- Function to save the current theme
    local function save_theme(theme)
      local file = io.open(state_file, 'w')
      if file then
        file:write(theme)
        file:close()
      end
    end
    
    -- Load the saved theme or use default
    local current_variant = read_theme()

    local function setup_rose_pine(variant)
      require('rose-pine').setup {
        variant = variant, -- auto, main, moon, or dawn
        dark_variant = 'moon', -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
          migrations = true, -- Handle deprecated options automatically
        },

        styles = {
          bold = true,
          italic = false,
          transparency = false,
        },

        groups = {
          border = 'muted',
          link = 'iris',
          panel = 'surface',

          error = 'love',
          hint = 'iris',
          info = 'foam',
          note = 'pine',
          todo = 'rose',
          warn = 'gold',

          git_add = 'foam',
          git_change = 'rose',
          git_delete = 'love',
          git_dirty = 'rose',
          git_ignore = 'muted',
          git_merge = 'iris',
          git_rename = 'pine',
          git_stage = 'iris',
          git_text = 'rose',
          git_untracked = 'subtle',

          h1 = 'iris',
          h2 = 'foam',
          h3 = 'rose',
          h4 = 'gold',
          h5 = 'pine',
          h6 = 'foam',
        },

        palette = {
          -- Override the builtin palette per variant
          -- moon = {
          --     base = '#18191a',
          --     overlay = '#363738',
          -- },
        },

        -- NOTE: Highlight groups are extended (merged) by default. Disable this
        -- per group via `inherit = false`
        highlight_groups = {
          -- Comment = { fg = "foam" },
          -- StatusLine = { fg = "love", bg = "love", blend = 15 },
          -- VertSplit = { fg = "muted", bg = "muted" },
          -- Visual = { fg = "base", bg = "text", inherit = false },
        },

        before_highlight = function(group, highlight, palette)
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
      }
    end

    -- Initial setup with moon variant
    setup_rose_pine(current_variant)
    vim.cmd 'colorscheme rose-pine'

    -- Create toggle function that properly updates the variant
    local function toggle_rose_pine()
      if current_variant == 'moon' then
        current_variant = 'dawn'
        save_theme(current_variant) -- Save to state file
        setup_rose_pine(current_variant)
        vim.cmd 'colorscheme rose-pine'
        vim.o.background = 'light'
      else
        current_variant = 'moon'
        save_theme(current_variant) -- Save to state file
        setup_rose_pine(current_variant)
        vim.cmd 'colorscheme rose-pine'
        vim.o.background = 'dark'
      end
    end

    -- Create user command for toggling
    vim.api.nvim_create_user_command('ToggleRosePineTheme', toggle_rose_pine, {
      desc = 'Toggle between rose-pine-moon and rose-pine-dawn',
    })
  end,
}
