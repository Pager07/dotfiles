return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Show selection count (lines, chars) when in visual mode
      table.insert(opts.sections.lualine_y, {
        function()
          local mode = vim.fn.mode()
          if mode:find("[vV\022]") then -- visual, visual-line, visual-block
            local starts = vim.fn.line("v")
            local ends = vim.fn.line(".")
            local lines = math.abs(ends - starts) + 1
            return "󰒅 " .. lines .. " lines"
          end
          return ""
        end,
      })
    end,
  },
}
