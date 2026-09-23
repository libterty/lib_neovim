return {
  "akinsho/bufferline.nvim",
  -- 核心 UI，不延遲載入，確保鍵位一開機就可用
  lazy = false,
  keys = {
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "下一個檔案分頁" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "上一個檔案分頁" },
    {
      "<leader>bd",
      function()
        require("config.safe-close").close(vim.api.nvim_get_current_buf())
      end,
      desc = "關閉目前分頁",
    },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "關閉其他分頁" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      -- 保護：bufferline 預設的 close_command 是無條件 `bdelete! <id>`。
      -- 實測遇過它收到檔案樹的 buffer 編號，結果把整個檔案樹砍掉、版面全毀。
      -- 這裡改成只允許關閉「真的在分頁列上的一般檔案」。
      close_command = function(bufnr)
        require("config.safe-close").close(bufnr)
      end,
      right_mouse_command = function(bufnr)
        require("config.safe-close").close(bufnr)
      end,
      offsets = {
        { filetype = "NvimTree", text = "檔案總管", highlight = "Directory", separator = true },
      },
      -- 不依賴 Nerd Font：關閉檔案類型圖示、用純文字符號取代特殊字符
      show_buffer_icons = false,
      show_close_icon = true,
      show_buffer_close_icons = true,
      close_icon = "x",
      buffer_close_icon = "x",
      modified_icon = "*",
      left_trunc_marker = "<",
      right_trunc_marker = ">",
      indicator = { icon = "|", style = "icon" },
    },
  },
}
