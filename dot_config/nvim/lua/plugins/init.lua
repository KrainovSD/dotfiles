return {
  -- autoclose
  {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        keys = {
          ["("] = { escape = false, close = true, pair = "()" },
          ["["] = { escape = false, close = true, pair = "[]" },
          ["{"] = { escape = false, close = true, pair = "{}" },

          [">"] = { escape = true, close = false, pair = "<>" },
          [")"] = { escape = true, close = false, pair = "()" },
          ["]"] = { escape = true, close = false, pair = "[]" },
          ["}"] = { escape = true, close = false, pair = "{}" },

          ['"'] = { escape = true, close = true, pair = '""' },
          ["'"] = { escape = true, close = true, pair = "''" },
          ["`"] = { escape = true, close = true, pair = "``" },
        },
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  -- clibboard ssh
  {
    "ojroques/vim-oscyank",
    cond = function()
      return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
    end,
    config = function()
      vim.api.nvim_create_autocmd("TextYankPost", {
        pattern = "*",
        desc = "Copy to system clipboard via OSC52",
        callback = function()
          local event = vim.v.event
          if event.operator == "y" and (event.regname == "" or event.regname == "+" or event.regname == "*") then
            local reg = event.regname == "" and '"' or event.regname
            vim.cmd("OSCYankRegister " .. reg)
          end
        end,
      })
    end,
  },

  -- spell checker
  -- {
  --   "lewis6991/spellsitter.nvim",
  --   config = function()
  --     require("spellsitter").setup({
  --       enable = true,
  --       debug = true,
  --       additional_vim_regex_highlighting = false,
  --     })
  --     vim.cmd([[set spell]])
  --     vim.cmd([[set spelllang=ru,en]])
  --   end,
  -- },

  -- mass change escape
  {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    -- event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- hierarchy symantic navigation for line plugin
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
    end,
    config = function()
      require("nvim-navic").setup({
        separator = " > ",
        highlight = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("NavicAttach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        end,
      })
    end,
  },

  -- line info in first row
  {
    "b0o/incline.nvim",
    config = function()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = {
              guibg = "#3c3836", -- dark1 в gruvbox
              guifg = "#ebdbb2", -- light1 в gruvbox
            },
            InclineNormalNC = {
              guibg = "#504945", -- dark2 в gruvbox
              guifg = "#a89984", -- light4 в gruvbox
            },
          },
        },
        window = {
          margin = { vertical = 0, horizontal = 1 },
        },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and " [+]" or ""
          local readonly = vim.api.nvim_buf_get_option(props.buf, "readonly") and " [RO]" or ""
          local response = {
            { icon, guifg = color },
            { " " },
            { filename },
            { modified },
            { readonly },
          }
          local symantic_location = require("nvim-navic").get_data(props.buf) or {}
          if props.focused then
            for _, item in ipairs(symantic_location) do
              table.insert(response, {
                { " > ", group = "NavicSeparator" },
                { item.icon, group = "NavicIcons" .. item.type },
                { item.name, group = "NavicText" },
              })
            end
          end
          table.insert(response, " ")
          return response
        end,
      })
    end,
    event = "VeryLazy",
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      local text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require("ufo").setup({
        fold_virt_text_handler = text_handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
        open_fold_hl_timeout = 150,
        close_fold_kinds_for_ft = { default = { "imports", "comment" } },
      })
    end,
  },

  -- status line under buffers
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
          icons_enabled = true,
          -- component_separators = { left = "", right = "" },
          -- section_separators = { left = "", right = "" },
          disabled_filetypes = { "NvimTree", "TelescopePrompt", "packer", "toggleterm", "neotree", "neo-tree" },
          always_divide_middle = true,
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = { "neo-tree" },
      })
    end,
  },

  -- todo highlight
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- check nvim perfomance on startup
  {
    "dstein64/vim-startuptime",
  },

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({})
    end,
  },

  -- tagbar with variables, methods, funcs
  {
    "preservim/tagbar",
  },

  -- tagbar with variables, method, funcs with lsp
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- split working, swap splits, move cursor in other buffers, resizing
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("smart-splits").setup({})
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
    end,
  },

  -- auto comment
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = {
      -- pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      pre_hook = function(ctx)
        return require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()(ctx)
      end,
    },
  },

  -- git last commit per line info, reset hunks, view hunk diff in line and file diff
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 500,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
      })
    end,
  },

  -- git diff mode
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = "diff2_horizontal", -- или "diff2_vertical"
          },
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
      })
    end,
  },

  {
    "tpope/vim-fugitive",
    config = function() end,
  },

  -- multi cursor
  {
    "mg979/vim-visual-multi",
    config = function()
      vim.g.VM_maps["Find Under"] = "<C-d>"
      vim.g.VM_maps["Find Subword Under"] = "<C-d>"
      vim.g.VM_maps["Select Cursor Down"] = "<C-j>"
    end,
  },

  -- store sessions
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({})
    end,
  },

  -- tabs line for opened buffers
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
    end,
  },

  -- delete buffer for tabs
  {
    "famiu/bufdelete.nvim",
  },

  -- markdown render
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  -- image preview. not working for mewith neotree
  {
    "folke/snacks.nvim",
    enabled = false,
    opts = {
      image = {},
    },
  },

  -- better image preview
  -- {
  --     "3rd/image.nvim",
  --     enabled = true,
  --     opts = {},
  -- },

  -- file tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim",
      "folke/snacks.nvim",
    },
    config = function()
      require("neo-tree").setup({
        clipboard = {
          sync = "universal",
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
        window = {
          mappings = {
            ["P"] = {
              "toggle_preview",
              config = {
                use_float = false,
                -- use_image_nvim = true,
                -- use_snacks_image = false,
                use_snacks_image = true,
                -- title = 'Neo-tree Preview',
              },
            },
          },
        },
      })
    end,
  },

  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({})
    end,
  },

  -- search
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<c-t>"] = require("trouble.sources.telescope").open,
            },
            n = {
              ["<c-t>"] = require("trouble.sources.telescope").open,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- check npm package versions
  {
    "vuki656/package-info.nvim",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require("package-info").setup({
        autostart = false,
      })
    end,
  },
}
