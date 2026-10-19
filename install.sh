#!/usr/bin/env bash
# nyxvim installer.
#   bash <(curl -fsSL https://raw.githubusercontent.com/Nainyxx/nyxvim/main/install.sh)
# Backs up an existing Neovim setup, clones nyxvim into ~/.config/nvim and
# pre-installs plugins, parsers and language servers.
set -euo pipefail

REPO="${NYXVIM_REPO:-https://github.com/Nainyxx/nyxvim.git}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
OMARCHY_THEME="$HOME/.local/state/omarchy/current/theme/neovim.lua"

info() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }
die() { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

# --- requirements ------------------------------------------------------------
command -v git >/dev/null || die "git is required"
command -v nvim >/dev/null || die "Neovim 0.11+ is required"
nvim --headless -c 'if !has("nvim-0.11") | cquit | endif' -c qa 2>/dev/null ||
  die "Neovim 0.11+ is required (found $(nvim --version | head -1))"

missing=()
for tool in rg fd lazygit gcc make curl unzip tree-sitter npm go python3 cargo claude; do
  command -v "$tool" >/dev/null || missing+=("$tool")
done
if ((${#missing[@]})); then
  warn "Optional tools not found: ${missing[*]}"
  warn "  rg/fd: search, lazygit: git UI, gcc/make/tree-sitter: syntax parsers,"
  warn "  npm/go/python3/cargo: language servers and Alt+R, claude: Claude Code panel"
  if command -v pacman >/dev/null; then
    warn "  Arch: sudo pacman -S --needed ripgrep fd lazygit base-devel curl unzip tree-sitter-cli npm go python rust"
  fi
fi

# --- back up the current setup -----------------------------------------------
if [[ -d $CONFIG/.git ]] && git -C "$CONFIG" remote get-url origin 2>/dev/null | grep -q 'Nainyxx/nyxvim'; then
  info "nyxvim is already installed, updating"
  git -C "$CONFIG" pull --ff-only
else
  stamp=$(date +%Y%m%d-%H%M%S)
  for dir in "$CONFIG" "$DATA" "$STATE" "$CACHE"; do
    if [[ -e $dir ]]; then
      mv "$dir" "$dir.bak-$stamp"
      info "Backed up $dir -> $dir.bak-$stamp"
    fi
  done
  info "Cloning nyxvim into $CONFIG"
  git clone "$REPO" "$CONFIG"
fi

# --- theme: follow Omarchy if present, otherwise a fixed colorscheme ---------
if [[ ! -e $OMARCHY_THEME ]]; then
  info "Omarchy not found, using tokyonight"
  theme="$CONFIG/lua/plugins/theme.lua"
  rm -f "$theme"
  cat >"$theme" <<'EOF'
return {
  { "folke/tokyonight.nvim" },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
}
EOF
  # Keep this local replacement out of `git status`.
  git -C "$CONFIG" update-index --skip-worktree lua/plugins/theme.lua
fi

# --- pre-install everything --------------------------------------------------
info "Installing plugins"
timeout 600 nvim --headless "+Lazy! sync" +qa || warn "Plugin install did not finish, it will continue on first start"

info "Installing language servers and formatters"
timeout 900 nvim --headless \
  -c "lua require('lazy').load({ plugins = { 'mason-tool-installer.nvim' } })" \
  -c "MasonToolsInstallSync" -c qa ||
  warn "Mason did not finish, it will continue on first start"

if command -v tree-sitter >/dev/null; then
  info "Compiling syntax parsers"
  timeout 600 nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'nvim-treesitter' } })" \
    -c "lua require('nvim-treesitter').install(require('config.parsers')):wait(500000)" \
    -c qa || warn "Parsers did not finish, they will compile on first start"
fi

info "Done. Run nvim, press Alt+K for the cheatsheet."
