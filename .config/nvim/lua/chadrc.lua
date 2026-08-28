local options = {
  base46 = {
    integration = {
      "blankline",
      "cmp",
      "defaults",
      "devicons",
      "git",
      "lsp",
      "mason",
      "nvcheatsheet",
      "nvdash",
      "statusline",
      "syntax",
      "tbline",
      "telescope",
      "treesitter",
      "whichkey",
    },
    theme = "aylin",
    transparency = false,
    hl_override = {
      NvDashAscii = { bg = "NONE", fg = "blue" },
      NvDashButtons = { bg = "NONE", fg = "white" },
    },
  },

  nvdash = {
    load_on_startup = true,
    header = {
      [[      █████╗ ████████╗██╗  ██╗██╗   ██╗██╗   ██╗ ]],
      [[     ██╔══██╗╚══██╔══╝██║  ██║██║   ██║██║   ██║ ]],
      [[     ███████║   ██║   ███████║██║   ██║██║   ██║ ]],
      [[     ██╔══██║   ██║   ██╔══██║██║   ██║██║   ██║ ]],
      [[     ██║  ██║   ██║   ██║  ██║╚██████╔╝╚██████╔╝ ]],
      [[     ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝  ]],
      [[                                                      ]],
    },

    buttons = {
      { txt = "  Find File", keys = "f", cmd = "Telescope find_files" },
      { txt = "  Recent Files", keys = "r", cmd = "Telescope oldfiles" },
      { txt = "󰈭  Find Word", keys = "g", cmd = "Telescope live_grep" },
      { txt = "  Restore Session", keys = "s", cmd = 'lua require("persistence").load()' },
      { txt = "  Mason", keys = "m", cmd = "Mason" },
      { txt = "󰒲  Lazy", keys = "l", cmd = "Lazy" },
      { txt = "  Quit", keys = "q", cmd = "qa" },

      { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },
      {
        txt = function()
          local stats = require("lazy").stats()
          return "  " .. stats.loaded .. "/" .. stats.count .. " plugins"
        end,
        hl = "NvDashLazy",
        no_gap = true,
      },
      { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },
    },
  },

  mason = {
    pkgs = {
      "gopls",
      "gofumpt",
      "goimports",
      "goimports-reviser",
      "pyright",
      "ruff",
      "black",
      "typescript-language-server",
      "tailwindcss-language-server",
      "dockerfile-language-server",
      "docker-compose-language-service",
      "yaml-language-server",
      "json-lsp",
      "bash-language-server",
      "lua-language-server",
      "marksman",
      "prettier",
      "prettierd",
      "emmet-language-server",
    },
  },
}

return options
