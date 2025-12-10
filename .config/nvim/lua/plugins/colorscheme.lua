return {
    {
        "folke/tokyonight.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        enabled = true,
        config = function()
            require("tokyonight").setup({
                transparent = true,
                terminal_colors = false,
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
                on_highlights = function(hi, c)
                    hi["NeoTreeFileName"] = { fg = c.fg }
                end,

            })
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
}
