-- Deprecated in favor of markdown-oxide lsp

local source = {}

-- This function runs the `rg` command to find all `[[...]]` links in Markdown files
local items = {}

local function get_wiki_links()
    local handle = io.popen([[rg -o '\[\[([^http].*?)\]\]' -g '*.md' . | sed 's/.*\[\[//' | sed 's/\]\]//']])

    local result = handle:read("*a")
    handle:close()

    local sync_items = {}
    for link in result:gmatch("[^\r\n]+") do
        table.insert(sync_items, {
            label = link,
            kind = vim.lsp.protocol.CompletionItemKind.Text
        })
    end
    return sync_items
end

-- Required by nvim-cmp to check if the source is available
function source:is_available()
    return vim.bo.filetype == "markdown" -- Only enable in Markdown files
end

-- Main function to provide completion items
function source:complete(params, callback)
    local before_cursor = params.context.cursor_before_line
    if before_cursor:sub(-2) == '[[' then
        -- If `[[` was typed, proceed with fetching and returning the items
        local populate_items = {}
        if next(items) == nil then
            populate_items = get_wiki_links()
        else
            populate_items = items
        end

        callback({ items = populate_items, isIncomplete = false })
    else
        -- If `[[` was not typed, return an empty result to prevent completion
        callback({ items = {}, isIncomplete = false })
    end
end

-- Optional: Resolve additional info for a completion item
function source:resolve(completion_item, callback)
    callback(completion_item)
end

-- function source:get_keyword_pattern()
--   return '\\[\\['  -- Only trigger after typing `[[`
-- end

function source:get_trigger_characters()
    return { '[' }
end

-- Optional: Custom behavior when a completion item is confirmed
function source:execute(completion_item, callback)
    callback(completion_item)
end

-- Asynchronous function to populate `wiki_links_cache` at startup
local function async_get_wiki_links()
    local command = [[rg -o '\[\[([^http].*?)\]\]' -g '*.md' . | sed 's/.*\[\[//' | sed 's/\]\]//']]

    vim.fn.jobstart(command, {
        stdout_buffered = true,

        -- Process stdout output
        on_stdout = function(_, data)
            -- Remove empty lines and populate `wiki_links_cache`
            local result = {}
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    table.insert(result, {
                        label = line,
                        kind = vim.lsp.protocol.CompletionItemKind.Text,
                        insertText = line .. "]]"
                    })
                end
            end
            items = result
        end,

        -- Handle any stderr output (optional)
        on_stderr = function(_, data)
            if data then
                vim.api.nvim_err_writeln(table.concat(data, "\n"))
            end
        end,

        -- Handle exit code (optional)
        on_exit = function(_, code)
            if code ~= 0 then
                vim.api.nvim_err_writeln("Wiki links search command exited with code " .. code)
            -- else
            --     print("Wiki links successfully loaded into cache.")
            end
        end,
    })
end

-- Run `async_get_wiki_links` at startup
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*.md",
    callback = function()
        vim.defer_fn(function()
            async_get_wiki_links()
        end, 100) -- Delay in milliseconds

        vim.api.nvim_create_user_command("RefreshLinks",
            async_get_wiki_links, {})
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.md",
    callback = async_get_wiki_links,
})

return source
