return {
  -- Import LazyVim's Python extras (includes pyright, ruff, etc.)
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Auto-select venv from project root
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
}
