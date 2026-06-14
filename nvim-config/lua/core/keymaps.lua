local map = vim.keymap.set

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>W", "<cmd>noautocmd w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")
