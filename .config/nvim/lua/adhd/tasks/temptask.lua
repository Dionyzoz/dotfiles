local builtin = require('telescope.builtin')

local task_util = require('adhd.tasks.task_util')

local get_stem = require('adhd.tasks.task_util').get_stem

local function task_picker(project)
    builtin.find_files({
        prompt_title = "Tasks",
        results_title = "Task Files",
        find_command = task_util.find_command({ "tasks", project or "" }),
        entry_maker = function(entry)
            local file_and_hi = vim.split(entry, ",")
            local file = file_and_hi[1]
            local hi = file_and_hi[2]
            local stem = get_stem(file);


            local style = { { 0, #stem + 1 }, hi };

            local style_array = { style, }

            return {
                value = file, -- Full file path
                display = function()
                    return stem, style_array
                end,
                -- Display name without .md
                ordinal = entry, -- For sorting/filtering
            }
        end,
    })
end


local function relevant_task_picker(project)
    builtin.find_files({
        prompt_title = "Relevant Tasks",
        results_title = "Task Files",
        find_command = task_util.find_command({ "ranked_tasks", project or "" }),
        entry_maker = function(entry)
            local file_and_hi = vim.split(entry, ",")
            local file = file_and_hi[1]
            local hi = file_and_hi[2]
            local stem = get_stem(file);


            local style = { { 0, #stem + 1 }, hi };

            local style_array = { style, }

            return {
                value = file, -- Full file path
                display = function()
                    return stem, style_array
                end,
                -- Display name without .md
                ordinal = entry, -- For sorting/filtering
            }
        end,
    })
end

local function project_picker(callback)
    builtin.find_files({
        prompt_title = "Projects",
        results_title = "Project Files",
        find_command = task_util.find_command({ "projects" }),

        entry_maker = function(entry)
            return {
                value = entry,             -- Full file path
                display = get_stem(entry), -- Display name without .md
                ordinal = entry,
            }
        end,
        attach_mappings = function(_, map)
            map('i', '<C-j>', function(prompt_bufnr)
                local entry = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                if entry then
                    callback(entry.value)
                end
            end)
            return true
        end,
    })
end

local function link_to_project(project)
    local filepath = vim.fn.expand('%:p')

    ---@diagnostic disable-next-line: missing-fields
    task_util.run_python_script({ 'link_to_project', filepath, project },
        function()
            print("Succesfully linked to project")

            vim.cmd('checktime') -- Check for external file modifications
        end)
end


local function nice_rank()
    local filepath = vim.fn.expand('%:p')
    task_util.run_python_script({ 'nice_rank', filepath },
        function(_)
            vim.cmd('checktime') -- Check for external file modifications
        end)
end

-- local function remove_rank()
--     local filepath = vim.fn.expand('%:p')
--     task_util.run_python_script({ 'remove_rank', filepath }, function(_)
--         vim.cmd('checktime') -- Check for external file modifications
--     end)
-- end

local function status_update()
    local filepath = vim.fn.expand('%:p')
    vim.cmd("w") -- Ensure the changes are saved

    task_util.run_python_script({ "status_options", filepath }, function(status_options)
        vim.ui.select(status_options, { prompt = "Change status to" },
            function(option)
                if (option == nil) then
                    vim.notify("Did not update status", "info")
                    return
                end
                task_util.run_python_script({ 'status_update', filepath, option },
                    function(_)
                        vim.cmd('checktime') -- Check for external file modifications
                    end)
            end)
    end)
end

vim.api.nvim_create_user_command('Nice', nice_rank, {})
vim.api.nvim_create_user_command('TaskStatus', status_update, {})
-- vim.api.nvim_create_user_command('Block', remove_rank, {})
vim.api.nvim_create_user_command('LinkProject', function() project_picker(link_to_project) end, {})

--

-- This should be localized to markdown files only
vim.keymap.set('n', ',s', status_update, { noremap = true, silent = true })
vim.keymap.set('n', ',r', nice_rank, { noremap = true, silent = true })


vim.keymap.set('n', '<leader>fr', relevant_task_picker, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>fp', function() project_picker(task_picker) end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ft', task_picker, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ft', task_picker, { noremap = true, silent = true })
