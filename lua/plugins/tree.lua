return {
  "nvim-tree/nvim-tree.lua",
  -- 例外：nvim-tree 要接管 `nvim <dir>` 產生的初始目錄 buffer，
  -- 這發生在 VimEnter 之前，任何 lazy trigger 都會晚一步，故不延遲載入
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "切換檔案樹" },
  },
  opts = {
    hijack_netrw = true,
    sync_root_with_cwd = true,
    view = { width = 32 },
    renderer = {
      group_empty = true,
      -- 不依賴 Nerd Font：檔案/資料夾一律用純文字符號，避免終端機字型不支援時顯示成方框
      icons = {
        git_placement = "before",
        show = { git = true, folder = true, file = false, folder_arrow = true },
        glyphs = {
          folder = {
            arrow_closed = ">",
            arrow_open = "v",
            default = "▸",
            open = "▾",
            empty = "▸",
            empty_open = "▾",
            symlink = "▸",
            symlink_open = "▾",
          },
          git = {
            unstaged = "M",
            staged = "S",
            unmerged = "U",
            renamed = "R",
            untracked = "?",
            deleted = "D",
            ignored = "-",
          },
        },
      },
    },
    git = { enable = true, ignore = false },
    filters = { dotfiles = false },
    actions = {
      open_file = {
        window_picker = { enable = false },
      },
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)
    require("config.tree-panels").setup()
  end,
}
