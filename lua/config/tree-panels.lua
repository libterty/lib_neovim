-- 檔案樹欄位下方的兩個面板：Git 變更（上）＋ 快速鍵小抄（下）。
--
-- 都用浮動視窗而不是分割視窗：分割視窗會參與版面配置，檔案樹開關或開檔案時
-- 整個版面會重排（實測過小抄會被擠成中間一整欄）。浮動視窗不參與版面配置。
local M = {}

local CHEAT_LINES = {
  "── 快速鍵小抄（可捲動）──",
  "",
  "【模式切換】",
  "  Normal=下指令 Insert=打字",
  "  離開打字模式    Esc 或 Ctrl-[",
  "  游標前打字      i",
  "  游標後打字      a",
  "  跳行首打字      I",
  "  跳行尾打字      A",
  "  下方開新行打字   o",
  "  上方開新行打字   O",
  "  換掉整個單字    cw",
  "",
  "【檔案】",
  "  存檔          :w",
  "  另存          :w 檔名",
  "  離開          :q",
  "  存檔並離開     :wq",
  "  強制離開不存檔  :q!",
  "  全部離開       :qa",
  "",
  "【移動】",
  "  回上一個位置    Ctrl-o",
  "  回下一個位置    Ctrl-i",
  "  檔案開頭/結尾   gg / G",
  "  行首/行尾      0 / $",
  "  上下半頁       Ctrl-u / Ctrl-d",
  "  跳到第 N 行     :N",
  "",
  "【編輯】",
  "  復原 / 重做     u / Ctrl-r",
  "  刪除整行       dd",
  "  複製整行       yy",
  "  貼上          p",
  "  刪除到行尾     D",
  "  取代單字       ciw",
  "",
  "【選取】",
  "  選取多行       V 之後 j/k",
  "  選取方塊       Ctrl-v 之後 j/k",
  "  選取單字       viw",
  "  全選          ggVG",
  "",
  "【複製貼上】",
  "  複製選取       選取後按 y",
  "  複製整行       yy",
  "  剪下選取       選取後按 d",
  "  貼在游標後      p",
  "  貼在游標前      P",
  "  （y 會同時進系統剪貼簿，",
  "    可直接 Cmd-V 貼到其他 App）",
  "",
  "【滑鼠】",
  "  拖曳選取       按住左鍵拖曳",
  "  選好後複製      放開後按 y",
  "  用 iTerm2 原生選取",
  "                按住 Option 拖曳",
  "",
  "【註解】",
  "  整行切換       gcc",
  "  多行切換       V 選取後 gc",
  "",
  "【搜尋】",
  "  搜尋          /關鍵字",
  "  下一個/上一個   n / N",
  "  取消高亮       Esc",
  "  取代整份檔案    :%s/舊/新/g",
  "",
  "【分頁】",
  "  下一個分頁     Shift-l",
  "  上一個分頁     Shift-h",
  "  關閉分頁       <leader>bd",
  "  關閉其他分頁    <leader>bo",
  "",
  "【視窗】",
  "  左右上下切換    Ctrl-h/j/k/l",
  "  水平分割       :split",
  "  垂直分割       :vsplit",
  "  關閉視窗       <leader>q",
  "",
  "【檔案樹裡的操作】",
  "  開啟檔案       Enter",
  "  複製完整路徑    gy",
  "  複製相對路徑    Y",
  "  複製檔名       y",
  "  新增檔案       a",
  "  刪除          d",
  "  改名          r",
  "  收合全部       W",
  "  （都會進系統剪貼簿）",
  "",
  "【工具】",
  "  開關檔案樹     <leader>e",
  "  開關終端機     <leader>tt 或 Ctrl-t",
  "  浮動終端機     <leader>tf",
  "  Lazygit       <leader>gg 或 Ctrl-g",
  "  格式化檔案     <leader>f",
  "  完整快速鍵表    <leader>?",
  "",
  "【程式碼 LSP】",
  "  跳到定義       gd",
  "  找所有引用     gr",
  "  查看說明       K",
  "  重新命名       <leader>rn",
  "  修正建議       <leader>ca",
  "  上/下個錯誤     [d / ]d",
  "",
  "【終端機模式】",
  "  離開輸入模式    Esc Esc",
  "",
  "（<leader> 就是空白鍵）",
  "（滑鼠滾輪可捲動這些面板）",
}

