return {
    { 'luochen1990/rainbow' },
    { 'mhinz/vim-startify' },
    {
        'yuttie/comfortable-motion.vim',
        config = function()
            vim.keymap.set('n', '<C-d>', ':call comfortable_motion#flick(100)<CR>', { silent = true })
            vim.keymap.set('n', '<C-u>', ':call comfortable_motion#flick(-100)<CR>', { silent = true })

            -- vim.keymap.set('n', '<C-f>', ':call comfortable_motion#flick(200)<CR>', { silent = true }) i prefer to use this in neotree;
            vim.keymap.set('n', '<C-b>', ':call comfortable_motion#flick(-200)<CR>', { silent = true })
        end
    },
    { 'RRethy/vim-illuminate',      enabled = false },
    { 'ryanoasis/vim-devicons' },
    { 'tpope/vim-fugitive' },
    -- { 'tpope/vim-dispatch' },
    -- { 'nvim-tree/nvim-web-devicons' ,  opts = {} },
    { 'windwp/nvim-ts-autotag' },
    { 'wvim-tree/nvim-web-devicons' },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        lazy = false, -- neo-tree will lazily load itself
        config = function()
            -- local log = require("neo-tree.log")
            -- log.new({ level = "trace" }, true) -- change log level of neo tree
            --
            -- local function on_move(data)
            --     Snacks.rename.on_rename_file(data.source, data.destination)
            -- end
            -- local events = require("neo-tree.events")
            --
            -- opts.event_handlers = opts.event_handlers or {}
            -- vim.list_extend(opts.event_handlers, {
            --     { event = events.FILE_MOVED,   handler = on_move },
            --     { event = events.FILE_RENAMED, handler = on_move },
            -- })

            vim.keymap.set('n', '<C-n>', ':Neotree toggle<cr>', { silent = true })

            vim.keymap.set('n', '<C-f>', function()
                    local reveal_file = vim.fn.expand('%:p')

                    if (reveal_file == '') then
                        reveal_file = vim.fn.getcwd()
                    else
                        local f = io.open(reveal_file, "r")
                        if (f) then
                            f.close(f)
                        else
                            reveal_file = vim.fn.getcwd()
                        end
                    end
                    require('neo-tree.command').execute({
                        action = "focus",          -- OPTIONAL, this is the default value
                        source = "filesystem",     -- OPTIONAL, this is the default value
                        position = "left",         -- OPTIONAL, this is the default value
                        reveal_file = reveal_file, -- path to file or folder to reveal
                        reveal_force_cwd = true,   -- change cwd without asking if needed
                    })
                end,
                { desc = "Open neo-tree at current file or working directory", noremap = true }
            );
        end
    },
    {
        'folke/snacks.nvim',
        priority = 1000,

        config = function()
            require 'snacks'.setup({
                indent = { enabled = true },
                input = { enabled = true },
                notifier = { enabled = true },
                scope = { enabled = true },
                -- scroll = { enabled = true },
                statuscolumn = { enabled = false }, -- we set this in config/options.lua
                -- toggle = { map = LazyVim.safe_keymap_set },
                -- words = { enabled = true },
            })
            require "adhd.secondbrain" -- requires snacks to look nice --
        end
    },
    {
        'phaazon/hop.nvim',
        opts = { keys = 'etovxqpdygfblzhckisuran' },
        keys = {
            { '<leader>j', ':HopWord<cr>',                silent = true, desc = "Hop to a word somewhere in buffer" },

            { ';j',        ':HopAnywhereCurrentLine<cr>', silent = true, desc = "Hop to a character in line" }
        }
    },
    -- {
    --     'preservim/nerdtree',
    --     enabled = false,
    --     config = function()
    --         vim.g["NERDTreeQuitOnOpen"] = 0
    --         vim.g["webdevicons_conceal_nerdtree_brackets"] = 1
    --
    --         vim.g.NERDTreeIgnore = { [[\.DS_Store$]], [[^__pycache__$]] }
    --
    --         vim.keymap.set("n", "<C-f>", ":NERDTreeFind<cr>")
    --         vim.keymap.set("n", "<C-n>", ":NERDTree<cr>")
    --     end
    -- },
      {
        'MagicDuck/grug-far.nvim',
        -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
        -- additional lazy config to defer loading is not really needed...
        config = function()
          -- optional setup call to override plugin options
          -- alternatively you can set options with vim.g.grug_far = { ... }
          require('grug-far').setup({
            -- options, see Configuration section below
            -- there are no required options atm
          });
        end
      },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' },
        config = function()
            local telescope = require("telescope")

            telescope.setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {
                            -- even more opts
                        } },
                },
                buffer_previewer_maker = function(filepath, bufnr, opts)
                    opts = opts or {}

                    filepath = vim.fn.expand(filepath)
                    vim.loop.fs_stat(filepath, function(_, stat)
                        if not stat then return end
                        if stat.size > 100000 then
                            return
                        else
                            require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
                        end
                    end)
                end,
                mappings = {
                    i = {
                        ['<C-b>'] = require('telescope.actions').delete_buffer
                    },
                    n = {
                        ['<C-b>'] = require('telescope.actions').delete_buffer
                    },
                }

            }
            )
            require("telescope").load_extension("ui-select")
            -- register tasks
            -- local builtin = require('telescope.builtin')

            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end,
                { desc = 'Find Files (hidden)' })
            vim.keymap.set('n', 'ff', function() builtin.find_files() end, { desc = 'Find Files' })
            vim.keymap.set('n', 'fg', function() builtin.live_grep() end, { desc = 'Live Grep' })
            vim.keymap.set('n', 'fb', function() builtin.buffers() end, { desc = 'Find Buffers' })
            vim.keymap.set('n', 'fh', function() builtin.help_tags() end, { desc = 'Help Tags' })
            vim.keymap.set('n', 'fr', function() builtin.lsp_incoming_calls() end, { desc = 'LSP Incoming Calls' })
            vim.keymap.set('n', '<leader>.f', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end,
                { desc = 'Find Files (cwd)' })

            require "adhd.tasks" -- deeply integrated with telescope --
            require "adhd.fuzzy"
        end,

    }
}
