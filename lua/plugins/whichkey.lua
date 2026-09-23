return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>?", "<cmd>WhichKey<cr>", desc = "顯示所有快速鍵" },
  },
  opts = {
    preset = "modern",
    -- 不依賴 Nerd Font：關閉自動圖示比對，避免顯示成方框
    icons = { mappings = false, rules = false },
    -- 只保留我們自訂的 <leader> 快速鍵提示，不要跳出內建的 operator/motion 說明（太干擾）
    presets = {
      operators = false,
      motions = false,
      text_objects = false,
      windows = false,
      nav = false,
      z = false,
      g = false,
    },
    spec = {
      { "<leader>f", group = "格式化" },
      { "<leader>b", group = "分頁 (buffer)" },
      { "<leader>t", group = "終端機" },
      { "<leader>c", group = "程式碼動作" },
      { "<leader>g", group = "Git" },
    },
  },
}
