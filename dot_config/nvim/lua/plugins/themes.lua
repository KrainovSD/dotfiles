return {
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        transparent_mode = true,
        italic = {
          strings = false,
          comments = true,
        },
        contrast = "hard",
      })
      --            vim.cmd.colorscheme("gruvbox")
    end,
  },
  {
    "folke/tokyonight.nvim",
  },
}
