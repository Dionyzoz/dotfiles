local telescope = require('telescope.builtin')
local Path = require('plenary.path')

-- Function to find directories and move the current file
local function move_file_to_selected_dir()
    if vim.bo.modified then
        error("Error: Please save the buffer before proceeding.")
        return -- Exit the function if there are unsaved changes
    end

    local current_dir = vim.fn.expand("%:p:h") -- Directory of the current buffer
    current_dir = vim.fn.fnamemodify(current_dir, ":.")

    telescope.find_files({
        prompt_title = "Move File To Directory",
        results_title = "Directories",
        cwd = vim.fn.getcwd(),
        previewer = false,

        find_command = { "fd", "--type", "d", "-E", current_dir },
        -- find_command = { "find", ".", "-type", "d", "-not", "-path", "./.*" }, -- Include ".", exclude hidden directories and current buffer's directory
        entry_maker = function(entry)
            return {
                value = entry,
                display = " " .. entry:gsub("^./", ""), -- Display without the './' prefix
                ordinal = entry
            }
        end,
        layout_strategy = "center", -- Center the window
        layout_config = {
            prompt_position = "bottom",
            width = 0.4,  -- 40% of the screen width
            height = 0.5, -- 50% of the screen height
        },
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local entry = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)

                if entry then
                    local target_dir = entry.value
                    local current_file = vim.api.nvim_buf_get_name(0) -- Get current file path

                    -- Get just the filename from the current file's path
                    if current_file ~= "" and Path:new(current_file):exists() then
                        -- Get just the filename from the current file's path
                        local filename = Path:new(current_file):_split()
                        filename = filename
                        [#filename]                                         -- Gets the last component, which is the filename

                        local target_path = Path:new(target_dir, filename)  -- Construct the target path without duplicating directories
                        -- vim.fn.mkdir(target_dir, "p")                       -- Ensure the target directory exists
                        vim.fn.rename(current_file, target_path:absolute()) -- Move the file to the constructed target path

                        -- Update the buffer with the new file location
                        vim.cmd("e " .. target_path:absolute())
                        vim.notify("Moved to: " .. target_path:absolute(), "info")

                        require("adhd.utils.neo-tree-refresh").refresh_filesystem()
                    else
                        vim.notify("No file to move", "error")
                    end
                end
            end)
            return true
        end,
    })
end


-- You can bind this function to a key for quick access
vim.keymap.set('n', 'fm', move_file_to_selected_dir) --{ noremap = true, silent = true }
