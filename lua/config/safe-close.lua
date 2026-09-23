-- 安全關閉分頁。處理兩個 Vim 原生行為造成的問題：
--
-- 1) `:bdelete` 會「連帶關閉所有正在顯示該 buffer 的視窗」。
--    所以關掉目前正在看的分頁時，編輯區視窗會直接消失，只剩檔案樹撐滿畫面，
--    看起來像所有分頁都被關掉了。解法：先把視窗切到別的檔案，再刪 buffer。
--
-- 2) bufferline 預設的 close_command 是無條件 `bdelete! <id>`，不檢查對象，
--    實測發生過它拿到檔案樹的 buffer 編號，把檔案樹整個砍掉。解法：先擋下受保護的視窗。
local M = {}

local PROTECTED_FILETYPES = {
  NvimTree = true,
  cheatsheet = true,
  toggleterm = true,
}

---@param bufnr number
---@return boolean closable, string|nil reason
function M.is_closable(bufnr)
  if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
    return false, "buffer 無效"
  end
  local ft = vim.bo[bufnr].filetype
  if PROTECTED_FILETYPES[ft] then
    return false, "受保護的視窗 (" .. ft .. ")"
  end
  if vim.bo[bufnr].buftype ~= "" then
    return false, "非一般檔案 (buftype=" .. vim.bo[bufnr].buftype .. ")"
  end
  if not vim.bo[bufnr].buflisted then
    return false, "不在分頁列上"
  end
  return true, nil
end

---找一個可以拿來頂替的 buffer：優先用分頁列上的其他檔案
---@param exclude number
---@return number|nil
local function pick_replacement(exclude)
  local alt = vim.fn.bufnr("#")
  if alt ~= -1 and alt ~= exclude and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
    return alt
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= exclude and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
      return b
    end
  end
  return nil
end

---@param bufnr number
function M.close(bufnr)
  local ok, reason = M.is_closable(bufnr)
  if not ok then
    vim.notify("已阻擋關閉：" .. tostring(reason), vim.log.levels.WARN)
    return
  end

  -- 有未存檔的修改時先問，不要默默丟掉
  if vim.bo[bufnr].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    local choice = vim.fn.confirm(
      "「" .. name .. "」有未存檔的修改，要怎麼處理？",
      "&1 存檔並關閉\n&2 不存檔直接關閉\n&3 取消",
      3
    )
    if choice == 1 then
      local written = pcall(vim.api.nvim_buf_call, bufnr, function()
        vim.cmd("write")
      end)
      if not written then
        vim.notify("存檔失敗，已取消關閉", vim.log.levels.ERROR)
        return
      end
    elseif choice ~= 2 then
      return -- 取消
    end
  end

  -- 關鍵：先讓所有顯示這個 buffer 的視窗改顯示別的東西，
  -- 這樣等一下 bdelete 就不會把這些視窗一起關掉、造成版面塌掉。
  local replacement = pick_replacement(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      if replacement then
        vim.api.nvim_win_set_buf(win, replacement)
      else
        -- 沒有其他檔案了，開一個空白 buffer 佔住視窗，避免視窗被關掉
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end
  end

  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

return M
