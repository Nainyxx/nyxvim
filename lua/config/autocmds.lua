local group = vim.api.nvim_create_augroup("user", { clear = true })

-- Autosave: no :w needed.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.g.disable_autosave or not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local bo = vim.bo[buf]
    local name = vim.api.nvim_buf_get_name(buf)
    if bo.modified and bo.modifiable and not bo.readonly and bo.buftype == "" and name ~= "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! update")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- `nvim` or `nvim <dir>`: file tree on the left, Claude on the right.
-- `nvim file` (git commit messages and quick edits) opens just the file.
local function has_claude_session(dir)
  local project = vim.fn.expand("~/.claude/projects/") .. dir:gsub("[^%w]", "-")
  return #vim.fn.glob(project .. "/*.jsonl", false, true) > 0
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  nested = true,
  callback = function()
    local argv = vim.fn.argv()
    if #argv > 1 or vim.g.started_with_stdin then
      return
    end
    if #argv == 1 then
      if vim.fn.isdirectory(argv[1]) == 0 then
        return
      end
      local dirbuf = vim.api.nvim_get_current_buf()
      vim.cmd.cd(vim.fn.fnameescape(argv[1]))
      vim.cmd.enew()
      pcall(vim.api.nvim_buf_delete, dirbuf, { force = true })
    end

    local editor = vim.api.nvim_get_current_win()
    vim.cmd("Neotree show")
    if vim.fn.executable("claude") == 1 then
      vim.cmd(has_claude_session(vim.fn.getcwd()) and "ClaudeCode --continue" or "ClaudeCode")
    end
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(editor) then
        vim.api.nvim_set_current_win(editor)
        vim.cmd.stopinsert()
        Snacks.dashboard({ buf = vim.api.nvim_win_get_buf(editor), win = editor })
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("StdinReadPre", {
  group = group,
  callback = function()
    vim.g.started_with_stdin = true
  end,
})
