return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
      },
    },
    keys = {
      { "<A-c>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "i", "t" }, desc = "Перейти в Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Показать/спрятать" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Перейти в Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Выбрать старую сессию" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Добавить текущий файл" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Отправить выделенное" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Добавить файл", ft = "neo-tree" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Принять правку" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Отклонить правку" },
    },
  },
}
