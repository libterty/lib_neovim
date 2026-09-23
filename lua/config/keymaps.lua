local map = vim.keymap.set

-- 視窗移動
map("n", "<C-h>", "<C-w>h", { desc = "移到左邊視窗" })
map("n", "<C-j>", "<C-w>j", { desc = "移到下邊視窗" })
map("n", "<C-k>", "<C-w>k", { desc = "移到上邊視窗" })
map("n", "<C-l>", "<C-w>l", { desc = "移到右邊視窗" })

-- 常用
map("n", "<leader>w", "<cmd>w<cr>", { desc = "儲存檔案" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "關閉視窗" })
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "取消搜尋高亮" })

-- 終端機模式下用 esc 回到 normal mode
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "離開終端機模式" })
