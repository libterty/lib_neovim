return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    -- 不依賴 Nerd Font：全域關閉圖示
    options = { theme = "catppuccin", icons_enabled = false },
    sections = {
      lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } },
    },
  },
}
