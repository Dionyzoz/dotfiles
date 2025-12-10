return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { 'nvim-tree/nvim-web-devicons' }, -- for some reason this only installs as a dependency?? --
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "lua", "python", "json", "markdown", "javascript", "typescript", "tsx", "markdown_inline", "yaml" },
                sync_install = false,

                auto_install = false,
                highlight = {
                    enable = true,
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
                autotag = {
                    enable = true,
                }
            }
        end

    }
}
