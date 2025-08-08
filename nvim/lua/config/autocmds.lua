-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-save configuration
local group = vim.api.nvim_create_augroup('auto-save', { clear = true })

local function auto_save()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)

  -- Only save if buffer is modified, has a filename, and is a normal buffer
  if vim.bo[buf].modified and filename ~= '' and vim.bo[buf].buftype == '' and vim.bo[buf].modifiable and not vim.bo[buf].readonly then
    vim.cmd 'silent! w'
  end
end

-- Auto-save when finishing editing
vim.api.nvim_create_autocmd({
  'InsertLeave',
  'BufLeave',
  'FocusLost',
}, {
  group = group,
  pattern = '*',
  callback = auto_save,
})

-- Warp theme sync command
vim.api.nvim_create_user_command('WarpSync', function(opts)
  local warp_theme = require 'custom.warp-theme'
  local force = opts.bang or false

  warp_theme.sync(force)
end, {
  desc = 'Sync Warp theme with Neovim (use :WarpSync! to force)',
  bang = true,
})

-- Auto-sync Warp theme on startup - load cached theme immediately, then sync in background
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Load cached Warp theme and sync',
  group = vim.api.nvim_create_augroup('warp-theme-sync', { clear = true }),
  callback = function()
    local ok, warp_theme = pcall(require, 'custom.warp-theme')
    if not ok then
      return
    end
    
    -- Try to load cached theme immediately for fast startup
    local cached_loaded = warp_theme.load_cached_theme()
    
    -- If no cache or cache failed, sync normally with a short delay
    if not cached_loaded then
      vim.defer_fn(function()
        warp_theme.sync(true)
      end, 30)
    else
      -- Cache loaded successfully, but still sync in background to detect changes
      vim.defer_fn(function()
        warp_theme.sync(false) -- Don't force if no change detected
      end, 100)
    end
    
    -- Start file watcher for automatic theme sync
    warp_theme.start_watcher()
    
    -- Add periodic theme check as fallback (every 2 seconds)
    local timer = vim.uv.new_timer()
    if timer then
      timer:start(2000, 2000, vim.schedule_wrap(function()
        warp_theme.sync(false)
      end))
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
