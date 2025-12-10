local Job = require('plenary.job')
local Path = require('plenary.path')

local M = {}

function M.find_command(args)
    local command = '/usr/bin/python3'
    local _unpack = table.unpack or unpack -- backwards compatible
    return { command, os.getenv("XDG_CONFIG_HOME") .. '/nvim/python/project_finder.py', _unpack(args) }
end

function M.run_python_script(args, callback)
    ---
    --- Function that provides access to the project finder python module for managing tasks and projects.
    ---
    ---@diagnostic disable-next-line: deprecated
    local _unpack = table.unpack or unpack -- backwards compatible

    ---@diagnostic disable-next-line: missing-fields
    Job:new({
        command = '/usr/bin/python3',
        args = { os.getenv("XDG_CONFIG_HOME") .. '/nvim/python/project_finder.py', _unpack(args) },
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    local results = j:result() or {}
                    callback(results)
                else
                    local stderr = table.concat(j:stderr_result() or {}, "\n")
                    vim.notify("Python script failed: " .. stderr, vim.log.levels.ERROR)
                end
            end)
        end,
    }):start()
end

function M.get_stem(filepath)
    local filename = Path:new(filepath):_split()
    filename = filename[#filename]    -- Get the last component (filename)
    return filename:gsub("%.md$", "") -- Remove .md extension
end

return M
