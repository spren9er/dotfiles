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

-- vim: ts=2 sts=2 sw=2 et
