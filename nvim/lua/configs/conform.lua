local opts = {
  formatters_by_ft = {
    -- go stuff
    go = { "gofumpt", "goimports_reviser", "golines" },
    -- python stuff
    python = {
      "black",
    },
    -- web dev stuff
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd", "djlint" },
    markdown = { "prettierd" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    -- elixir
    elixir = { "mix" },
    eelixir = { "mix" },
    heex = { "mix" },
  },

  format_on_save = {
    -- Enable format on save
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return opts
