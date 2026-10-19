local map = vim.keymap.set

-- Neovim 0.11+ default LSP maps start with "gr"; drop them so `gr` is instant.
for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grx" }) do
  pcall(vim.keymap.del, { "n", "x" }, lhs)
end

local function terminal()
  Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } })
end

-- Alt-keys: terminal, run, cheatsheet
map({ "n", "i", "t" }, "<A-t>", terminal, { desc = "Терминал снизу" })
map({ "n", "i", "t" }, "<A-r>", function() require("config.run").run() end, { desc = "Запустить код" })
map({ "n", "i" }, "<A-k>", function() require("config.cheatsheet").toggle() end, { desc = "Шпаргалка" })

-- Alt+Z / X / C: jump to file tree / code / Claude (Alt+C is in plugins/claude.lua)
local function is_code(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local code = vim.bo[buf].buftype == "" or vim.bo[buf].filetype == "snacks_dashboard"
  return code and vim.api.nvim_win_get_config(win).relative == ""
end

local last_code_win
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if is_code(win) then
      last_code_win = win
    end
  end,
})

local function focus_code()
  if not (last_code_win and vim.api.nvim_win_is_valid(last_code_win) and is_code(last_code_win)) then
    last_code_win = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(is_code)
  end
  if last_code_win then
    vim.api.nvim_set_current_win(last_code_win)
    vim.cmd.stopinsert()
  end
end

map({ "n", "i", "t" }, "<A-z>", "<cmd>Neotree focus<cr>", { desc = "Перейти в дерево файлов" })
map({ "n", "i", "t" }, "<A-x>", focus_code, { desc = "Перейти в код" })

-- Windows: Ctrl+h/j/k/l between tree, code, terminal and Claude
map("n", "<C-h>", "<C-w>h", { desc = "Окно слева" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно снизу" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно сверху" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно справа" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Окно слева" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Окно справа" })

map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")
map("n", "<C-s>", "<cmd>write<cr>", { desc = "Сохранить" })
map({ "n", "x" }, "<C-/>", "gcc", { remap = true, desc = "Комментарий" })
map({ "n", "x" }, "<C-_>", "gcc", { remap = true, desc = "Комментарий" })

-- Files and search
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Дерево файлов" })
map("n", "<C-p>", function() Snacks.picker.files() end, { desc = "Найти файл" })
map("n", "<leader><space>", function() Snacks.picker.files() end, { desc = "Найти файл" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Файлы" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Текст по проекту" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Открытые вкладки" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Недавние файлы" })
map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Все хоткеи" })

-- Tabs (buffers)
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Вкладка слева" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Вкладка справа" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Закрыть вкладку" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Закрыть остальные" })

-- Code (LSP)
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "К определению" })
map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "Где используется" })
map("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Реализации" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Исправить / действия" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Переименовать" })
map({ "n", "x" }, "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, { desc = "Форматировать" })
map("n", "<leader>cs", function() Snacks.picker.lsp_symbols() end, { desc = "Функции в файле" })

-- Errors
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Ошибка целиком" })
map("n", "<leader>x", function() Snacks.picker.diagnostics() end, { desc = "Все ошибки проекта" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Следующая ошибка" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Предыдущая ошибка" })

-- Git
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Кто написал строку" })
map("n", "<leader>gd", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Показать изменение" })

-- Toggles
map("n", "<leader>uf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Форматирование при сохранении: " .. (vim.g.disable_autoformat and "выкл" or "вкл"))
end, { desc = "Автоформат вкл/выкл" })
map("n", "<leader>us", function()
  vim.g.disable_autosave = not vim.g.disable_autosave
  vim.notify("Автосохранение: " .. (vim.g.disable_autosave and "выкл" or "вкл"))
end, { desc = "Автосохранение вкл/выкл" })
