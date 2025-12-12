return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip'
        },

        config = function()
            -- Set up nvim-cmp.
            local cmp = require 'cmp'

            local luasnip = require('luasnip')

            -- local extra_wikilink_source = require 'adhd.wiki_links.cmp'
            -- cmp.register_source('wiki_links', extra_wikilink_source)
            cmp.setup({
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- For `luasnip` users.
                        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                    end,
                },
                window = {
                    -- completion = cmp.config.window.bordered(),
                    -- documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    {
                        name = 'nvim_lsp',
                        option = {
                            markdown_oxide = {
                                keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
                            }
                        }
                    },
                    { name = 'luasnip' }, -- For luasnip users.
                    { name = 'nvim_lsp_signature_help' }
                    -- { name = 'ultisnips' }, -- For ultisnips users.
                    -- { name = 'snippy' }, -- For snippy users.
                }, {
                    { name = 'buffer' },
                })
            })


            -- Markdown-specific setup
            cmp.setup.filetype('markdown', {
                sources = cmp.config.sources({
                    {
                        name = 'nvim_lsp',
                    },
                    { name = 'luasnip' }, -- For luasnip users.
                    -- { name = 'nvim_lsp_signature_help' },
                    -- { name = 'buffer' },     -- Completion from current buffer
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.menu = ({
                            nvim_lsp = '[LSP]',
                            -- nvim_lua = '[Nvim Lua]',
                            -- buffer = '[Buffer]',
                        })[entry.source.name]

                        vim_item.dup = ({
                            -- vsnip = 0,
                            nvim_lsp = 0,
                            -- buffer = 0,
                        })[entry.source.name] or 0

                        return vim_item
                    end
                }
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
                }, {
                    { name = 'buffer' },
                })
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    }
    , {
    'neovim/nvim-lspconfig',
    dependencies = { "hrsh7th/cmp-nvim-lsp", },
    config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Setup language servers.
        local lspconfig = require "lspconfig"

        vim.lsp.config('*', { capabilities = capabilities })

        vim.lsp.config('pyright', {
            settings = {
                python = {
                    analysis = {
                        extraPaths = { vim.fn.getcwd() }, -- No matter which file I open in a project, root is almost always in sys path
                        ignore = { '*' },
                        useLibraryCodeForTypes = true,
                        diagnosticSeverityOverrides = {
                            reportUnusedVariable = "warning", -- or anything
                        },
                        typeCheckingMode = "basic",
                        autoSearchPaths = true,
                    },
                },
            },
        })

        vim.lsp.config('ruff', {
            on_attach = function(client, _) client.server_capabilities.hoverProvider = false end,

            init_options = {
                settings = {
                    -- Any extra CLI arguments for `ruff` go here.
                    args = {},
                }
            }
        })

        -- vim.eslint.setup {
        --     capabilities = capabilities,
        --     -- on_attach = function(client, bufnr)
        --     --     vim.api.nvim_create_autocmd("BufWritePre", {
        --     --         buffer = bufnr,
        --     --         command = "EslintFixAll",
        --     --     })
        --     -- end,
        -- }


        vim.lsp.config('markdown_oxide', {
            -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
            -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
            capabilities = vim.tbl_deep_extend(
                'force',
                capabilities,
                {
                    workspace = {
                        didChangeWatchedFiles = {
                            dynamicRegistration = true,
                        },
                    },
                }
            ),
        })

        vim.lsp.config('yamlls', {
            settings = {
                yaml = {
                    schemas = {
                        ["https://raw.githubusercontent.com/kedro-org/kedro/develop/static/jsonschema/kedro-catalog-0.17.json"] = "conf/**/*catalog*",
                        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
                    }
                }
            }
        })

        -- vim.html.setup {
        --     capabilities = capabilities,
        -- }

        vim.lsp.config('bashls', {
            filetypes = { "sh", "zsh" },
        })

        vim.lsp.config('ts_ls', {
            on_attach = function(client)
                client.server_capabilities.document_formatting = false
            end,
        })
        -- lspconfig.cssls.setup({
        --     capabilities = capabilities,
        -- })

        vim.lsp.config('clangd', {
            cmd = {
                "/usr/bin/clangd",
                "--background-index",
                "--pch-storage=memory",          -- Store PCH in memory (faster but uses more RAM)
                "--clang-tidy",                  -- Enable clang-tidy diagnostics
                "-j=4",                          -- Use 4 parallel threads
                "--function-arg-placeholders",   -- Show argument placeholders
                "--completion-style=detailed",   -- Rich autocompletion
                "--query-driver=/usr/bin/clang*" -- Detect system compilers
            },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_dir = lspconfig.util.root_pattern("src"),
            init_option = { fallbackFlags = { "-std=c++2a" } },
            -- on_attach = function(client, bufnr)
            --     client.resolved_capabilities.document_formatting = true
            -- end
        })

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    completion = {
                        callSnippet = "Replace"
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    telemetry = {
                        enable = false
                    }
                },
            },
        })

        vim.lsp.enable('pyright')
        vim.lsp.enable('ruff')
        vim.lsp.enable('markdown_oxide')
        vim.lsp.enable('yamlls')
        vim.lsp.enable('bash_ls')
        vim.lsp.enable('ts_ls')
        vim.lsp.enable('clangd')
        vim.lsp.enable('lua_ls')
        vim.lsp.enable('html')
        vim.lsp.enable('eslint')


        -- lspconfig["null-ls"].setup({})

        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', ',e', vim.diagnostic.open_float)
        vim.keymap.set('n', 'ge', vim.diagnostic.goto_prev)
        vim.keymap.set('n', 'gE', vim.diagnostic.goto_next)
        vim.keymap.set('n', ',q', vim.diagnostic.setloclist)



        local function get_lsp_references(opts)
            if pcall(require, 'telescope') then
                return require('telescope.builtin').lsp_references(opts)
            else
                return vim.lsp.buf.references(opts)
            end
        end

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer

        local function on_list(options)
            if vim.bo.filetype == "markdown" then
                vim.cmd("edit " .. options.items[1].filename)
            else
                vim.fn.setqflist({}, ' ', options)
                vim.cmd.cfirst()
            end
        end

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', function()
                    vim.lsp.buf.definition({ on_list = on_list })
                end, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<space>k', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', get_lsp_references, opts)
                vim.keymap.set('n', ';f', function()
                    vim.lsp.buf.format { async = true }
                end, opts)
            end,
        })

        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '🆇',
                    [vim.diagnostic.severity.WARN] = '⚠️',
                    [vim.diagnostic.severity.INFO] = 'ℹ️',
                    [vim.diagnostic.severity.HINT] = '',
                },
            }
        })
    end

}, {
    'nvimtools/none-ls.nvim',
    config = function() -- Enable black and prettier formatting
        local null_ls = require("null-ls")

        local prettier = null_ls.builtins.formatting.prettier.with({
            extra_args = { "--print-width", "80" }
        })

        local sources = { prettier, null_ls.builtins.formatting.black }

        null_ls.setup({
            sources = sources,
        })
    end

}
}
