-- "NYXVIM" in the ANSI Shadow font, glued letter by letter.
local function logo()
  local letters = {
    { "███╗   ██╗", "████╗  ██║", "██╔██╗ ██║", "██║╚██╗██║", "██║ ╚████║", "╚═╝  ╚═══╝" },
    { "██╗   ██╗", "╚██╗ ██╔╝", " ╚████╔╝ ", "  ╚██╔╝  ", "   ██║   ", "   ╚═╝   " },
    { "██╗  ██╗", "╚██╗██╔╝", " ╚███╔╝ ", " ██╔██╗ ", "██╔╝ ██╗", "╚═╝  ╚═╝" },
    { "██╗   ██╗", "██║   ██║", "██║   ██║", "╚██╗ ██╔╝", " ╚████╔╝ ", "  ╚═══╝  " },
    { "██╗", "██║", "██║", "██║", "██║", "╚═╝" },
    { "███╗   ███╗", "████╗ ████║", "██╔████╔██║", "██║╚██╔╝██║", "██║ ╚═╝ ██║", "╚═╝     ╚═╝" },
  }
  local rows = {}
  for row = 1, 6 do
    rows[row] = table.concat(vim.tbl_map(function(l) return l[row] end, letters))
  end
  return table.concat(rows, "\n")
end

return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
      indent = { enabled = true },
      words = { enabled = true },
      lazygit = { enabled = true },
      terminal = { enabled = true },
      -- Opened by config/autocmds.lua once the side panels are in place.
      dashboard = {
        enabled = false,
        preset = {
          header = logo(),
          keys = {
            { icon = " ", key = "f", desc = "Найти файл", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "g", desc = "Текст по проекту", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Недавние файлы", action = ":lua Snacks.picker.recent()" },
            { icon = "󰌌 ", key = "k", desc = "Шпаргалка", action = ":lua require('config.cheatsheet').toggle()" },
            { icon = "󰒲 ", key = "l", desc = "Плагины", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Выйти", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>a", group = "AI (Claude)" },
        { "<leader>b", group = "вкладки" },
        { "<leader>c", group = "код" },
        { "<leader>f", group = "поиск" },
        { "<leader>g", group = "git" },
        { "<leader>u", group = "переключатели" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        close_command = function(n)
          Snacks.bufdelete(n)
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          { filetype = "neo-tree", text = "Файлы", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto", globalstatus = true, section_separators = "", component_separators = "│" },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
      },
    },
  },
}
