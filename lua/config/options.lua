local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 1200
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 8

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true

opt.undofile = true
opt.swapfile = false
opt.wrap = false

-- 檔案被 nvim 以外的東西改動時自動重新載入。
-- autoread 預設是開的，但它只有在 nvim 主動檢查檔案時才生效，
-- 所以這裡補上檢查時機（例如 git checkout 切分支之後，畫面才不會停在舊內容）。
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("AutoReloadChangedFiles", { clear = true }),
  callback = function()
    if vim.bo.buftype == "" and vim.fn.mode() == "n" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = "AutoReloadChangedFiles",
  callback = function()
    vim.notify("檔案在外部被修改，已重新載入", vim.log.levels.INFO)
  end,
})

-- 語言別的縮排覆寫（Python 常見慣例是 4 空格）
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})
