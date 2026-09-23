# Neovim 設定

以 [lazy.nvim](https://github.com/folke/lazy.nvim) 管理外掛，目標是接近 VSCode 的使用手感：左側檔案樹、上方檔案分頁、Git 變更面板、內建終端機、LSP 與自動格式化。

支援語言：Terraform、Python、TypeScript / JavaScript、SQL、Bash。

## 畫面配置

```
┌──────────────┬────────────────────────────────┐
│              │  分頁列（可點擊切換 / 關閉）      │
│   檔案樹      ├────────────────────────────────┤
│              │                                │
│              │          編輯區                 │
├──────────────┤                                │
│  Git 變更     │                                │
├──────────────┤                                │
│  快速鍵小抄   │                                │
└──────────────┴────────────────────────────────┘
```

Git 變更與快速鍵小抄都是浮動視窗（不參與版面配置，所以不會在開關檔案樹時造成版面錯亂），兩者都可以用滑鼠滾輪捲動。

## 安裝

### 1. 外部相依套件

這份設定依賴幾個外部執行檔，只複製 Lua 檔案是不夠的：

```bash
brew install neovim ripgrep fd tree-sitter-cli lazygit
```

| 套件 | 用途 | 沒裝會怎樣 |
| --- | --- | --- |
| `neovim` | 本體，需要 **0.11 以上**（開發時用 0.12.5）| 無法使用 |
| `ripgrep` / `fd` | 檔案與內容搜尋 | 搜尋功能受限 |
| `tree-sitter-cli` | 編譯語法解析器 | 語法上色全部失效 |
| `lazygit` | Git 操作介面（`<leader>gg`）| 該快速鍵無作用 |

另外需要 **Node.js**（多數 LSP 是 npm 套件）與 **Git**。

> 不需要 Nerd Font。所有圖示都刻意改用一般 Unicode 字元，終端機字型不支援特殊字符也不會出現方框。

### 2. 取得設定

```bash
git clone https://github.com/libterty/lib_neovim.git ~/.config/nvim
nvim
```

第一次啟動時，lazy.nvim 會依 `lazy-lock.json` 鎖定的版本安裝外掛，Mason 會自動安裝下列工具，等它跑完即可：

- **LSP**：`terraform-ls`、`pyright`、`typescript-language-server`、`sqlls`、`bash-language-server`
- **格式化**：`black`（Python）、`prettier`（TS/JS）、`shfmt`（Bash）、`sqlfluff`（SQL）、`terraform fmt`（需另外安裝 Terraform CLI）

## 常用快速鍵

Leader 鍵是**空白鍵**。完整清單可按 `<leader>?`，或直接看畫面左下角的小抄面板。

| 按鍵 | 功能 |
| --- | --- |
| `<leader>e` | 開關檔案樹 |
| `<leader>f` | 格式化目前檔案（存檔時也會自動格式化）|
| `Shift-h` / `Shift-l` | 切換上一個 / 下一個分頁 |
| `<leader>bd` | 關閉目前分頁（有未存檔內容會先詢問）|
| `Ctrl-t` | 開關下方終端機 |
| `Ctrl-g` | 開啟 Lazygit |
| `<leader>gs` | 移到 Git 變更面板（`Enter` 開檔）|
| `<leader>gr` | 手動更新 Git 變更清單 |
| `<leader>k` | 移到快速鍵小抄面板 |
| `gd` / `gr` / `K` | 跳到定義 / 找引用 / 查看說明 |
| `<leader>rn` / `<leader>ca` | 重新命名 / 修正建議 |
| `gcc` / `gc` | 註解整行 / 註解選取範圍 |

在檔案樹上：`gy` 複製完整路徑、`Y` 複製相對路徑、`y` 複製檔名（都會進系統剪貼簿）。

## 檔案結構

```
init.lua                      進入點：leader 鍵、停用 netrw、載入各模組
lua/config/
  options.lua                 編輯器選項、外部改動自動重新載入
  keymaps.lua                 與外掛無關的基本鍵位
  lazy.lua                    lazy.nvim bootstrap
  tree-panels.lua             Git 變更面板 + 快速鍵小抄（浮動視窗）
  cheatsheet.lua              <leader>ch 的浮動快速鍵清單
  safe-close.lua              安全關閉分頁
lua/plugins/                  各外掛設定，一個檔案一個主題
```

## 幾個刻意的設計決定

**`safe-close.lua` — 為什麼不直接用 `:bdelete`**

Vim 的 `:bdelete` 會連帶關閉所有正在顯示該 buffer 的視窗。關掉目前正在看的分頁時，編輯區視窗會直接消失、檔案樹撐滿畫面，看起來像所有分頁都被關掉。這裡改成先把視窗切到別的檔案再刪 buffer。同時擋下對檔案樹、小抄、終端機的誤刪（bufferline 預設的 `close_command` 不檢查對象）。

**面板用浮動視窗而不是分割視窗**

分割視窗會參與版面配置。檔案樹在開啟資料夾時佔滿整個畫面、開檔案後縮成側邊欄，這個過程會讓分割出來的面板被擠到奇怪的位置（實測會變成中間一整欄）。浮動視窗不參與版面配置，所以不可能造成重排。

**nvim-tree / bufferline / toggleterm 不延遲載入**

nvim-tree 需要在 Neovim 處理啟動參數之前就載入，才能接管 `nvim <目錄>` 產生的目錄 buffer；任何 lazy trigger 都會晚一步。另外兩個是核心 UI，延遲載入帶來的啟動時間差不值得換取鍵位時序的不確定性。

**nvim-treesitter 使用 `main` 分支**

`master` 分支已於 2025 年公告封存，與 Neovim 0.11+ 搭配會在語法注入時出錯（實測 markdown 會崩潰）。`main` 分支需要外部的 `tree-sitter` CLI 來編譯解析器。

**Git 變更面板每 3 秒輪詢**

只靠 `BufWritePost` 抓不到 nvim 以外的改動（例如其他終端機或 AI agent 改的檔案）。輪詢有三層節流：面板沒顯示不跑、上次未完成不重複發、內容沒變不重畫。實測每次 `git status` 約 0.03 秒。
