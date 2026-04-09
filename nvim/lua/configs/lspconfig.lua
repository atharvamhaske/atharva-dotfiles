require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

local function configure(server, opts)
  vim.lsp.config(server, vim.tbl_deep_extend("force", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }, opts or {}))
  vim.lsp.enable(server)
end

for _, server in ipairs({
  "bashls",
  "jsonls",
  "yamlls",
  "marksman",
  "dockerls",
  "docker_compose_language_service",
  "cssls",
  "html",
  "ts_ls",
  "tailwindcss",
  "emmet_language_server",
  "gopls",
  "pyright",
  "ruff",
}) do
  configure(server)
end

configure("html", {
  filetypes = { "html" },
})

configure("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true },
      gofumpt = true,
    },
  },
})

configure("pyright", {
  filetypes = { "python" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

configure("ruff", { filetypes = { "python" } })

configure("tailwindcss", {
  filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
})

configure("emmet_language_server", {
  filetypes = {
    "css",
    "eruby",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "pug",
    "typescript",
    "typescriptreact",
  },
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  callback = function()
    vim.lsp.codelens.refresh()
  end,
})
