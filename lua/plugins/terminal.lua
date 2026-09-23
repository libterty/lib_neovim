return {
  "akinsho/toggleterm.nvim",
  -- 例外：不延遲載入，避免 lazy-key 首次觸發的時機問題，確保按鍵一定有效
  lazy = false,
  opts = {
    size = 15,
    direction = "horizontal",
    shade_terminals = true,
    start_in_insert = false,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
      float_opts = { border = "curved" },
    })

    local map = vim.keymap.set
    -- 注意：<C-\> 在多數終端機（含 iTerm2）預設是 SIGQUIT，按了不會送到 nvim，改用以下鍵位
    map({ "n", "t" }, "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "切換終端機（下方）" })
    map({ "n", "t" }, "<C-t>", "<cmd>ToggleTerm<cr>", { desc = "切換終端機（下方）" })
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "浮動終端機" })
    map("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "開啟 Lazygit（原始檔控制）" })
    -- 單鍵版本，不受 <leader> 連續按鍵時間限制影響
    map("n", "<C-g>", function()
      lazygit:toggle()
    end, { desc = "開啟 Lazygit（原始檔控制）" })

    -- 終端機滾輪支援：終端機 insert 模式下滑鼠滾輪預設會被送給裡面跑的程式，
    -- 而不是捲動 nvim 的 buffer，這裡攔截滾輪先切到 terminal-normal 模式捲動，再切回 insert
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(args)
        vim.opt_local.scrollback = 100000
        local opts = { buffer = args.buf }
        vim.keymap.set("t", "<ScrollWheelUp>", [[<C-\><C-n><ScrollWheelUp>i]], opts)
        vim.keymap.set("t", "<ScrollWheelDown>", [[<C-\><C-n><ScrollWheelDown>i]], opts)
      end,
    })
  end,
}
