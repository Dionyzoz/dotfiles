local M = {}


M.refresh_filesystem = function()
    require("neo-tree.sources.manager").refresh("filesystem")

end

return M
