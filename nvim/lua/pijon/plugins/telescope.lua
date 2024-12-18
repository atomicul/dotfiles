return {{
    "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = true,
    keys = {
        {"<leader><leader>", "<cmd>Telescope find_files<cr>"},
        {"<leader>ff", "<cmd>Telescope live_grep<cr>"},
        {"<leader>fg", "<cmd>Telescope git_files<cr>"},
        {"<leader>fb", "<cmd>Telescope buffers<cr>"},
    }
}}
