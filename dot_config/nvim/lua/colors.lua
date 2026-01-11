function SetColor(color)
    color = color or "onedark"
    vim.cmd.colorscheme(color)
end

-- tokyonight, gruvbox
SetColor("gruvbox")
