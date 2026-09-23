local parsers = {
  "terraform",
  "hcl",
  "python",
  "typescript",
  "tsx",
  "javascript",
  "sql",
  "bash",
  "json",
  "yaml",
  "dockerfile",
  "markdown",
  "markdown_inline",
  "lua",
  "vim",
  "vimdoc",
}

local filetypes = {
  "terraform",
  "hcl",
  "python",
  "typescript",
  "typescriptreact",
  "javascript",
  "sql",
  "sh",
  "bash",
  "json",
  "yaml",
  "dockerfile",
  "markdown",
  "lua",
  "vim",
  "help",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function()
        -- 部分 parser 可能還沒編譯完成，失敗就跳過，不擋開檔
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
