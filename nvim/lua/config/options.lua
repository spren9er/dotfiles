-- [[ Options ]]
-- See `:help vim.o`
--  For more options, you can see `:help option-list`

-- 24-bit colors
vim.o.termguicolors = true

-- Disable swap files
vim.o.swapfile = false

-- Reduce the "Press ENTER" prompts
vim.opt.shortmess:append 'I' -- Remove intro message
vim.opt.shortmess:append 'c' -- Don't show completion menu messages
vim.opt.shortmess:append 'S' -- Don't show search count message

-- Auto-reload files w/o asking
vim.o.autoread = true

-- Add relative line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = ''

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 50

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 8

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Set default indentation to 2 spaces
vim.o.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for
vim.o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.o.softtabstop = 2 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartindent = true -- Smart indenting when starting a new line

-- Set text width
vim.o.textwidth = 80
vim.o.colorcolumn = ''

-- Format options (manual string handling)
vim.o.formatoptions = vim.o.formatoptions .. 't' -- Add auto-wrap

-- Line wrapping
vim.o.wrap = true
vim.o.linebreak = true
vim.o.breakindent = true

-- Search
vim.o.hlsearch = false
vim.o.incsearch = true

-- vim: ts=2 sts=2 sw=2 et
