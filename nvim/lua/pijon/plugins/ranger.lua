return {{
    'francoiscabrol/ranger.vim',
    dependencies={'rbgrouleff/bclose.vim'},
    keys={{'<leader>l', ":Ranger<cr>"}},
    init=function() vim.keymap.remove('n', '<leader>f') end
}}
