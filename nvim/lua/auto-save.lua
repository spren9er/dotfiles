-- Auto-save configuration
local autosave_group = vim.api.nvim_create_augroup('AutoSave', { clear = true })

local function auto_save()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)

  -- Only save if buffer is modified, has a filename, and is a normal buffer
  if vim.bo[buf].modified and filename ~= '' and vim.bo[buf].buftype == '' and vim.bo[buf].modifiable and not vim.bo[buf].readonly then
    vim.cmd 'silent! w'
  end
end

-- Auto-save when leaving buffer or losing focus
vim.api.nvim_create_autocmd({
  'InsertLeave',
  'BufLeave',
  'FocusLost',
}, {
  group = autosave_group,
  pattern = '*',
  callback = auto_save,
})
