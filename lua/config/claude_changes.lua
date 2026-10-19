-- Highlight lines that changed on disk while the file was open: that is how
-- Claude Code edits land. Marks stay until the next outside change to the file
-- or until <leader>ah clears them.
local M = {}

local ns = vim.api.nvim_create_namespace("claude_changes")
local before = {}

local function set_highlights()
  vim.api.nvim_set_hl(0, "ClaudeChangeLine", { link = "DiffChange", default = true })
  vim.api.nvim_set_hl(0, "ClaudeChangeSign", { link = "DiagnosticWarn", default = true })
end

local function mark(buf, old, new)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local hunks = vim.text.diff(table.concat(old, "\n") .. "\n", table.concat(new, "\n") .. "\n", { result_type = "indices" })
  local last = vim.api.nvim_buf_line_count(buf) - 1
  for _, h in ipairs(hunks) do
    local start, count = h[3], h[4]
    if count == 0 then
      -- Pure deletion: flag the line where the removed text used to be.
      local row = math.min(start, last)
      vim.api.nvim_buf_set_extmark(buf, ns, row, 0, { sign_text = "▁", sign_hl_group = "ClaudeChangeSign", priority = 20 })
    else
      for row = start - 1, math.min(start + count - 2, last) do
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          sign_text = "▍",
          sign_hl_group = "ClaudeChangeSign",
          line_hl_group = "ClaudeChangeLine",
          priority = 20,
        })
      end
    end
  end
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

function M.setup()
  set_highlights()
  -- With autoread on, unmodified buffers reload silently and FileChangedShell
  -- never fires; the handler below does the reloading instead.
  vim.o.autoread = false
  local group = vim.api.nvim_create_augroup("claude_changes", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })

  vim.api.nvim_create_autocmd("FileChangedShell", {
    group = group,
    callback = function(args)
      if vim.v.fcs_reason == "deleted" then
        return
      end
      before[args.buf] = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
      -- Unsaved edits of your own: ask instead of silently throwing them away.
      vim.v.fcs_choice = vim.bo[args.buf].modified and "ask" or "reload"
    end,
  })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(args)
      local old = before[args.buf]
      before[args.buf] = nil
      if old then
        mark(args.buf, old, vim.api.nvim_buf_get_lines(args.buf, 0, -1, false))
      end
    end,
  })

  -- Claude runs inside Neovim, so focus never leaves it: poll for changes.
  local timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end))
end

return M
