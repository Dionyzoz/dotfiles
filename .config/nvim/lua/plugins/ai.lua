return {
    {
        'olimorris/codecompanion.nvim',
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        opts = {
            adapters = {
                http = {
                    deepseek = function()
                        return require("codecompanion.adapters").extend("deepseek", {
                            env = {
                                api_key = os.getenv("DEEPSEEK_SECRET"),
                            },
                            schema = {
                                model = {
                                    default = "deepseek-chat"
                                }
                            }

                        })
                    end,
                    anthropic = function()
                        return require("codecompanion.adapters").extend("anthropic", {
                            env = {
                                api_key = os.getenv("ANTHROPIC_SECRET"),
                            },
                            schema = {
                                model = {
                                    default = "claude-sonnet-4-20250514"
                                }
                            }
                        })
                    end,
                    tavily = function()
                        return require("codecompanion.adapters").extend("tavily", {
                            env = {
                                api_key = os.getenv("TAVILY_SECRET")
                            }
                        })
                    end,
                     azure_openai = function()
                        return require("codecompanion.adapters").extend("azure_openai", {
                          env = {
                            api_key = os.getenv("AZUREAI_SECRET"),
                            endpoint = os.getenv("AZUREAI_ENDPOINT"),
                          },
                          schema = {
                            model = {
                              default = "DeepSeek-V3.2",
                            },
                          },
                        })
                      end,
                }
            },

            strategies = {
                chat = {
                    adapter = "azure_openai",
                },
                inline = {
                    adapter = "azure_openai",
                },
            },

            display = {
                diff = {
                    enabled = true,
                    provider =  "mini_diff", -- inline|split|mini.diff

                },
                chat = {
                    window = {
                        width = 0.4,
                    }
                },
                action_palette = { provider = "snacks" }
            }
        }
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { "codecompanion" },
        opts = {
            render_modes = true, -- Render in ALL modes
            sign = {
                enabled = false, -- Turn off in the status column
            },
            file_types = { "codecompanion" }
        }
    },
    {
        "echasnovski/mini.diff",
        config = function()
            local diff = require("mini.diff")
            diff.setup({
                -- Disabled by default
                source = diff.gen_source.none(),
            })
        end,
    },
}
