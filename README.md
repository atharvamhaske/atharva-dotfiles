# Atharva Dotfiles

One repo for terminal + editor setup:
- Neovim config
- Ghostty config
- Zsh config
- tmux config
- Codex config template (sanitized)

## Why sidebar was not visible in Neovim
Your setup was using `oil.nvim` as a floating explorer, not a permanent left tree.

I changed your local Neovim mapping:
- `<leader>e` -> open Oil in left sidebar (`:Oil --left`)
- `-` -> toggle floating Oil window
- `<leader>E` -> toggle floating Oil window

## Key Commands
- Open sidebar: `<leader>e`
- Open floating explorer: `-` or `<leader>E`
- Outline symbols: `<leader>o`
- Find files: `<leader>ff`
- Live grep: `<leader>fg`
- LazyGit: `<leader>lg`
- Harpoon add file: `<leader>H`
- Harpoon menu: `<leader>h`
- Trouble diagnostics: `<leader>xx`
- Toggle undo tree: `<leader>u`

## tmux keys (from `tmux/.tmux.conf`)
- Prefix: `Ctrl+a`
- Split horizontal: `Prefix` then `|`
- Split vertical: `Prefix` then `-`
- Move panes: `Prefix` then `h/j/k/l`
- Reload tmux config: `Prefix` then `r`


