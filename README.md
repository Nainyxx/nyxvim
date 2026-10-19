# nyxvim

Neovim config by Nainyxx, on lazy.nvim (no distro). Layout: file tree left, Claude Code right.

## Install

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Nainyxx/nyxvim/main/install.sh)
```

Backs up any existing `~/.config/nvim` (and Neovim data/state/cache) to `*.bak-<date>`,
clones this repo and pre-installs plugins, language servers and parsers.
Needs Neovim 0.11+ and git; the script lists any optional tools that are missing.

## Keys

- Alt+K — cheatsheet (`cheatsheet.md`), Space — all commands (which-key)
- Alt+Z / Alt+X / Alt+C — jump to file tree / code / Claude
- Alt+T — terminal, Alt+R — run current file/project
- Lines Claude changed are marked with `▍`; Space a h clears the marks

## Notes

- Autosave + format on save; LSP: Go, Python, Rust, C/C++, Lua
- Colorscheme follows the Omarchy theme (`lua/plugins/theme.lua` symlink);
  outside Omarchy the installer sets tokyonight
