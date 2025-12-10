local map = vim.keymap.set


map('t', '<ESC>', '<C-\\><C-n>', { noremap = true, silent = true })

-- terminals
map('n', '<leader>t', ':belowright new | resize 20 | term<CR>',
    { noremap = true, silent = true, desc = "Opens terminal in vertical split" })

map('n', '<leader>T', function()
    vim.cmd("vert new")
    vim.cmd("term")
end, { remap = true, desc = "Opens terminal in vertical split" })

map('n', ';t', function()
    local file_directory = vim.fn.expand("%:p:h")
    vim.cmd("belowright new")
    vim.cmd("resize 20")
    vim.cmd("lcd " .. file_directory)
    vim.cmd("term")
end
, { noremap = true, silent = true, desc = "Opens terminal in the current buffer's directory in horizontal split" })

map('n', ';T', function()
    local file_directory = vim.fn.expand("%:p:h")
    vim.cmd("vert new")
    vim.cmd("lcd " .. file_directory)
    vim.cmd("term")
end
, { remap = false, silent = true, desc = "Opens terminal in the current buffer's directory in vertical split" })


function ToggleQuickFix()
    local qfbufnr = vim.fn.getqflist({ qfbufnr = 0 }).qfbufnr
    -- Whether the qf buffer is open in a window
    local has_win
    if qfbufnr == 0 then -- Quickfix buffer doesn't exist
        has_win = false
    else                 -- Quickfix buffer has been open before
        if #vim.fn.win_findbuf(qfbufnr) > 0 then
            has_win = true
        else
            has_win = false
        end
    end

    if has_win then
        -- If we are currently on the qf window, then first switch
        -- back to the previous window
        if vim.fn.bufnr("%") == qfbufnr then
            vim.cmd.wincmd("p")
        end
        vim.cmd.cclose()
    else
        vim.cmd("botright copen")
    end
end

map("n", ";c", ToggleQuickFix, { desc = "Toggle qf window" })

-- Open the current working directory in VS Code with `:VSCode`
vim.api.nvim_create_user_command(
  'VSCode',
  function()
    -- `vim.fn.system()` runs the shell command asynchronously by default on Unix‑like systems;
    -- for Windows you may need "code.cmd" instead of "code".
    vim.fn.jobstart({ 'code', '.' }, { detach = true })
  end,
  { desc = 'Open the current working directory in Visual Studio Code' }
)

