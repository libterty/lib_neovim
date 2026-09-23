return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({ flavour = "mocha" })
    vim.cmd.colorscheme("catppuccin")
    -- 視窗分隔線（例如終端機跟上方程式碼視窗的邊界）改用白色，方便區分
    -- 注意：nvim-tree 那個視窗的邊界另外用 NvimTreeWinSeparator 這個獨立群組，要一併覆蓋
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#ffffff" })
  end,
}
