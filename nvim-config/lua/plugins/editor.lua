return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night" },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.config",
    opts = {
      ensure_installed = { "c_sharp", "typescript", "javascript", "tsx", "json", "lua" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter" },
    event = "BufReadPost",
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>z", "<cmd>Yazi<CR>", desc = "Open yazi file manager" },
    },
    opts = {
      open_for_directories = false,
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>fe", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = true },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fd", "<cmd>Telescope find_files hidden=true<CR>", desc = "Find hidden files" },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open diffview" },
      { "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
    },
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = false,
    },
    keys = {
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Next git hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev git hunk" },
      { "<leader>hs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk", mode = { "n", "v" } },
      { "<leader>hr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk", mode = { "n", "v" } },
      { "<leader>hS", function() require("gitsigns").stage_buffer() end, desc = "Stage buffer" },
      { "<leader>hu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
      { "<leader>hR", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },
      { "<leader>hp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
      { "<leader>hb", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle line blame" },
      { "<leader>hd", function() require("gitsigns").diffthis() end, desc = "Diff this" },
      { "<leader>hD", function() require("gitsigns").diffthis("~") end, desc = "Diff this ~" },
      { "<leader>ht", function() require("gitsigns").toggle_deleted() end, desc = "Toggle deleted" },
      { "ih", function() require("gitsigns").select_hunk() end, mode = { "o", "x" }, desc = "Select hunk" },
    },
  },
}
