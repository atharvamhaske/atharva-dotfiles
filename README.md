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

## Install this dotfiles repo
```bash
# from your home directory
ln -sfn ~/bishal-dotfiles/nvim ~/.config/nvim
ln -sfn ~/bishal-dotfiles/ghostty ~/.config/ghostty
ln -sfn ~/bishal-dotfiles/zsh/.zshrc ~/.zshrc
ln -sfn ~/bishal-dotfiles/tmux/.tmux.conf ~/.tmux.conf

# codex config template is sanitized; copy manually and add your own secret key
cp ~/bishal-dotfiles/codex/config.toml.template ~/.codex/config.toml
```

## GitHub push (after `gh` re-login)
```bash
cd ~/bishal-dotfiles
git init
git add .
git commit -m "chore: add bishal dotfiles (nvim/tmux/ghostty/zsh/codex template)"
gh auth login
gh repo create bishal-dotfiles --public --source=. --remote=origin --push
```
