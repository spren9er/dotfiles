-- Warp theme integration for Neovim
-- This module reads Warp's theme YAML files and applies them to Neovim
--
-- Features:
-- - Automatic theme detection from Warp's preferences
-- - Support for both custom and built-in Warp themes
-- - Real-time theme synchronization via file watching
-- - Theme caching for faster startup
-- - Comprehensive highlight group coverage
-- - Neo-tree integration
--
-- Usage:
--   local warp_theme = require('custom.warp-theme')
--   warp_theme.load_cached_theme()  -- Load cached theme on startup
--   warp_theme.start_watcher()      -- Start automatic sync
--   warp_theme.sync()               -- Manual sync

local M = {}

-- Constants
local WARP_THEMES_PATH = vim.fn.expand '~/.warp/themes'
local WARP_PREFS_FILE = vim.fn.expand '~/Library/Preferences/dev.warp.Warp-Stable.plist'
local THEME_CACHE_FILE = vim.fn.expand '~/.config/nvim/lua/custom/.warp-theme-cache.lua'

-- Color adjustment factors for generating surface and overlay colors from base theme background
-- These values (0-255) are added to dark themes or subtracted from light themes to create visual hierarchy
-- surface: subtle background variations (e.g. for floating windows)
-- overlay: more prominent background variations (e.g. for selections, active elements)
local COLOR_ADJUSTMENT_FACTORS = { surface = 15, overlay = 30 }

-- State tracking
local last_applied_theme = nil
local file_watcher = nil

-- Safe helper function for executing shell commands
local function safe_popen(command)
  local handle = io.popen(command)
  if not handle then
    vim.notify('Failed to execute: ' .. command, vim.log.levels.WARN)
    return nil
  end
  return handle
end

-- Color utility functions
local color_utils = {}

-- Calculate color luminance using standard formula
function color_utils.calculate_luminance(color)
  if not color or type(color) ~= 'string' or not color:match '^#%x%x%x%x%x%x$' then
    return 0.5 -- fallback to middle luminance
  end

  local r = tonumber(color:sub(2, 3), 16) or 0
  local g = tonumber(color:sub(4, 5), 16) or 0
  local b = tonumber(color:sub(6, 7), 16) or 0
  return (0.299 * r + 0.587 * g + 0.114 * b) / 255
end

-- Adjust color brightness by a given factor
function color_utils.adjust_brightness(color, factor, is_dark_theme)
  if not color or type(color) ~= 'string' or not color:match '^#%x%x%x%x%x%x$' then
    return color -- return original if invalid
  end

  local r = tonumber(color:sub(2, 3), 16) or 0
  local g = tonumber(color:sub(4, 5), 16) or 0
  local b = tonumber(color:sub(6, 7), 16) or 0

  if is_dark_theme then
    -- For dark themes, lighten the color
    r = math.min(255, r + factor)
    g = math.min(255, g + factor)
    b = math.min(255, b + factor)
  else
    -- For light themes, darken the color
    r = math.max(0, r - factor)
    g = math.max(0, g - factor)
    b = math.max(0, b - factor)
  end

  return string.format('#%02x%02x%02x', r, g, b)
end

-- Safe file removal using Lua operations instead of shell commands
local function safe_remove_file(filepath)
  local success, err = os.remove(filepath)
  if not success and err then
    -- Only log if file actually existed (ignore "file not found" errors)
    local file = io.open(filepath, 'r')
    if file then
      file:close()
      vim.notify('Failed to remove temporary file: ' .. filepath, vim.log.levels.WARN)
    end
  end
end

-- Helper function to parse color from different quote formats
local function parse_color(content, color_name)
  return content:match(color_name .. ":%s*'(#%x%x%x%x%x%x)'")
    or content:match(color_name .. ':%s*"(#%x%x%x%x%x%x)"')
    or content:match(color_name .. ':%s*(#%x%x%x%x%x%x)')
end

