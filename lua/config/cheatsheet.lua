-- Alt+K: floating cheatsheet from cheatsheet.md in the config dir.
local M = {}

local win

function M.toggle()
  if win and win:valid() then
    win:close()
    win = nil
    return
  end
  local lines = vim.fn.readfile(vim.fn.stdpath("config") .. "/cheatsheet.md")
  win = Snacks.win({
    text = lines,
    ft = "markdown",
    width = 0.6,
    height = 0.8,
    border = "rounded",
    title = " Шпаргалка ",
    title_pos = "center",
    bo = { modifiable = false },
    wo = { wrap = false, conceallevel = 0 },
    keys = { q = "close", ["<Esc>"] = "close", ["<A-k>"] = "close" },
  })
end

return M
