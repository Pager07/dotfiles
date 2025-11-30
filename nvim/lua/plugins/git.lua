return {
  -- vim-fugitive for full Git integration (blame sidebar, etc.)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gB", "<cmd>Git blame<cr>", desc = "Blame (full sidebar)" },
    },
  },

  -- Enhance gitsigns with better keybindings
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = false, -- toggle with <leader>gb
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    },
    keys = {
      { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gl", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line (popup)" },
    },
  },
}