-- Helper function to parse terminal colors section
local function parse_color_section(content, section_name)
  local colors = {}
  local section_pattern = section_name .. ':%s*\n(.-)\n%s*%w+:'
  local section = content:match(section_pattern)
  if not section then
    return colors
  end

  local color_names = { 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white' }
  for _, color in ipairs(color_names) do
    colors[color] = parse_color(section, color)
  end

  return colors
end

-- Helper function to parse background color (handles both simple and gradient formats)
local function parse_background_color(content)
  -- Try simple format first
  local simple_bg = parse_color(content, 'background')
  if simple_bg then
    return simple_bg
  end

  -- Handle gradient background (top/bottom format)
  local bg_top = content:match 'background:%s*\n%s*top:%s*[\'"]?(#%x%x%x%x%x%x)'
  local bg_bottom = content:match 'bottom:%s*[\'"]?(#%x%x%x%x%x%x)'
  -- Use top color as primary background, or bottom if top missing
  return bg_top or bg_bottom
end

-- Helper function to parse background image configuration
local function parse_background_image(content)
  local bg_image, opacity

  -- Try nested structure format first
  local bg_image_section = content:match 'background_image:%s*\n(.-)\ndetails:'
  if bg_image_section then
    bg_image = bg_image_section:match 'path:%s*[\'"]?([^\'"\n]+)' or bg_image_section:match 'path:%s*([^%s\n]+)'
    local opacity_str = bg_image_section:match 'opacity:%s*([%d%.]+)'
    opacity = opacity_str and tonumber(opacity_str)
  else
    -- Fallback to simple format
    bg_image = content:match 'background_image:%s*[\'"]([^\'"]+)[\'"]' or content:match 'background_image:%s*([^%s\n]+)'
    local opacity_str = content:match 'opacity:%s*([%d%.]+)'
    opacity = opacity_str and tonumber(opacity_str)
  end

  return bg_image, opacity
end

-- Helper function to parse terminal colors section
local function parse_terminal_colors(content)
  local terminal_colors = { bright = {}, normal = {} }
  local color_names = { 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white' }

  -- Extract bright colors
  local bright_section = content:match 'bright:%s*\n(.-)\n%s*normal:'
  if bright_section then
    for _, color in ipairs(color_names) do
      terminal_colors.bright[color] = parse_color(bright_section, color)
    end
  end

  -- Extract normal colors
  local normal_section = content:match 'normal:%s*\n(.+)'
  if normal_section then
    for _, color in ipairs(color_names) do
      terminal_colors.normal[color] = parse_color(normal_section, color)
    end
  end

  return terminal_colors
end

-- Function to parse a YAML-like structure (simple parsing for Warp themes)
local function parse_warp_theme(filepath)
  local file = io.open(filepath, 'r')
  if not file then
    return nil
  end

  local content = file:read '*all'
  file:close()

  local theme = {}

  -- Parse basic properties
  theme.name = content:match 'name:%s*(.-)%s*\n' or content:match "name:%s*'(.-)'" or content:match 'name:%s*"(.-)"'
  theme.accent = parse_color(content, 'accent')
  theme.foreground = parse_color(content, 'foreground')
  theme.details = content:match 'details:%s*(%w+)'

  -- Parse background (handles both simple and gradient formats)
  theme.background = parse_background_color(content)

  -- Parse background image and opacity
  theme.background_image, theme.opacity = parse_background_image(content)

  -- Parse terminal colors
  theme.terminal_colors = parse_terminal_colors(content)

  return theme
end

-- Function to find available Warp themes
function M.get_available_themes()
  local themes = {}
  local handle = safe_popen('find "' .. WARP_THEMES_PATH .. '" -name "*.yaml" 2>/dev/null')
  if not handle then
    vim.notify('Failed to search for Warp themes in: ' .. WARP_THEMES_PATH, vim.log.levels.WARN)
    return themes
  end

  for file in handle:lines() do
    local theme = parse_warp_theme(file)
    if theme and theme.name then
      themes[theme.name] = {
        filepath = file,
        theme = theme,
      }
    end
  end
  handle:close()
  return themes
end

-- State for tracking theme changes
local last_theme_hash = nil

-- Function to serialize theme to cache file
local function save_theme_to_cache(theme_info)
  if not theme_info then
    return false
  end

  local cache_content = string.format('return %s', vim.inspect(theme_info, { indent = '  ' }))

  local file = io.open(THEME_CACHE_FILE, 'w')
  if file then
    file:write(cache_content)
    file:close()
    return true
  end
  return false
end

-- Function to load theme from cache file
local function load_theme_from_cache()
  if vim.fn.filereadable(THEME_CACHE_FILE) == 1 then
    local ok, theme_info = pcall(dofile, THEME_CACHE_FILE)
    if ok and theme_info and theme_info.theme then
      return theme_info
    end
  end
  return nil
end

-- Function to extract theme info from the Warp preferences
local function extract_warp_theme_info()
  local handle = safe_popen 'plutil -p ~/Library/Preferences/dev.warp.Warp-Stable.plist 2>/dev/null | grep "Theme" | grep -v "Referral"'
  if not handle then
    return nil
  end

  local result = handle:read '*a'
  handle:close()

  if not result or result == '' then
    return nil
  end

  -- Check for custom theme format: "Theme" => "{"Custom":{"name":"Theme Name","path":"/path"}}"
  local custom_name, custom_path = result:match '"Custom".-"name":"([^"]+)".-"path":"([^"]+)"'
  if custom_name and custom_path then
    return {
      name = custom_name,
      path = custom_path,
      type = 'custom',
    }
  end

  -- Check for built-in theme format with double quotes: "Theme" => ""ThemeName""
  local builtin_name = result:match '"Theme" => ""([^"]+)""'
  if builtin_name then
    return {
      name = builtin_name,
      type = 'builtin',
    }
  end

  -- Fallback: try simpler pattern for single quotes
  builtin_name = result:match '"Theme" => "([^"]+)"'
  if builtin_name then
    return {
      name = builtin_name,
      type = 'builtin',
    }
  end

  return nil
end

-- Function to get Warp theme fingerprint/hash for change detection
local function get_warp_theme_hash()
  local handle = safe_popen "plutil -p ~/Library/Preferences/dev.warp.Warp-Stable.plist 2>/dev/null | grep '\"Theme\"' | grep '=>'"
  if not handle then
    return nil
  end

  local result = handle:read '*a'
  handle:close()

  if not result or result == '' then
    return nil
  end

  -- Clean up the result and use just the Theme line as hash
  local clean_result = result:gsub('\n', ''):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')

  return clean_result
end

-- Function to detect if Warp theme has changed
local function has_warp_theme_changed()
  local current_hash = get_warp_theme_hash()

  if not current_hash then
    return false -- Can't detect, assume no change
  end

  -- Check if this is different from last known state
  if last_theme_hash ~= current_hash then
    last_theme_hash = current_hash
    return true
  end

  -- Additional check: compare with cached theme name if available
  local cached_theme = load_theme_from_cache()
  if cached_theme then
    local current_theme_info = extract_warp_theme_info()
    if current_theme_info and current_theme_info.name ~= cached_theme.name then
      return true
    end
  end

  return false
end

-- Function to fetch built-in Warp theme from GitHub
local function fetch_builtin_theme(theme_name)
  local github_name

  -- Handle special cases for basic themes
  if theme_name == 'Dark' then
    github_name = 'warp_dark'
  elseif theme_name == 'Light' then
    github_name = 'warp_light'
  else
    -- Convert theme name to GitHub filename format (snake_case)
    -- Examples: "Solarized Light" -> "solarized_light", "GruvboxLight" -> "gruvbox_light"
    github_name = theme_name
      :gsub('([a-z])([A-Z])', '%1_%2') -- Insert underscore before capitals (camelCase -> snake_case)
      :gsub('%s+', '_') -- Replace spaces with underscores
      :lower() -- Convert to lowercase
      :gsub('[^%w_]', '') -- Remove non-alphanumeric characters except underscores
  end

  local github_url = 'https://raw.githubusercontent.com/warpdotdev/themes/main/warp_bundled/' .. github_name .. '.yaml'

  -- Try to download the theme file
  local temp_file = '/tmp/warp_theme_' .. github_name .. '.yaml'
  local cmd = string.format('curl -s -o "%s" "%s" 2>/dev/null && [ -s "%s" ]', temp_file, github_url, temp_file)
  local success = os.execute(cmd) == 0

  if success then
    local theme = parse_warp_theme(temp_file)
    -- Clean up temp file
    os.execute('rm -f "' .. temp_file .. '"')
    return theme
  else
    -- Clean up temp file if it exists
    os.execute('rm -f "' .. temp_file .. '"')
    return nil
  end
end

-- Function to find custom theme by name in local directory
local function find_custom_theme_by_name(theme_name)
  -- Get all YAML files in the themes directory
  local handle = safe_popen('find "' .. WARP_THEMES_PATH .. '" -name "*.yaml" 2>/dev/null')
  if not handle then
    return nil
  end

  local files = {}
  for file_path in handle:lines() do
    table.insert(files, file_path)
  end
  handle:close()

  -- Sort files to ensure consistent ordering (longer paths first for more specific matches)
  table.sort(files, function(a, b)
    return #a > #b
  end)

  for _, file_path in ipairs(files) do
    local theme = parse_warp_theme(file_path)
    if theme and theme.name then
      -- Exact name match
      if theme.name == theme_name then
        return theme
      end
    end
  end

  return nil
end

-- Function to get theme colors from appropriate source
local function get_theme_colors(theme_info)
  if not theme_info then
    return nil
  end

  local theme_name = theme_info.name

  -- For custom themes, use the path if available, otherwise search by name
  if theme_info.type == 'custom' then
    if theme_info.path and vim.fn.filereadable(theme_info.path) == 1 then
      -- Use the direct path provided by Warp
      return parse_warp_theme(theme_info.path)
    else
      -- Fallback: search by name in all local theme files
      return find_custom_theme_by_name(theme_name)
    end
  end

  -- For built-in themes, try to fetch from GitHub
  if theme_info.type == 'builtin' then
    local builtin_theme = fetch_builtin_theme(theme_name)
    if builtin_theme then
      return builtin_theme
    end
  end

  return nil
end

-- Simple function to detect if we should use dark theme (fallback method)
local function should_use_dark_theme()
  -- Method 1: Check macOS system appearance
  local handle = io.popen 'defaults read -g AppleInterfaceStyle 2>/dev/null'
  local is_dark = false

  if handle then
    local result = handle:read '*a'
    handle:close()
    is_dark = result:match 'Dark' ~= nil
  end

  -- Method 2: Check COLORFGBG environment variable as backup
  if not is_dark then
    local colorfgbg = os.getenv 'COLORFGBG'
    if colorfgbg then
      local bg = colorfgbg:match ';(%d+)$'
      if bg then
        local bg_num = tonumber(bg)
        -- Background colors 0-7 are typically dark, 8-15 are bright
        if bg_num and bg_num < 8 then
          is_dark = true
        end
      end
    end
  end

  return is_dark
end

-- Function to read current theme colors when change is detected
local function read_current_terminal_colors()
  -- Step 1: Get theme info from Warp preferences
  local theme_info = extract_warp_theme_info()
  if not theme_info then
    return nil
  end

  local theme_name = theme_info.name

  -- Step 2: Get actual theme colors from appropriate source
  local theme = get_theme_colors(theme_info)

  if theme then
    if theme.background and theme.foreground and theme.terminal_colors and theme.terminal_colors.normal and theme.terminal_colors.bright then
      -- Ensure theme has a name (use detected name as fallback)
      if not theme.name then
        theme.name = theme_name
      end

      return {
        name = theme_name,
        type = theme_info.type,
        theme = theme,
      }
    end
  end

  -- If we get here, theme loading failed
  if theme_info.type == 'custom' then
    vim.notify(
      "Error: Custom theme '" .. theme_name .. "' not found at path: " .. (theme_info.path or 'unknown') .. '. Keeping current theme.',
      vim.log.levels.ERROR
    )
  elseif theme_info.type == 'builtin' then
    vim.notify("Error: Built-in theme '" .. theme_name .. "' not available. Keeping current theme.", vim.log.levels.ERROR)
  end

  -- Return nil to indicate theme loading failed and current theme should be kept
  return nil
end

-- Function to load cached theme immediately (for startup)
function M.load_cached_theme()
  local cached_theme = load_theme_from_cache()
  if cached_theme then
    M.apply_theme(cached_theme)
    return true
  end
  return false
end

-- Function to detect current theme
function M.detect_current_theme()
  -- First check if we have a theme change
  if has_warp_theme_changed() then
    -- Theme changed, read current colors
    return read_current_terminal_colors()
  end

  -- No change detected, but we might need a theme for first-time setup
  if not last_applied_theme then
    return read_current_terminal_colors()
  end

  -- Theme hasn't changed and we have an applied theme, return nil to skip sync
  return nil
end

-- Function to apply a Warp theme to Neovim
function M.apply_theme(theme_info)
  if not theme_info or not theme_info.theme then
    return
  end

  local theme = theme_info.theme

  -- Track the applied theme
  last_applied_theme = theme.name

  local colors = theme.terminal_colors

  -- Always use transparent background - let Warp handle the window background
  local background_color = 'NONE'

  -- Clear existing colorscheme
  vim.cmd 'highlight clear'
  vim.cmd 'syntax reset'

  -- Set colorscheme name
  vim.g.colors_name = theme.name:lower():gsub('[^%w_]', '_')

  -- Set background based on theme details or original theme background color luminance
  local is_dark_theme = false
  if theme.details == 'darker' then
    is_dark_theme = true
  elseif theme.details == 'lighter' then
    is_dark_theme = false
  else
    -- For 'custom' or other values, determine from original theme background color luminance
    if theme.background then
      local luminance = color_utils.calculate_luminance(theme.background)
      is_dark_theme = luminance < 0.5
    else
      -- Fallback: check if normal colors suggest dark theme
      local fallback_color = colors.normal.black or '#000000'
      local bg_luminance = color_utils.calculate_luminance(fallback_color)
      is_dark_theme = bg_luminance < 0.5
    end
  end

  vim.opt.background = is_dark_theme and 'dark' or 'light'

  -- Calculate some helper colors dynamically
  local muted = colors.bright.black or (is_dark_theme and '#6c7086' or '#9ca0b0')

  -- Ensure we have essential colors filled in for calculation
  if not colors.bright.black then
    colors.bright.black = is_dark_theme and '#6c7086' or '#9ca0b0'
  end
  if not colors.bright.white then
    colors.bright.white = is_dark_theme and '#a6adc8' or '#4c4f69'
  end

  -- Generate surface and overlay colors based on the original theme background
  local function lighten_darken_color(factor)
    -- Always use the original theme background as base for surface/overlay colors
    local base_color = theme.background

    -- If still no color, use terminal colors or fallbacks that match the theme
    if not base_color then
      if is_dark_theme then
        -- Use normal black as base for dark themes, or muted color
        base_color = colors.normal.black or '#1e1e2e'
      else
        -- Use normal white as base for light themes
        base_color = colors.normal.white or '#eff1f5'
      end
    end

    local r = tonumber(base_color:sub(2, 3), 16) or 0
    local g = tonumber(base_color:sub(4, 5), 16) or 0
    local b = tonumber(base_color:sub(6, 7), 16) or 0

    if is_dark_theme then
      -- For dark themes, lighten the color
      r = math.min(255, r + factor)
      g = math.min(255, g + factor)
      b = math.min(255, b + factor)
    else
      -- For light themes, darken the color
      r = math.max(0, r - factor)
      g = math.max(0, g - factor)
      b = math.max(0, b - factor)
    end

    return string.format('#%02x%02x%02x', r, g, b)
  end

  local surface = lighten_darken_color(COLOR_ADJUSTMENT_FACTORS.surface)
  local overlay = lighten_darken_color(COLOR_ADJUSTMENT_FACTORS.overlay)

  -- Core highlight groups
  vim.api.nvim_set_hl(0, 'Normal', { fg = theme.foreground, bg = background_color })
  vim.api.nvim_set_hl(0, 'NormalFloat', { fg = theme.foreground, bg = surface })
  vim.api.nvim_set_hl(0, 'NormalNC', { fg = theme.foreground, bg = background_color })

  -- Visual selection
  vim.api.nvim_set_hl(0, 'Visual', { bg = overlay })
  vim.api.nvim_set_hl(0, 'VisualNOS', { bg = overlay })

  -- Cursor
  vim.api.nvim_set_hl(0, 'Cursor', { fg = theme.background, bg = theme.foreground })
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = surface })
  vim.api.nvim_set_hl(0, 'CursorColumn', { bg = surface })

  -- Line numbers
  vim.api.nvim_set_hl(0, 'LineNr', { fg = muted })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = theme.accent, bold = true })
  vim.api.nvim_set_hl(0, 'SignColumn', { bg = background_color })
  vim.api.nvim_set_hl(0, 'FoldColumn', { fg = muted, bg = background_color })

  -- Folds
  vim.api.nvim_set_hl(0, 'Folded', { fg = colors.normal.cyan, bg = surface })

  -- Search
  vim.api.nvim_set_hl(0, 'Search', { fg = theme.background, bg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'IncSearch', { fg = theme.background, bg = theme.accent })
  vim.api.nvim_set_hl(0, 'Substitute', { fg = theme.background, bg = colors.normal.red })

  -- Messages
  vim.api.nvim_set_hl(0, 'ErrorMsg', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'WarningMsg', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'ModeMsg', { fg = theme.foreground })
  vim.api.nvim_set_hl(0, 'MoreMsg', { fg = colors.normal.cyan })

  -- Status line
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = theme.foreground, bg = overlay })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = muted, bg = surface })

  -- Tab line
  vim.api.nvim_set_hl(0, 'TabLine', { fg = muted, bg = surface })
  vim.api.nvim_set_hl(0, 'TabLineFill', { bg = surface })
  vim.api.nvim_set_hl(0, 'TabLineSel', { fg = theme.foreground, bg = overlay, bold = true })

  -- Windows
  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = overlay })
  vim.api.nvim_set_hl(0, 'VertSplit', { fg = overlay })

  -- Popup menu
  vim.api.nvim_set_hl(0, 'Pmenu', { fg = theme.foreground, bg = surface })
  vim.api.nvim_set_hl(0, 'PmenuSel', { fg = theme.foreground, bg = overlay, bold = true })
  vim.api.nvim_set_hl(0, 'PmenuSbar', { bg = overlay })
  vim.api.nvim_set_hl(0, 'PmenuThumb', { bg = muted })

  -- Wild menu
  vim.api.nvim_set_hl(0, 'WildMenu', { fg = theme.background, bg = colors.normal.yellow })

  -- Syntax highlighting
  vim.api.nvim_set_hl(0, 'Comment', { fg = muted, italic = true })
  vim.api.nvim_set_hl(0, 'Constant', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'String', { fg = colors.normal.green })
  vim.api.nvim_set_hl(0, 'Character', { fg = colors.normal.green })
  vim.api.nvim_set_hl(0, 'Number', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Boolean', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Float', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Identifier', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'Function', { fg = colors.normal.blue })
  vim.api.nvim_set_hl(0, 'Statement', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'Conditional', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'Repeat', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'Label', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'Operator', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'Keyword', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'Exception', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'PreProc', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Include', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Define', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Macro', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'PreCondit', { fg = colors.normal.magenta })
  vim.api.nvim_set_hl(0, 'Type', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'StorageClass', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'Structure', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'Typedef', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'Special', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'SpecialChar', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'Tag', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'Delimiter', { fg = theme.foreground })
  vim.api.nvim_set_hl(0, 'SpecialComment', { fg = muted })
  vim.api.nvim_set_hl(0, 'Debug', { fg = colors.normal.red })

  -- Errors and diagnostics
  vim.api.nvim_set_hl(0, 'Error', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'Todo', { fg = colors.normal.yellow, bold = true })

  -- Diff
  vim.api.nvim_set_hl(0, 'DiffAdd', { fg = colors.normal.green, bg = surface })
  vim.api.nvim_set_hl(0, 'DiffChange', { fg = colors.normal.yellow, bg = surface })
  vim.api.nvim_set_hl(0, 'DiffDelete', { fg = colors.normal.red, bg = surface })
  vim.api.nvim_set_hl(0, 'DiffText', { fg = colors.normal.yellow, bg = overlay, bold = true })

  -- Neo-tree comprehensive theming

  -- Main UI elements
  vim.api.nvim_set_hl(0, 'NeoTreeNormal', { fg = theme.foreground, bg = background_color })
  vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { fg = theme.foreground, bg = background_color })
  vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { fg = background_color, bg = background_color })
  vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { fg = overlay, bg = background_color })
  vim.api.nvim_set_hl(0, 'NeoTreeStatusLine', { fg = theme.foreground, bg = overlay })
  vim.api.nvim_set_hl(0, 'NeoTreeStatusLineNC', { fg = muted, bg = surface })

  -- Tree structure
  vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { fg = muted })
  vim.api.nvim_set_hl(0, 'NeoTreeExpander', { fg = muted })
  vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = theme.accent, bold = true })
  vim.api.nvim_set_hl(0, 'NeoTreeSymbolicLinkTarget', { fg = colors.normal.cyan, italic = true })

  -- File and directory names
  vim.api.nvim_set_hl(0, 'NeoTreeFileName', { fg = theme.foreground })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'NeoTreeDotfile', { fg = muted })
  vim.api.nvim_set_hl(0, 'NeoTreeHiddenByName', { fg = muted })
  vim.api.nvim_set_hl(0, 'NeoTreeFilterTerm', { fg = colors.normal.yellow, bold = true })

  -- File icons
  vim.api.nvim_set_hl(0, 'NeoTreeFileIcon', { fg = theme.foreground })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = theme.accent })

  -- Git status colors
  vim.api.nvim_set_hl(0, 'NeoTreeGitAdded', { fg = colors.normal.green })
  vim.api.nvim_set_hl(0, 'NeoTreeGitModified', { fg = colors.normal.blue })
  vim.api.nvim_set_hl(0, 'NeoTreeGitDeleted', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'NeoTreeGitRenamed', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'NeoTreeGitUntracked', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'NeoTreeGitIgnored', { fg = muted })
  vim.api.nvim_set_hl(0, 'NeoTreeGitUnstaged', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'NeoTreeGitStaged', { fg = colors.normal.green })
  vim.api.nvim_set_hl(0, 'NeoTreeGitConflict', { fg = colors.normal.red, bold = true })

  -- Cursor and selection
  vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = overlay })
  vim.api.nvim_set_hl(0, 'NeoTreeDimText', { fg = muted })

  -- Additional highlight groups for better compatibility
  -- These are important for various plugins and UI elements
  vim.api.nvim_set_hl(0, 'FloatBorder', { fg = overlay, bg = surface })
  vim.api.nvim_set_hl(0, 'FloatTitle', { fg = theme.accent, bg = surface, bold = true })
  vim.api.nvim_set_hl(0, 'Title', { fg = theme.accent, bold = true })
  vim.api.nvim_set_hl(0, 'Directory', { fg = theme.accent })
  vim.api.nvim_set_hl(0, 'MatchParen', { fg = theme.accent, bold = true })
  vim.api.nvim_set_hl(0, 'NonText', { fg = muted })
  vim.api.nvim_set_hl(0, 'SpecialKey', { fg = muted })
  vim.api.nvim_set_hl(0, 'EndOfBuffer', { fg = background_color })
  vim.api.nvim_set_hl(0, 'Question', { fg = colors.normal.green })
  vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = overlay, bold = true })

  -- LSP/Notification message box styling (fidget.nvim and similar plugins)
  vim.api.nvim_set_hl(0, 'FidgetTitle', { fg = theme.accent, bg = surface, bold = true })
  vim.api.nvim_set_hl(0, 'FidgetTask', { fg = theme.foreground, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetIcon', { fg = theme.accent, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetText', { fg = theme.foreground, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetSpinner', { fg = colors.normal.cyan, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetGroup', { fg = muted, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetProgress', { fg = colors.normal.green, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetProgressNC', { fg = muted, bg = surface })
  vim.api.nvim_set_hl(0, 'FidgetComplete', { fg = colors.normal.green, bg = surface })
  
  -- General notification highlight groups
  vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyBorder', { fg = overlay, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyTitle', { fg = theme.accent, bg = surface, bold = true })
  vim.api.nvim_set_hl(0, 'NotifyIcon', { fg = theme.accent, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyError', { fg = colors.normal.red, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyWarn', { fg = colors.normal.yellow, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyInfo', { fg = colors.normal.cyan, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyDebug', { fg = muted, bg = surface })
  vim.api.nvim_set_hl(0, 'NotifyTrace', { fg = muted, bg = surface })

  -- LSP and Diagnostic highlighting
  vim.api.nvim_set_hl(0, 'DiagnosticError', { fg = colors.normal.red })
  vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = colors.normal.yellow })
  vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = colors.normal.cyan })
  vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = muted })

  -- Float window (preview, etc.)
  vim.api.nvim_set_hl(0, 'NeoTreeFloatBorder', { fg = overlay, bg = surface })
  vim.api.nvim_set_hl(0, 'NeoTreeFloatTitle', { fg = theme.accent, bg = surface, bold = true })

  -- Tab bar
  vim.api.nvim_set_hl(0, 'NeoTreeTabInactive', { fg = muted, bg = surface })
  vim.api.nvim_set_hl(0, 'NeoTreeTabActive', { fg = theme.foreground, bg = overlay, bold = true })
  vim.api.nvim_set_hl(0, 'NeoTreeTabSeparatorInactive', { fg = overlay, bg = surface })
  vim.api.nvim_set_hl(0, 'NeoTreeTabSeparatorActive', { fg = theme.accent, bg = overlay })

  -- Update terminal colors
  vim.g.terminal_color_0 = colors.normal.black
  vim.g.terminal_color_1 = colors.normal.red
  vim.g.terminal_color_2 = colors.normal.green
  vim.g.terminal_color_3 = colors.normal.yellow
  vim.g.terminal_color_4 = colors.normal.blue
  vim.g.terminal_color_5 = colors.normal.magenta
  vim.g.terminal_color_6 = colors.normal.cyan
  vim.g.terminal_color_7 = colors.normal.white
  vim.g.terminal_color_8 = colors.bright.black
  vim.g.terminal_color_9 = colors.bright.red
  vim.g.terminal_color_10 = colors.bright.green
  vim.g.terminal_color_11 = colors.bright.yellow
  vim.g.terminal_color_12 = colors.bright.blue
  vim.g.terminal_color_13 = colors.bright.magenta
  vim.g.terminal_color_14 = colors.bright.cyan
  vim.g.terminal_color_15 = colors.bright.white

  -- Force Neo-tree to refresh and pick up new git colors
  -- This ensures git status colors update immediately when theme changes
  vim.defer_fn(function()
    local ok, neo_tree = pcall(require, 'neo-tree')
    if ok then
      -- Refresh all Neo-tree sources to pick up new highlight groups
      pcall(function()
        local events = require 'neo-tree.events'
        events.fire_event(events.GIT_EVENT)
        -- Also trigger a full filesystem refresh to ensure git status colors update
        vim.cmd 'Neotree filesystem refresh'
      end)
    end
  end, 50) -- Small delay to ensure highlight groups are fully applied
