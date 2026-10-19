-- Alt+R: save and run the current file/project in the bottom terminal (Alt+T).
local M = {}

local last_cmd

local function q(path)
  return vim.fn.shellescape(path)
end

local function build_cmd()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return nil, "Файл не сохранён"
  end
  local dir = vim.fs.dirname(file)
  local name = vim.fn.fnamemodify(file, ":t:r")
  local out = vim.fn.stdpath("cache") .. "/run/" .. name
  local ft = vim.bo.filetype

  if ft == "go" then
    if file:match("_test%.go$") then
      return ("cd %s && go test ."):format(q(dir))
    end
    return ("cd %s && go run ."):format(q(dir))
  elseif ft == "rust" then
    local root = vim.fs.root(0, "Cargo.toml")
    if root then
      return ("cd %s && cargo run"):format(q(root))
    end
    return ("mkdir -p %s && rustc %s -o %s && %s"):format(q(vim.fs.dirname(out)), q(file), q(out), q(out))
  elseif ft == "python" then
    local root = vim.fs.root(0, { ".venv", "pyproject.toml", ".git" }) or dir
    local py = vim.uv.fs_stat(root .. "/.venv/bin/python") and (root .. "/.venv/bin/python") or "python3"
    return ("cd %s && %s %s"):format(q(root), q(py), q(file))
  elseif ft == "c" or ft == "cpp" then
    local root = vim.fs.root(0, "Makefile")
    if root then
      return ("cd %s && make"):format(q(root))
    end
    local cc = ft == "c" and "gcc -std=c17" or "g++ -std=c++20"
    return ("mkdir -p %s && %s -Wall -g %s -o %s && %s"):format(q(vim.fs.dirname(out)), cc, q(file), q(out), q(out))
  elseif ft == "sh" or ft == "bash" then
    return ("bash %s"):format(q(file))
  elseif ft == "lua" then
    return ("nvim -l %s"):format(q(file))
  end
  return nil, "Не знаю, как запускать «" .. ft .. "»"
end

local function send(cmd)
  local term = Snacks.terminal.get(nil, { win = { position = "bottom" } })
  if not term then
    return
  end
  if not term:valid() then
    term:show()
  end
  local chan = vim.bo[term.buf].channel
  -- Subshell keeps `cd` from moving the terminal's own working directory.
  vim.fn.chansend(chan, "clear; (" .. cmd .. ")\r")
  term:focus()
  vim.cmd.startinsert()
end

function M.run()
  if vim.bo.buftype == "" then
    vim.cmd("silent! wall")
    local cmd, err = build_cmd()
    if not cmd then
      return vim.notify(err, vim.log.levels.WARN)
    end
    last_cmd = cmd
  elseif not last_cmd then
    return vim.notify("Сначала нажмите Alt+R в файле с кодом", vim.log.levels.WARN)
  end
  send(last_cmd)
end

return M
