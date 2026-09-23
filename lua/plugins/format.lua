return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      desc = "格式化目前檔案",
    },
  },
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      python = { "black" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascript = { "prettier" },
      sql = { "sqlfluff" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = true,
    },
  },
}
