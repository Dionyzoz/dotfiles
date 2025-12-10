local map = vim.keymap.set


-- switch between buffers
map("n", "<leader>l", ":bnext<cr>")
map("n", "<leader>h", ":bprevious<cr>")
-- Switch between last opened buffers. This is easier to press.
map('n', '<C-s>', '<C-^>', { remap = false })

-- turn off highlighting with ;h
map('', ';h', ':noh<cr>', { silent = true })

-- map <leader>o & <leader>O to newline without insert mode
map("n", "<leader>o",
    [[:<C-u>call append(line("."), repeat([""], v:count1))<CR>]],
    { silent = true, desc = "newline below (no insert-mode)" })

map("n", "<leader>O",
    [[:<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>]],
    { silent = true, desc = "newline above (no insert-mode)" })

-- quickfix window
map("n", "<leader>n", ":cnext<CR>")
map("n", "<leader>p", ":cprev<CR>")

-- Making window changing easier
map('n', '<C-j>', '<C-W>j', { remap = false })
map('n', '<C-h>', '<C-W>h', { remap = false })
map('n', '<C-k>', '<C-W>k', { remap = false })
map('n', '<C-l>', '<C-W>l', { remap = false })
map('n', '<C-p>', '<C-W>p', { remap = false })

-- Change window position
map('n', '<C-W>j', '<C-W>J')
map('n', '<C-W>h', '<C-W>H')
map('n', '<C-W>k', '<C-W>K')
map('n', '<C-W>l', '<C-W>L')
-- quick saving
map('n', ';w', ':update<CR>', { remap = false, silent = true })

-- close buffer
map('n', '<leader>q', ':bdelete<CR>')

-- closing
map('n', ';q', ':q<CR>')

-- Quit all opened buffers
map("n", ";Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })


-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
-- map("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
-- map("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Always use very magic mode for searching
map("n", "/", [[/\v]])


-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
map("n", "c", '"_c')
map("n", "C", '"_C')
map("n", "cc", '"_cc')
map("x", "c", '"_c')


-- Copy entire buffer.
map("n", '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
map({ "v", "x" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
map({ "n", "v", "x" }, '<leader>yy', '"+yy',
    { noremap = true, silent = true, desc = 'Yank line to clipboard' })
map({ "n", "v", "x" }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })


-- Replace visual selection with text in register, but not contaminate the register,
-- see also https://stackoverflow.com/q/10723700/6064933.
map("x", "p", '"_c<Esc>p')


-- Go to the beginning and end of current line in insert mode quickly
map("i", "<C-A>", "<HOME>")
map("i", "<C-E>", "<END>")

-- Go to beginning of command in command-line mode
map("c", "<C-A>", "<HOME>")

-- Delete the character to the right of the cursor
map("i", "<C-D>", "<DEL>")
