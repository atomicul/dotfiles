return {{
    "nvim-treesitter/nvim-treesitter",
    priority=900,
    config = function() require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "yaml",
            "python",
            "html",
            "javascript",
            "typescript",
            "cpp",
            "c",
            "lua",
            "vim",
            "vimdoc",
            "query",
            "markdown",
            "markdown_inline"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    } end,
}}
