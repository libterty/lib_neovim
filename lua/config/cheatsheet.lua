local LINES = {
  " 快速鍵小抄 ",
  "",
  " 存檔        :w",
  " 回上一頁     Ctrl-o",
  " 跳回下一頁    Ctrl-i",
  " 復原/取消復原  u / Ctrl-r",
  " 選取多行     V 之後 j/k",
  " 選取方塊多行   Ctrl-v 之後 j/k",
  " 註解/取消整行  gcc",
  " 註解/取消選取  先 V 選多行 再按 gc",
  " 切換分頁     Shift-h / Shift-l",
  " 關閉分頁     <leader>bd",
  " 開關檔案樹    <leader>e",
  " 開關終端機    <leader>tt",
  " 開 Lazygit    <leader>gg",
  " 格式化檔案    <leader>f",
  " 完整快速鍵清單 <leader>?",
  "",
  " 按 q 或 Esc 關閉 ",
}

local function toggle_cheatsheet()
  local width = 0
  for _, line in ipairs(LINES) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, LINES)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width + 2,
    height = #LINES,
    row = math.floor((vim.o.lines - #LINES) / 2),
    col = math.floor((vim.o.columns - width - 2) / 2),
    style = "minimal",
    border = "rounded",
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<esc>", close, { buffer = buf, nowait = true })
end

vim.keymap.set("n", "<leader>ch", toggle_cheatsheet, { desc = "開啟快速鍵小抄" })
