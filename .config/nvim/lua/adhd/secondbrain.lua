local Path = require('plenary.path')

vim.api.nvim_create_user_command("Daily", function(opts)
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    local offset = opts.args
    local path = ""
    if offset then
        path = vim.fn.system("d -q " .. offset)
    else
        path = vim.fn.system("d -q")
    end
    vim.cmd("e " .. path)
    vim.cmd("lcd" .. SECOND_BRAIN)
    vim.cmd("w")
    vim.cmd("normal! 5ggzz")
    if not offset then
        vim.cmd("startinsert")
    end
end, { nargs = '?' })

vim.api.nvim_create_user_command("Note", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            -- Escape spaces in filename
            local path = SECOND_BRAIN .. "/0-inbox/" .. input .. ".md"
            vim.fn.system("touch " .. vim.fn.shellescape(path))

            vim.cmd("e " .. path)
            -- vim.cmd("w")
            vim.cmd("lcd " .. SECOND_BRAIN)
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Zet", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            local path = vim.fn.system("echo " .. input .. " | zet -q")
            vim.cmd("e " .. path)
            vim.cmd("lcd" .. SECOND_BRAIN)
            -- vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Task", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    vim.ui.input({ prompt = "Enter task name: " }, function(input)
        if input then
            local path = vim.fn.system("echo " .. input .. " | task -q")
            vim.cmd("e " .. path)
            vim.cmd("lcd" .. SECOND_BRAIN)
            -- vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Permanent", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local body = table.concat(lines, "\n")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            local escaped_body = vim.fn.shellescape(body)
            local escaped_input = vim.fn.shellescape(input)
            local command = string.format("echo %s | zet -q %s", escaped_input, escaped_body)
            local path = vim.fn.system(command)
            print(path)
            local og_path = vim.fn.expand("%")
            vim.cmd("e " .. path)
            vim.cmd("lcd" .. SECOND_BRAIN)
            os.remove(og_path)
            -- vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Template", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local body = table.concat(lines, "\n")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            local escaped_body = vim.fn.shellescape(body)
            local escaped_input = vim.fn.shellescape(input)
            local command = string.format("echo %s | zet -q %s", escaped_input, escaped_body)
            local path = vim.fn.system(command)
            print(path)

            vim.cmd("e " .. path)
            vim.cmd("lcd" .. SECOND_BRAIN)
            vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})


vim.api.nvim_create_user_command("Archive", function()
    local SECOND_BRAIN = os.getenv("SECOND_BRAIN")

    if vim.fn.getcwd() ~= SECOND_BRAIN then
        vim.notify("Archiving only works in $SECOND_BRAIN dir", "error")
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0) -- Get current file path
    -- Get just the filename from the current file's path
    local file = Path:new(current_file)

    local file_dir = file:parent()

    local file_split = file:_split()
    local filename = file_split[#file_split] -- Gets the last component, which is the filename


    local archive_path = Path:new(file_dir, "archive") -- Construct the target path without duplicating directories
    local target_path = Path:new(archive_path, filename)

    if archive_path:mkdir() ~= nil then
        vim.notify("Created local archive folder", "info")
    end                                -- exists ok by default

    vim.fn.rename(current_file, target_path:absolute()) -- Move the file to the constructed target path

    -- Update the buffer with the new file location
    vim.cmd("e " .. target_path:absolute())
    vim.cmd("lcd" .. SECOND_BRAIN)

    vim.notify("Moved to: " .. target_path:absolute(), "info")

    require("adhd.utils.neo-tree-refresh").refresh_filesystem()
end
, {})
