return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPre",
    dependencies = { "mason.nvim", "nvim-lspconfig" },
    opts = {
      ensure_installed = { "ts_ls" },
      handlers = {
        function(server)
          require("lspconfig")[server].setup({})
        end,
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = { "nvim-lspconfig" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = buf })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf })
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf })
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf })
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = buf })
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = buf })
        end,
      })
    end,
  },
}
