vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 停用內建 netrw，改由 nvim-tree 接管目錄開啟（例如 `nvim .`）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.cheatsheet")
