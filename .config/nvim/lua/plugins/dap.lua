return {

    {
        'mfussenegger/nvim-dap',
        dependencies = { 'mfussenegger/nvim-dap-python' },

        config = function()
            local dap = require('dap')

            require('dap-python').setup('/usr/bin/python')

            dap.configurations.python = {
                {
                    -- The first three options are required by nvim-dap
                    type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
                    request = 'launch',
                    name = "Launch file",

                    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
                    console = 'integratedTerminal',
                    program = "${file}", -- This configuration will launch the current file if used.
                    cwd = vim.fn.getcwd(),
                    justMyCode = false,
                    pythonPath = function()
                        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                        local cwd = vim.fn.getcwd()
                        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                            return cwd .. '/venv/bin/python'
                        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                            return cwd .. '/.venv/bin/python'
                        else
                            return '/usr/bin/python'
                        end
                    end,
                },
                {
                    -- func host start --language-worker -- "-m debugpy --listen 127.0.0.1:9091" --verbose
                    type = 'python',
                    request = 'attach',
                    name = 'Attach to debugpy',
                    justMyCode = false,
                    server = 'localhost',
                    console = 'integratedTerminal',
                    port = 5678
                },
                {
                    type = 'python',
                    request = 'launch',
                    name = 'Debug flask application',
                    module = 'flask',
                    args = { 'run' },
                    console = 'integratedTerminal',
                }
            }

            -- Function to open debug terminal in vertical split
            dap.defaults.fallback.terminal_win_cmd = "vsplit new"


            vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
            vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
            vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
            vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
            vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
            vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
            vim.keymap.set('n', '<Leader>LP',
                function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
            vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
            vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
        end

    },
}
