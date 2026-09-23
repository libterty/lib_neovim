# Neovim 設定

用 [lazy.nvim](https://github.com/folke/lazy.nvim) 管外掛，做成接近 VSCode 的操作方式：左邊檔案樹、上面檔案分頁、Git 變更面板、內建終端機，加上 LSP 跟存檔自動格式化。

支援 Terraform、Python、TypeScript / JavaScript、SQL、Bash。

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

Git 變更和快速鍵小抄是浮動視窗，不參與版面配置，開關檔案樹時不會把版面弄亂。兩個都能用滑鼠滾輪捲動。

## 安裝

### 1. 外部相依套件

只複製 Lua 檔案不夠，這份設定會用到幾個外部執行檔：

```bash
brew install neovim ripgrep fd tree-sitter-cli lazygit
```

| 套件 | 用途 | 沒裝會怎樣 |
| --- | --- | --- |
| `neovim` | 本體，需要 0.11 以上（開發時用 0.12.5）| 無法使用 |
| `ripgrep` / `fd` | 檔案與內容搜尋 | 搜尋功能受限 |
| `tree-sitter-cli` | 編譯語法解析器 | 語法上色全部失效 |
| `lazygit` | Git 操作介面（`<leader>gg`）| 該快速鍵無作用 |

還需要 Node.js（多數 LSP 是 npm 套件）和 Git。

不需要 Nerd Font。圖示全部改用一般 Unicode 字元，終端機字型不支援特殊字符也不會變方框。

### 2. 取得設定

```bash
git clone https://github.com/libterty/lib_neovim.git ~/.config/nvim
nvim
```

第一次啟動時 lazy.nvim 會照 `lazy-lock.json` 鎖定的版本裝外掛，Mason 會自動裝下面這些工具，等它跑完就好：

- LSP：`terraform-ls`、`pyright`、`typescript-language-server`、`sqlls`、`bash-language-server`
- 格式化：`black`（Python）、`prettier`（TS/JS）、`shfmt`（Bash）、`sqlfluff`（SQL）、`terraform fmt`（需另外裝 Terraform CLI）

## 常用快速鍵

Leader 鍵是空白鍵。完整清單按 `<leader>?`，或直接看左下角的小抄面板。

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

在檔案樹上：`gy` 複製完整路徑、`Y` 複製相對路徑、`y` 複製檔名，都會進系統剪貼簿。

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

## 設計取捨

### 為什麼不直接用 `:bdelete`

Vim 的 `:bdelete` 會連帶關閉所有正在顯示該 buffer 的視窗。關掉目前在看的分頁時，編輯區視窗會跟著消失、檔案樹撐滿畫面，看起來像所有分頁都被關掉了。`safe-close.lua` 改成先把視窗切到別的檔案再刪 buffer，同時擋掉對檔案樹、小抄、終端機的誤刪（bufferline 預設的 `close_command` 不檢查對象）。

### 面板為什麼是浮動視窗

分割視窗會參與版面配置。檔案樹在開啟資料夾時佔滿整個畫面，開檔案後縮成側邊欄，這個過程會把分割出來的面板擠到奇怪的位置，實測會變成中間一整欄。浮動視窗不參與版面配置，所以不會被重排。

### nvim-tree / bufferline / toggleterm 不延遲載入

nvim-tree 要在 Neovim 處理啟動參數之前就載入，才接管得到 `nvim <目錄>` 產生的目錄 buffer，任何 lazy trigger 都會晚一步。另外兩個是核心 UI，省下的啟動時間換來鍵位時序的不確定性並不划算。

### nvim-treesitter 用 `main` 分支

`master` 分支在 2025 年公告封存，配 Neovim 0.11+ 會在語法注入時出錯，實測 markdown 會崩潰。`main` 分支需要外部的 `tree-sitter` CLI 來編譯解析器。

### Git 變更面板每 3 秒輪詢

只靠 `BufWritePost` 抓不到 nvim 以外的改動，例如其他終端機或 AI agent 改的檔案。輪詢做了三層節流：面板沒顯示不跑、上次還沒跑完不重複發、內容沒變不重畫。實測每次 `git status` 約 0.03 秒。

### terraform-ls 關掉 codelens

`nvim-lspconfig` 的 terraformls 設定會在 `on_attach` 開 codelens，但 Neovim 0.12.5 的 codelens 讀行號時沒做邊界檢查（`runtime/lua/vim/lsp/codelens.lua:248`），buffer 變短就會拋 Index out of bounds 並中斷畫面繪製，例如切分支或檔案被外部改動後自動重新載入。這裡覆蓋掉那個 `on_attach`，上游修好後可以拿掉。
