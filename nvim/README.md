# Atharva Neovim Config (NvChad)

NvChad-based Neovim config with LSP, formatting, terminal, tmux navigation, and practical mappings.

## Install

```bash
git clone https://github.com/jitesh117/nvim ~/.config/nvim
nvim
```

Inside Neovim:

```vim
:MasonInstallAll
```

## LSP Servers Enabled

- `gopls`
- `pyright`
- `ruff`
- `ts_ls` (TypeScript/JavaScript)
- `html`
- `cssls`
- `tailwindcss`
- `emmet_language_server`
- `clangd`
- `elixirls`
- `bashls`
- `jsonls`
- `yamlls`
- `marksman`
- `dockerls`
- `docker_compose_language_service`

## Useful Commands

- `:Mason` open Mason package manager
- `:MasonInstallAll` install tools listed in `chadrc.lua`
- `:LspInfo` show active LSP clients
- `:checkhealth` check Neovim health
- `:Lazy` plugin manager UI
- `:Telescope find_files` fuzzy find files
- `:Telescope live_grep` grep in project

## Keybindings

Leader key: `<Space>`

General:
- `<C-h>/<C-j>/<C-k>/<C-l>` tmux navigation
- `<leader>tv` vertical terminal
- `<leader>tt` horizontal terminal
- `<leader>qs` restore session
- `<leader>ql` restore last session
- `<leader>qd` stop saving current session

LSP:
- `<leader>li` LSP info
- `<leader>lm` Mason
- `<leader>lf` floating diagnostics

Git:
- `<leader>ph` preview hunk
- `<leader>bl` blame line
- `<leader>tb` toggle line blame
- `<leader>gd` diff this
- `]h` next hunk
- `[h` previous hunk

Competitive coding helper:
- `<leader>cf` create problem folder + cpp file + tests
