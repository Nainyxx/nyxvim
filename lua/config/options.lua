-- Omarchy: clipboard over SSH/tmux.
require("config.remote_clipboard").setup()

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false -- lualine shows the mode
opt.laststatus = 3 -- one statusline for all windows
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.mouse = "a"
opt.clipboard = "unnamedplus" -- yank/paste use the system clipboard

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.swapfile = false -- autosave makes swap files pointless
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

-- Errors are shown right next to the code, no clicking required.
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})
