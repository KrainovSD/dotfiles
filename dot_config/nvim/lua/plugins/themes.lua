return {
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        transparent_mode = false,
        italic = {
          strings = false,
          comments = true,
        },
        contrast = "hard",
      })
    end,
  },
  -- { "morhetz/gruvbox" },
  -- { "folke/tokyonight.nvim" },
  -- { "rebelot/kanagawa.nvim" },
  -- { "sainnhe/everforest" },
}
