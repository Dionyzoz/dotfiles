vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>q', ':bdelete!<cr>', { noremap = true, silent = true })
        if vim.startswith(vim.api.nvim_buf_get_name(0), "term://") then
            vim.cmd("startinsert")
        end
    end
})

-- Move help windows to the right side
vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function()
        vim.cmd("wincmd L")
    end,
})


-- -- CLIPBOARD SOLUTION IN WSL
-- vim.api.nvim_create_autocmd({ "FocusGained" }, {
--     pattern = { "*" },
--     command = [[call setreg("@", getreg("+"))]],
-- })
--
-- -- sync with system clipboard on focus
-- vim.api.nvim_create_autocmd({ "FocusLost" }, {
--     pattern = { "*" },
--     command = [[call setreg("+", getreg("@"))]],
-- })
