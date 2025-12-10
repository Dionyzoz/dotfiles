if vim.loader then
    vim.loader.enable()
end


require("config.options")
require("commands")
require("autocommands")
require("keymaps")

-- plugin manager --
require("config.lazy")
