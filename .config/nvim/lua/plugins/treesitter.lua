return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        dependencies = { 'nvim-tree/nvim-web-devicons' }, -- for some reason this only installs as a dependency?? --
        config = function()
            vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/runtime')

            require('nvim-treesitter').setup {
                install_dir = vim.fn.stdpath('data') .. '/site',
            }

            vim.api.nvim_create_autocmd('FileType', {
                pattern = {
                    "c",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "python",
                    "typescript",
                    "typescriptreact",
                    "yaml",
                },
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end

    }
}