end

-- Function to start file watcher for automatic theme sync
function M.start_watcher()
  -- Stop existing watcher if running
  M.stop_watcher()

  -- Only watch if preferences file exists
  if vim.fn.filereadable(WARP_PREFS_FILE) == 0 then
    return false
  end

  file_watcher = vim.uv.new_fs_event()
  if not file_watcher then
    vim.notify('Failed to create file watcher for Warp theme sync', vim.log.levels.WARN)
    return false
  end

  local success, err = pcall(vim.uv.fs_event_start, file_watcher, WARP_PREFS_FILE, {}, function(err, filename, events)
    if err then
      vim.notify('File watcher error: ' .. err, vim.log.levels.ERROR)
      return
    end

    -- Debounce rapid file changes (macOS can trigger multiple events)
    vim.defer_fn(function()
      -- Only sync if we detect an actual theme change
      local current_theme = M.detect_current_theme()
      if current_theme then
        M.apply_theme(current_theme)
        save_theme_to_cache(current_theme)
        vim.notify('Warp theme synced: ' .. current_theme.name, vim.log.levels.INFO)
      end
    end, 100) -- 100ms debounce
  end)

  if not success then
    vim.notify('Failed to start file watcher: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
    file_watcher = nil
    return false
  end

  return true
end

-- Function to stop file watcher
function M.stop_watcher()
  if file_watcher then
    pcall(vim.uv.fs_event_stop, file_watcher)
    pcall(vim.uv.close, file_watcher)
    file_watcher = nil
  end
end

-- Function to sync with current theme
function M.sync(force)
  local current_theme = M.detect_current_theme()

  if not current_theme then
    if force then
      -- Force re-read colors
      current_theme = read_current_terminal_colors()
    else
      return
    end
  end

  if current_theme then
    M.apply_theme(current_theme)
    -- Save to cache for next startup
    save_theme_to_cache(current_theme)
  end
end

return M
