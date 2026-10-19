return {
  {
    "mason-org/mason.nvim",
    lazy = false, -- puts Mason's bin dir on PATH for the servers below
    opts = { ui = { border = "rounded" } },
  },

  -- Installs servers and formatters on first start. clangd, rustfmt and
  -- clang-format come from the system packages.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "gopls", "gofumpt", "goimports",
        "pyright", "ruff",
        "rust-analyzer",
        "lua-language-server", "stylua",
      },
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
      vim.cmd("MasonToolsInstall")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } } } },
      })
      vim.lsp.config("gopls", {
        settings = { gopls = { gofumpt = true, staticcheck = true } },
      })
      vim.lsp.enable({ "gopls", "pyright", "ruff", "rust_analyzer", "clangd", "lua_ls" })
    end,
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        lua = { "stylua" },
      },
      format_on_save = function()
        if vim.g.disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}
