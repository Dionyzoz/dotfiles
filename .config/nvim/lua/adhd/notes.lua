local Path = require('plenary.path')

local function get_notes_dir()
    local notes_dir = os.getenv("NOTES_DIR")

    if not notes_dir or notes_dir == "" then
        notes_dir = "~/vault"
    end

    return vim.fn.expand(notes_dir):gsub("/+$", "")
end

local function task_file_stem(title)
    local stem = title

    for _, char in ipairs({ "/", ":", "*", "?", '"', "<", ">", "|", "\\" }) do
        stem = stem:gsub(vim.pesc(char), "-")
    end

    stem = vim.trim(stem):gsub("%s+", " "):gsub("%.md$", "")

    if stem == "" then
        return nil
    end

    return stem
end

local function create_task_file(title)
    local clean_title = vim.trim(title):gsub("%s+", " ")
    local stem = task_file_stem(clean_title)

    if not stem then
        return nil, "Title is required."
    end

    local notes_dir = get_notes_dir()
    local tasks_dir = notes_dir .. "/0-tasks"
    vim.fn.mkdir(tasks_dir, "p")

    local path = tasks_dir .. "/" .. stem .. ".md"
    local stat = (vim.uv or vim.loop).fs_stat

    if stat(path) then
        path = tasks_dir .. "/" .. stem .. " " .. os.date("%Y%m%d%H%M%S") .. ".md"
    end

    local result = vim.fn.writefile({
        "---",
        "status: idea",
        "type: task",
        "rank: " .. os.time(),
        "---",
        "",
        "# " .. clean_title,
        "",
    }, path)

    if result ~= 0 then
        return nil, "Could not create task: " .. path
    end

    return path, nil, notes_dir
end

vim.api.nvim_create_user_command("Daily", function(opts)
    local NOTES_DIR = os.getenv("NOTES_DIR")
    local offset = opts.args
    local path = ""
    if offset then
        path = vim.fn.system("d -q " .. offset)
    else
        path = vim.fn.system("d -q")
    end
    vim.cmd("e " .. path)
    vim.cmd("lcd" .. NOTES_DIR)
    vim.cmd("w")
    vim.cmd("normal! 5ggzz")
    if not offset then
        vim.cmd("startinsert")
    end
end, { nargs = '?' })

vim.api.nvim_create_user_command("Note", function()
    local NOTES_DIR = os.getenv("NOTES_DIR")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            -- Escape spaces in filename
            local path = NOTES_DIR .. "/0-inbox/" .. input .. ".md"
            vim.fn.system("touch " .. vim.fn.shellescape(path))

            vim.cmd("e " .. path)
            -- vim.cmd("w")
            vim.cmd("lcd " .. NOTES_DIR)
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Zet", function()
    local NOTES_DIR = os.getenv("NOTES_DIR")
    vim.ui.input({ prompt = "Enter filename: " }, function(input)
        if input then
            local path = vim.fn.system("echo " .. input .. " | zet -q")
            vim.cmd("e " .. path)
            vim.cmd("lcd" .. NOTES_DIR)
            -- vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Task", function()
    vim.ui.input({ prompt = "Enter task name: " }, function(input)
        if input then
            local path, err, notes_dir = create_task_file(input)

            if not path then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end

            vim.cmd("edit " .. vim.fn.fnameescape(path))
            vim.cmd("lcd " .. vim.fn.fnameescape(notes_dir))
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")

            require("adhd.utils.neo-tree-refresh").refresh_filesystem()
        end
    end)
end, {})

vim.api.nvim_create_user_command("Permanent", function()
    local NOTES_DIR = os.getenv("NOTES_DIR")
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
            vim.cmd("lcd" .. NOTES_DIR)
            os.remove(og_path)
            -- vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})

vim.api.nvim_create_user_command("Template", function()
    local NOTES_DIR = os.getenv("NOTES_DIR")
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
            vim.cmd("lcd" .. NOTES_DIR)
            vim.cmd("w")
            vim.cmd("normal! 7ggzz")
            vim.cmd("startinsert")
        end
    end)
end, {})


vim.api.nvim_create_user_command("Archive", function()
    local NOTES_DIR = os.getenv("NOTES_DIR")

    if vim.fn.getcwd() ~= NOTES_DIR then
        vim.notify("Archiving only works in $NOTES_DIR dir", "error")
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
    vim.cmd("lcd" .. NOTES_DIR)

    vim.notify("Moved to: " .. target_path:absolute(), "info")

    require("adhd.utils.neo-tree-refresh").refresh_filesystem()
end
, {})
