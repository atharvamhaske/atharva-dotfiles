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
  "clangd",
  "elixirls",
}) do
  configure(server)
end

configure("html", {
  filetypes = { "html", "heex" },
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
    "heex",
    "elixir",
    "eelixir",
  },
  init_options = {
    userLanguages = {
      elixir = "html-eex",
      eelixir = "html-eex",
      heex = "html-eex",
    },
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        elixir = "html",
        eelixir = "html",
        heex = "html",
      },
      experimental = {
        classRegex = {
          [[class: "([^"]*)]],
          [[class: '([^']*)]],
          '~H""".*class="([^"]*)".*"""',
          [[class="([^"]*)]],
        },
      },
      validate = true,
    },
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
    "heex",
  },
})

configure("clangd", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    nvlsp.on_attach(client, bufnr)
  end,
})

configure("elixirls", {
  cmd = { "elixir-ls" },
  filetypes = { "elixir", "eelixir", "heex" },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
      enableTestLenses = true,
      suggestSpecs = true,
    },
  },
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  callback = function()
    vim.lsp.codelens.refresh()
  end,
})
