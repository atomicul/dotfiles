vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>")

vim.keymap.set("n", "<leader>qq", ":q<CR>")

-- Move lines by pressing J,K in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep search term centered while doing '/' searches
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.del("n", "<C-W><C-D>")
vim.keymap.del("n", "<C-W>d")

-- Scroll one line
vim.keymap.set('n', '<C-t>', '<C-e>')
-- The default <C-y> works for scrolling up

-- Scroll (half) screens
vim.keymap.set({'n', 'v'}, '<C-n>', '<C-d>')
vim.keymap.set({'n', 'v'}, '<C-p>', '<C-u>')

-- Prevent squirly brackets from adding to jump list
vim.keymap.set('n', '}', function()
    vim.cmd('keepjumps normal! ' .. vim.v.count1 .. '}')
end, { desc = "Keepjumps paragraph forward" })

vim.keymap.set('n', '{', function()
    vim.cmd('keepjumps normal! ' .. vim.v.count1 .. '{')
end, { desc = "Keepjumps paragraph backward" })
