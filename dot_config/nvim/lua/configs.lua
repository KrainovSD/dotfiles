vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- spell
vim.opt.spell = true
vim.opt.spelllang = { "ru", "en" }
vim.opt.spelloptions = "camel"
local spell_dir = vim.fn.stdpath("config") .. "/spell"
vim.fn.mkdir(spell_dir, "p")
vim.opt.spellfile = spell_dir .. "/dict.utf-8.add"

-- Enable filetype detection, plugins and indentation
vim.cmd("filetype on")
vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")

-- UI configuration
vim.opt.number = true -- Show line numbers
vim.o.winborder = "rounded"
-- vim.opt.numberwidth = 2
vim.opt.syntax = "on" -- Enable syntax highlighting
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.cursorline = true -- Highlight current line
-- vim.opt.cursorlineopt = "number"  -- Highlight only number
vim.opt.showmode = true -- Show current mode (insert, visual, etc.)
vim.opt.showmatch = true -- Highlight matching brackets

-- Indentation settings
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> counts for
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart indent

-- Search configuration
vim.opt.incsearch = true -- Show matches as search is typed
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive when uppercase is used
vim.opt.hlsearch = true -- Highlight all search matches

-- Mouse
vim.opt.mouse = "a"
vim.opt.mousefocus = true

-- History and completion
vim.opt.history = 1000 -- Command history size
vim.opt.clipboard = "unnamedplus"
vim.opt.wildmenu = true -- Enhanced command-line completion
vim.cmd(":set wildmode=list:longest") -- Completion behavior

-- Other
vim.cmd(":set nobackup") -- Disable backup files
vim.opt.scrolloff = 10 -- Minimum lines to keep above/below cursor
vim.cmd(":set wildignore=*docx,*.jpg,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx") -- File patterns to ignore for wildmenu and other completions
vim.opt.belloff = "all" -- Disable all bell sounds
vim.opt.completeopt = "longest" -- Auto-complete to longest common string
vim.opt.wrap = true
vim.opt.linebreak = true
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt.wrap = true
    vim.opt.linebreak = true
  end,
})
