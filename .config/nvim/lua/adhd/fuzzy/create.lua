local telescope = require('telescope.builtin')
local Path = require('plenary.path')
-- Function to find directories and move the current file
local function create_new_file()
    local current_dir = vim.fn.expand("%:p:h") -- Directory of the current buffer
    current_dir = vim.fn.fnamemodify(current_dir, ":.")

    telescope.find_files({
        prompt_title = "Create File In Directory",
        results_title = "Directories",
        cwd = vim.fn.getcwd(),
        previewer = false,

        find_command = { "fd", "--type", "d" },
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

                    vim.ui.input({ prompt = "Enter filename: " }, function(input)
                        if input then
                            print("Filename entered:", input)
                            local path = Path:new(target_dir, input) -- Construct the target path without duplicating directories
                            if input:sub(-1) == "/" then
                                -- Treat it as a directory
                                path:mkdir({ parents = true })
                                print("Directory created:", path)
                            else
                                -- Treat it as a file
                                path:touch()
                                vim.cmd("e " .. path:absolute())
                                vim.cmd("w!")
                                vim.notify("File touched:" .. path, "info")
                            end

                            require("adhd.utils.neo-tree-refresh").refresh_filesystem()
                        else
                            vim.notify("Input canceled", "info")
                        end
                    end)
                end
            end)
            return true
        end,
    })
end

vim.keymap.set('n', 'fc', create_new_file) --{ noremap = true, silent = true }
