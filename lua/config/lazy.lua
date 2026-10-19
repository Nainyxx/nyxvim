local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, notify = false },
  -- Omarchy swaps plugins/theme.lua on theme change; lazy picks that up and
  -- fires LazyReload, which plugins/omarchy-theme-hotreload.lua handles.
  change_detection = { notify = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})

-- Omarchy theme files name the colorscheme in a LazyVim spec; read it from there.
local function omarchy_colorscheme()
  local ok, spec = pcall(require, "plugins.theme")
  if not ok then
    return
  end
  for _, s in ipairs(spec) do
    if s[1] == "LazyVim/LazyVim" and s.opts and s.opts.colorscheme then
      return s.opts.colorscheme
    end
  end
end

if not pcall(vim.cmd.colorscheme, omarchy_colorscheme() or "habamax") then
  vim.cmd.colorscheme("habamax")
end
