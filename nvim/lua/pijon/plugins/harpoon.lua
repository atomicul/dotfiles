return {{
    "ThePrimeagen/harpoon",
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        {"<leader>a", function() require("harpoon.mark").add_file() end},
        {"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end},
        {"<C-m>", function() require("harpoon.ui").nav_file(1) end},
        {"<C-w>", function() require("harpoon.ui").nav_file(2) end},
        {"<C-v>", function() require("harpoon.ui").nav_file(3) end},
        {"<C-z>", function() require("harpoon.ui").nav_file(4) end},
    },
}}