local CHEAT_HEIGHT = 10
local GIT_HEIGHT = 10

local panels = {
  git = { win = nil, buf = nil, ft = "gitpanel" },
  cheat = { win = nil, buf = nil, ft = "cheatsheet" },
}

local git_files = {} -- 顯示行號 -> 檔案路徑

local function tree_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "NvimTree" and vim.api.nvim_win_get_config(win).relative == "" then
        return win
      end
    end
  end
  return nil
end

local function ensure_buf(panel, lines)
  if panel.buf and vim.api.nvim_buf_is_valid(panel.buf) then
    return panel.buf
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = panel.ft
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or { "" })
  vim.bo[buf].modifiable = false
  panel.buf = buf
  return buf
end

local function set_lines(buf, lines)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function hide(panel)
  if panel.win and vim.api.nvim_win_is_valid(panel.win) then
    pcall(vim.api.nvim_win_close, panel.win, true)
  end
  panel.win = nil
end

---@param panel table
---@param lines string[]|nil 只有第一次建立 buffer 時需要
---@param cfg table
local function place(panel, lines, cfg)
  if panel.win and vim.api.nvim_win_is_valid(panel.win) then
    vim.api.nvim_win_set_config(panel.win, cfg)
    return
  end
  panel.win = vim.api.nvim_open_win(ensure_buf(panel, lines), false, cfg)
  vim.wo[panel.win].wrap = false
  vim.wo[panel.win].cursorline = false
end

local function base_cfg(width, col, row, height)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = { "─", "─", "─", "", "", "", "", "" },
    -- 必須 focusable 才能用滑鼠滾輪捲動
    focusable = true,
    zindex = 40,
  }
end

local git_inflight = false
local git_last_lines = nil

