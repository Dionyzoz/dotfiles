-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Basic settings
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.scrolloff = 10

-- Tabs and indentation
vim.opt.tabstop = 8
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Encoding and clipboard
vim.opt.encoding = "utf-8"
vim.opt.backup = false
vim.opt.writebackup = false
-- vim.opt.clipboard = "unnamedplus"
-- vim.g.loaded_clipboard_provider = 1
vim.opt.clipboard = ""

-- Status line
vim.opt.laststatus = 2

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"

-- Window behavior
vim.opt.splitright = true

-- No annoying beeps
vim.opt.visualbell = true

-- Faster updates
vim.opt.updatetime = 300

-- Keep signcolumn visible to avoid screen flickering
vim.opt.signcolumn = "number"

-- Grep program
vim.opt.grepprg = "rg --vimgrep --smart-case --follow"


-- plugin config
vim.g.comfortable_motion_no_default_key_mappings = 1
