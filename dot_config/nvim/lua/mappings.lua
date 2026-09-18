local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<C-s>", ":w <CR>", opts)
vim.keymap.set("v", "p", "P", opts)
-- vim.keymap.set("i", "jk", "<Esc>", opts)
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

vim.cmd([[



" write to other register
nnoremap c "_c
vnoremap c "_c


vnoremap <leader>e :!sh<CR>
]])
