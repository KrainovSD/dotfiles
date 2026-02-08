local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<C-s>", ":w <CR>", opts)
vim.keymap.set("v", "p", "P", opts)
vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set({ "n", "v" }, "J", "4j", opts)
vim.keymap.set({ "n", "v" }, "K", "4k", opts)
vim.keymap.set({ "n", "v" }, "H", "4h", opts)
vim.keymap.set({ "n", "v" }, "L", "4l", opts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("n", "<leader>sp", ":vsplit<CR>")
vim.keymap.set({ "n", "t" }, "<leader>mx", "<C-w>x")
-- spell
vim.keymap.set("n", "<leader>ss", "<cmd>set spell!<CR>", opts)
vim.keymap.set({ "n", "v" }, "<leader>wa", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("spellgood " .. vim.fn.escape(word, ' \\"'))
  print('✓ Added to dictionary: "' .. word .. '"')
end, opts)
vim.keymap.set({ "n", "v" }, "<leader>wr", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("spellwrong " .. vim.fn.escape(word, ' \\"'))
  print('✗ Marked as wrong: "' .. word .. '"')
end, opts)
-- escape terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

-- terminal

-- tabs

vim.cmd([[

tnoremap <C-h> <C-\\><C-o><C-w>h
tnoremap <C-k> <C-\\><C-o><C-w>k
tnoremap <C-l> <C-\\><C-o><C-w>l
tnoremap <C-j> <C-\\><C-o><C-w>j

nnoremap <C-h> <C-w>h
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j

nnoremap c "_c
vnoremap c "_c

" nnoremap <Space> @q
nnoremap <C-Space> ␛
vnoremap <C-Space> ␛
vnoremap <leader>e :!sh<CR>
]])
