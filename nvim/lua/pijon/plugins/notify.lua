return {{
    "rcarriga/nvim-notify",
    init = function() vim.notify = require("notify") end,
    opts = {
        render = "simple",
        max_width = 60,
        timeout = 15000,
        background_colour = "#000000",
        stages = "slide",
    },
    keys = {{"<leader>un", function() require("notify").dismiss() end}}
}}