---更新 Git 變更清單（非同步，不卡畫面）
---@param opts? { only_if_visible?: boolean }
function M.refresh_git(opts)
  opts = opts or {}
  local buf = panels.git.buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  -- 節流1：定時輪詢時，面板沒顯示就不要浪費資源
  if opts.only_if_visible and not (panels.git.win and vim.api.nvim_win_is_valid(panels.git.win)) then
    return
  end
  -- 節流2：上一次還沒跑完就不要重複發
  if git_inflight then
    return
  end
  git_inflight = true
  vim.system(
    { "git", "status", "--porcelain=v1", "--untracked-files=normal" },
    { text = true, cwd = vim.fn.getcwd() },
    function(res)
      vim.schedule(function()
        git_inflight = false
        local lines, files = {}, {}
        if res.code ~= 0 then
          lines = { "── Git 變更 ──", "", "  （不是 git repo）" }
        else
          local entries = {}
          for line in (res.stdout or ""):gmatch("[^\n]+") do
            local status, path = line:sub(1, 2), line:sub(4)
            entries[#entries + 1] = { status = status, path = path }
          end
          lines[#lines + 1] = string.format("── Git 變更 (%d) ──", #entries)
          lines[#lines + 1] = ""
          if #entries == 0 then
            lines[#lines + 1] = "  （沒有變更）"
          end
          for _, e in ipairs(entries) do
            local mark = e.status:gsub("%s", "")
            if mark == "" then
              mark = "?"
            end
            lines[#lines + 1] = string.format("%-3s %s", mark, e.path)
            files[#lines] = e.path -- 顯示行號（1-based）對應檔案
          end
        end
        -- 節流3：內容沒變就不要重畫（畫面重繪會吃 CPU）
        local joined = table.concat(lines, "\n")
        if joined == git_last_lines then
          return
        end
        git_last_lines = joined
        git_files = files
        set_lines(buf, lines)
      end)
    end
  )
end

local function sync()
  local tw = tree_win()
  if not tw then
    hide(panels.git)
    hide(panels.cheat)
    return
  end

  local width = vim.api.nvim_win_get_width(tw)
  local pos = vim.api.nvim_win_get_position(tw)
  local tree_h = vim.api.nvim_win_get_height(tw)
  local bottom = pos[1] + tree_h
  local col = pos[2]

  -- 可用高度不足時按比例縮小，保證檔案樹至少留 5 行
  local budget = math.max(0, tree_h - 5)
  local cheat_h = math.min(CHEAT_HEIGHT, budget)
  local git_h = math.min(GIT_HEIGHT, math.max(0, budget - cheat_h - 1))

  if cheat_h < 3 then
    hide(panels.git)
    hide(panels.cheat)
    return
  end

  local cheat_row = bottom - cheat_h
  place(panels.cheat, CHEAT_LINES, base_cfg(width, col, cheat_row, cheat_h))

  if git_h >= 3 then
    -- 小抄的上邊框佔一行，所以 Git 面板再往上推一行
    local git_row = cheat_row - 1 - git_h
    local first_time = panels.git.buf == nil
    place(panels.git, { "── Git 變更 ──", "", "  讀取中…" }, base_cfg(width, col, git_row, git_h))
    if first_time then
      M.refresh_git()
    end
  else
    hide(panels.git)
  end
end

---把游標移進某個面板，並設定 q 回到原視窗
---@param key "git"|"cheat"
local function focus(key)
  sync()
  local panel = panels[key]
  if not (panel.win and vim.api.nvim_win_is_valid(panel.win)) then
    return
  end
  local from = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(panel.win)
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(from) then
      vim.api.nvim_set_current_win(from)
    end
  end, { buffer = panel.buf, nowait = true })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("TreePanels", { clear = true })

  vim.api.nvim_create_autocmd({ "WinEnter", "WinClosed", "WinResized", "VimResized", "BufWinEnter" }, {
    group = group,
    callback = function()
      vim.schedule(sync)
    end,
  })

  -- 存檔、切回視窗、換目錄、切換 buffer 時立即更新
  vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "DirChanged", "BufEnter" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        M.refresh_git()
      end)
    end,
  })

  -- 定時輪詢，才抓得到「nvim 以外」改動的檔案（例如別的終端機或 AI agent 改的）。
  -- 只在面板真的顯示時才跑，且內容沒變就不重畫，避免增加 CPU 負擔。
  local timer = vim.uv.new_timer()
  if timer then
    timer:start(
      3000,
      3000,
      vim.schedule_wrap(function()
        M.refresh_git({ only_if_visible = true })
      end)
    )
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = function()
        pcall(function()
          timer:stop()
          timer:close()
        end)
      end,
    })
  end

  -- 開機時 nvim-tree 的繪製時間不固定，多排幾次重試
  for _, delay in ipairs({ 100, 300, 700 }) do
    vim.defer_fn(sync, delay)
  end

  vim.keymap.set("n", "<leader>k", function()
    focus("cheat")
  end, { desc = "移到快速鍵小抄（j/k 捲動，q 離開）" })

  vim.keymap.set("n", "<leader>gs", function()
    M.refresh_git()
    focus("git")
  end, { desc = "移到 Git 變更清單（Enter 開檔，q 離開）" })

  vim.keymap.set("n", "<leader>gr", function()
    M.refresh_git()
  end, { desc = "手動更新 Git 變更清單" })

  -- 在 Git 面板按 Enter 開啟該檔案
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "gitpanel",
    callback = function(args)
      vim.keymap.set("n", "<cr>", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local path = git_files[lnum]
        if not path then
          return
        end
        -- 找一個一般編輯視窗來開檔案
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local b = vim.api.nvim_win_get_buf(win)
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
            vim.api.nvim_set_current_win(win)
            vim.cmd("edit " .. vim.fn.fnameescape(path))
            return
          end
        end
        -- 畫面上還沒有編輯視窗（例如剛開啟資料夾）就開一個
        vim.cmd("botright vsplit " .. vim.fn.fnameescape(path))
      end, { buffer = args.buf, nowait = true, desc = "開啟這個變更的檔案" })
    end,
  })
end

M.sync = sync

return M
