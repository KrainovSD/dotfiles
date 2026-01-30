local opts = { noremap = true, silent = true }

-- lsp
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

vim.keymap.set("n", "<C-s>", ":w <CR>", opts)
-- moving
vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set({ "n", "v" }, "J", "4j", opts)
vim.keymap.set({ "n", "v" }, "K", "4k", opts)
vim.keymap.set({ "n", "v" }, "H", "4h", opts)
vim.keymap.set({ "n", "v" }, "L", "4l", opts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)

-- buffer sizing
vim.keymap.set("n", "<leader>sp", ":vsplit<CR>", opts)
vim.keymap.set({ "n", "t" }, "<A-Left>", ":SmartResizeLeft<CR>", opts)
vim.keymap.set({ "n", "t" }, "<A-Right>", ":SmartResizeRight<CR>", opts)
vim.keymap.set({ "n", "t" }, "<A-Down>", ":SmartResizeDown<CR>", opts)
vim.keymap.set({ "n", "t" }, "<A-Up>", ":SmartResizeUp<CR>", opts)

-- moving buffers
vim.keymap.set({ "n", "t" }, "<leader>mh", ":SmartSwapLeft<CR>", opts)
vim.keymap.set({ "n", "t" }, "<leader>ml", ":SmartSwapRight<CR>", opts)
vim.keymap.set({ "n", "t" }, "<leader>mj", ":SmartSwapDown<CR>", opts)
vim.keymap.set({ "n", "t" }, "<leader>mk", ":SmartSwapUp<CR>", opts)
vim.keymap.set({ "n", "t" }, "<leader>mx", "<C-w>x", opts)

-- moving cursor
-- vim.keymap.set({ "n", "t" }, "<C-h>", ":SmartCursorMoveLeft<CR>", { noremap = true })
-- vim.keymap.set({ "n", "t" }, "<C-l>", ":SmartCursorMoveRight<CR>", { noremap = true })
-- vim.keymap.set({ "n", "t" }, "<C-j>", ":SmartCursorMoveDown<CR>", { noremap = true })
-- vim.keymap.set({ "n", "t" }, "<C-k>", ":SmartCursorMoveUp<CR>", { noremap = true })

-- multicursor
vim.keymap.set("n", "<C-d>", "<Plug>(VM-Find-Under)", opts)
vim.keymap.set("v", "<C-d>", "<Plug>(VM-Find-Subword-Under)", opts)
vim.keymap.set("n", "<C-S-j>", "<Plug>(VM-Add-Cursor-Down)", opts)
vim.keymap.set("n", "<C-S-K>", "<Plug>(VM-Add-Cursor-Up)", opts)

-- commnets
-- gc / gb / gcc / gbc

-- tree
vim.keymap.set("n", "<leader>tr", ":Neotree toggle<CR>", opts)

-- terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
vim.keymap.set({ "n", "t" }, "<leader>sh", ":ToggleTerm<CR>", opts)

-- git signs
vim.keymap.set("n", "<leader>dpl", ":Gitsigns preview_hunk_inline<CR>", opts)
vim.keymap.set("n", "<leader>dr", ":Gitsigns reset_hunk<CR>", opts)
vim.keymap.set("n", "<leader>dbv", ":Gitsigns diffthis<CR>", opts)
vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>", opts)
vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", opts)
vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory<CR>", opts)
vim.keymap.set("n", "<leader>G", function()
  vim.cmd.Git()
end, opts)

-- markdown
vim.keymap.set("n", "<leader>md", ":RenderMarkdown toggle<CR>", opts)
vim.keymap.set("n", "<leader>ss", "<cmd>set spell!<CR>", opts)

-- spell
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

-- tags
vim.keymap.set("n", "<leader>tg", ":Tagbar toggle<CR>", opts)
vim.keymap.set("n", "<leader>at", ":AerialNavToggle<CR>", opts) -- or :AerialToggle - without ui

-- tabs
vim.keymap.set("n", "<C-,>", ":BufferLineCyclePrev<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", opts)
vim.keymap.set("n", "<C-.>", ":BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<A-,>", ":BufferLineMovePrev<CR>", opts)
vim.keymap.set("n", "<A-.>", ":BufferLineMoveNext<CR>", opts)
vim.keymap.set("n", "<leader>bp", ":BufferLineTogglePin<CR>", opts)
vim.keymap.set("n", "<leader>q", ":Bdelete<CR>", opts)
vim.keymap.set("n", "<leader>bq", ":BufferLineCloseOthers<CR>", opts)

-- fold
vim.keymap.set("n", "zr", function()
  local ufo = require("ufo")
  ufo.closeFoldsWith(1)
end)
vim.keymap.set("n", "zo", function()
  local ufo = require("ufo")
  ufo.openAllFolds()
end)
vim.keymap.set("n", "zc", function()
  local ufo = require("ufo")
  ufo.closeAllFolds()
end)
vim.keymap.set("n", "z", function()
  local ufo = require("ufo")
  local winid = ufo.peekFoldedLinesUnderCursor()
  if winid then
    vim.api.nvim_win_close(winid, true)
  end
  vim.cmd("normal! za")
end)
vim.keymap.set("n", "Z", function()
  local ufo = require("ufo")
  local winid = ufo.peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end)

-- telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", opts)
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", opts)
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
vim.keymap.set("n", "<leader>fc", ":Telescope commands<CR>", opts)
vim.keymap.set("n", "<leader>fq", ":Telescope quickfix<CR>", opts)

-- lsp
vim.keymap.set("n", "<leader>gb", "<C-o>", opts)
vim.keymap.set("n", "<leader>gf", "<C-i>", opts)
vim.keymap.set("n", "<leader>gd", ":lua vim.lsp.buf.definition()<CR>", opts)
vim.keymap.set("n", "<leader>gi", ":lua vim.lsp.buf.implementation()<CR>", opts)
vim.keymap.set("n", "<leader>gr", ":lua vim.lsp.buf.references()<CR>", opts)
vim.keymap.set("n", "I", ":lua vim.lsp.buf.hover()<CR>", opts)
vim.keymap.set("n", "<leader>gn", ":lua vim.lsp.buf.rename()<CR>", opts)
vim.keymap.set("n", "<leader>e", ":lua vim.diagnostic.open_float()<CR>", opts)
vim.keymap.set("n", "<leader>gpe", ":lua vim.diagnostic.goto_prev()<CR>", opts)
vim.keymap.set("n", "<leader>gne", ":lua vim.diagnostic.goto_next()<CR>", opts)
vim.keymap.set("n", "<leader>fe", ":lua vim.diagnostic.setloclist()<CR>")
vim.keymap.set("n", "<leader>fea", ":lua vim.diagnostic.setqflist()<CR>")

vim.cmd([[

tnoremap <C-h> <C-\\><C-o><C-w>h
tnoremap <C-k> <C-\\><C-o><C-w>k
tnoremap <C-l> <C-\\><C-o><C-w>l
tnoremap <C-j> <C-\\><C-o><C-w>j

nnoremap <C-h> <C-w>h
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j

nnoremap <Space> @q
nnoremap <C-Space> ␛
vnoremap <C-Space> ␛
vnoremap <leader>e :!sh<CR>
]])
