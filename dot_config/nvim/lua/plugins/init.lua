local function autoclose()
  return {
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
  }
end

local function clipboard_in_ssh()
  return {
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
  }
end

local function ts_autotag()
  return {
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
  }
end

local function surround()
  return {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = false,
          insert_line = false,
          normal = "<leader>as",
          normal_cur = false,
          normal_line = false,
          normal_cur_line = false,
          visual = "as",
          visual_line = false,
          delete = "ds",
          change = "cs",
        },
      })
    end,
  }
end

local function file_info_incline()
  return {
    -- hierarchy symantic navigation for line plugin
    navic = {
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
    incline = {
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
  }
end

local function fold_ufo()
  return {
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

      vim.keymap.set("n", "zr", function()
        local ufo = require("ufo")
        ufo.closeFoldsWith(1)
      end)
      vim.keymap.set("n", "zo", function()
        local ufo = require("ufo")
        ufo.openAllFolds()
      end)
      vim.keymap.set("n", "zc", function()
        local ufo = require("ufo")
        ufo.closeAllFolds()
      end)
      vim.keymap.set("n", "z", function()
        local ufo = require("ufo")
        local winid = ufo.peekFoldedLinesUnderCursor()
        if winid then
          vim.api.nvim_win_close(winid, true)
        end
        vim.cmd("normal! za")
      end)
      vim.keymap.set("n", "Z", function()
        local ufo = require("ufo")
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end)
    end,
  }
end

local function status_line()
  return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function get_short_cwd()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      end

      require("lualine").setup({
        options = {
          theme = "gruvbox",
          icons_enabled = true,
          -- component_separators = { left = "", right = "" },
          -- section_separators = { left = "", right = "" },
          -- disabled_filetypes = { "NvimTree", "TelescopePrompt", "packer", "toggleterm", "neotree", "neo-tree" },
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
        extensions = {
          {
            filetypes = { "neo-tree" },
            sections = {
              lualine_a = { "mode" },
              lualine_b = { "branch" },
              lualine_c = { get_short_cwd },
              lualine_x = { "encoding", "fileformat", "filetype" },
              lualine_y = { "progress" },
              lualine_z = { "location" },
            },
          },
        },
      })
    end,
  }
end

local function todo_comments()
  return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  }
end

local function check_startup_performance()
  return {
    "dstein64/vim-startuptime",
  }
end

local function terminal()
  return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({})
      vim.keymap.set({ "n", "t" }, "<leader>sh", "<cmd>ToggleTerm<CR>")
    end,
  }
end

local function tagbar()
  -- vim.keymap.set("n", "<leader>tg", ":Tagbar toggle<CR>", opts)
  -- return {
  --   "preservim/tagbar",
  -- }

  return {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup({})
      vim.keymap.set("n", "<leader>at", "<cmd>AerialNavToggle<CR>")
      vim.keymap.set("n", "<leader>ft", function()
        return require("aerial").snacks_picker()
      end, { desc = "telescope help tags" })
    end,
  }
end

local function smart_splits()
  return {
    "mrjones2014/smart-splits.nvim",
    config = function()
      local sp = require("smart-splits")
      sp.setup({})
      vim.keymap.set({ "n", "t" }, "<A-Left>", sp.resize_left)
      vim.keymap.set({ "n", "t" }, "<A-Right>", sp.resize_right)
      vim.keymap.set({ "n", "t" }, "<A-Down>", sp.resize_down)
      vim.keymap.set({ "n", "t" }, "<A-Up>", sp.resize_up)

      vim.keymap.set({ "n", "t" }, "<leader>mh", sp.swap_buf_left)
      vim.keymap.set({ "n", "t" }, "<leader>ml", sp.swap_buf_right)
      vim.keymap.set({ "n", "t" }, "<leader>mj", sp.swap_buf_down)
      vim.keymap.set({ "n", "t" }, "<leader>mk", sp.swap_buf_up)

      -- vim.keymap.set({ "n", "t" }, "<C-h>", sp.move_cursor_left)
      -- vim.keymap.set({ "n", "t" }, "<C-l>", sp.move_cursor_right)
      -- vim.keymap.set({ "n", "t" }, "<C-j>", sp.move_cursor_down)
      -- vim.keymap.set({ "n", "t" }, "<C-k>", sp.move_cursor_up)
    end,
  }
end

local function auto_comment()
  return {
    tsx = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      config = function()
        require("ts_context_commentstring").setup({ enable_autocmd = false })
      end,
    },

    core = {
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
  }
end

local function git()
  return {
    signs = {
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
        local gs = require("gitsigns")
        vim.keymap.set("n", "<leader>dpl", gs.preview_hunk_inline)
        vim.keymap.set("n", "<leader>dr", gs.reset_hunk)
        vim.keymap.set("n", "<leader>dbv", gs.preview_hunk)
      end,
    },

    diff = {
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
        vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>")
        vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>")
        vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory<CR>")
      end,
    },

    git = {
      "tpope/vim-fugitive",
      config = function()
        vim.keymap.set("n", "<leader>G", function()
          vim.cmd.Git()
        end)
      end,
    },
  }
end

local function multicursor()
  return {
    "mg979/vim-visual-multi",
    config = function()
      -- vim.g.VM_maps["Find Under"] = "<C-d>"
      -- vim.g.VM_maps["Find Subword Under"] = "<C-d>"
      -- vim.g.VM_maps["Select Cursor Down"] = "<C-j>"
      vim.keymap.set("n", "<C-m>", "<Plug>(VM-Find-Under)")
      vim.keymap.set("v", "<C-m>", "<Plug>(VM-Find-Subword-Under)")
      vim.keymap.set("n", "<C-S-j>", "<Plug>(VM-Add-Cursor-Down)")
      vim.keymap.set("n", "<C-S-K>", "<Plug>(VM-Add-Cursor-Up)")
    end,
  }
end

local function sessions()
  return {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({})
    end,
  }
end

local function tabs()
  return {
    tabs = {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        vim.opt.termguicolors = true
        local bufferline = require("bufferline")
        local italic = false
        local transparent = false
        local bg = transparent and "none" or "#282828"
        local colorscheme = {
          standardWhite = "#fbf1c7",
          standardBlack = "#1d2021",
          editorBackground = transparent and "none" or "#1d2021",
          sidebarBackground = "#282828",
          popupBackground = "#3c3836",
          floatingWindowBackground = "#504945",
          menuOptionBackground = "#3c3836",
          mainText = "#ebdbb2",
          emphasisText = "#fbf1c7",
          commandText = "#ebdbb2",
          inactiveText = "#665c54",
          disabledText = "#928374",
          lineNumberText = "#7c6f64",
          selectedText = "#282828",
          inactiveSelectionText = "#665c54",
          windowBorder = "#3c3836",
          focusedBorder = "#504945",
          emphasizedBorder = "#665c54",
          specialValue = "#8ec07c",
          syntaxError = "#fb4934",
          syntaxFunction = "#83a598",
          warningText = "#fabd2f",
          syntaxKeyword = "#d3869b",
          linkText = "#83a598",
          stringText = "#b8bb26",
          warningEmphasis = "#fabd2f",
          successText = "#b8bb26",
          errorText = "#fb4934",
          specialKeyword = "#fe8019",
          commentText = "#928374",
          syntaxOperator = "#ebdbb2",
          foregroundEmphasis = "#fbf1c7",
          terminalGray = "#7c6f64",
        }
        require("bufferline").setup({
          options = {
            mode = "buffers",
            separator_style = "slant",
            numbers = "ordinal",
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
              local icon = level:match("error") and " " or " "
              return " " .. icon .. count
            end,
            offsets = {
              {
                filetype = "neo-tree",
                text = "Neo-tree",
                highlight = "Directory",
                text_align = "left",
              },
            },
            style_preset = bufferline.style_preset.no_italic,
            color_icons = true,
            show_buffer_icons = true,
            show_buffer_close_icons = true,
            show_close_icon = false,
          },
          highlights = {
            background = { bg = bg },
            buffer_visible = { fg = colorscheme.lineNumberText, bg = bg },
            buffer_selected = {
              fg = colorscheme.mainText,
              bg = colorscheme.editorBackground,
            },
            duplicate = {
              fg = colorscheme.mainText,
              bg = bg,
              italic = italic,
            },
            duplicate_visible = {
              fg = colorscheme.mainText,
              bg = bg,
              italic = italic,
            },
            duplicate_selected = {
              fg = colorscheme.mainText,
              bg = colorscheme.editorBackground,
              italic = italic,
            },

            tab = { fg = colorscheme.mainText, bg = bg },
            tab_selected = {
              fg = colorscheme.mainText,
              bg = colorscheme.editorBackground,
            },
            tab_close = { fg = colorscheme.syntaxError, bg = bg },
            indicator_selected = {
              fg = colorscheme.syntaxFunction,
              bg = colorscheme.editorBackground,
              bold = true,
            },

            separator = { fg = colorscheme.editorBackground, bg = bg },
            separator_selected = {
              fg = colorscheme.editorBackground,
              bg = colorscheme.editorBackground,
            },
            separator_visible = { fg = colorscheme.editorBackground, bg = bg },
            offset_separator = { fg = colorscheme.editorBackground, bg = bg },
            tab_separator = { fg = colorscheme.editorBackground, bg = bg },
            tab_separator_selected = {
              fg = colorscheme.editorBackground,
              bg = colorscheme.editorBackground,
            },

            close_button = { fg = colorscheme.lineNumberText, bg = bg },
            close_button_visible = { fg = colorscheme.syntaxError, bg = bg },
            close_button_selected = {
              fg = colorscheme.syntaxError,
              bg = colorscheme.editorBackground,
            },

            fill = { bg = bg },

            numbers = { fg = colorscheme.lineNumberText, bg = bg },
            numbers_visible = { fg = colorscheme.lineNumberText, bg = bg },
            numbers_selected = {
              fg = colorscheme.mainText,
              bg = colorscheme.editorBackground,
              italic = italic,
            },

            error = { fg = colorscheme.syntaxError, bg = bg },
            error_visible = { fg = colorscheme.syntaxError, bg = bg },
            error_selected = {
              fg = colorscheme.syntaxError,
              bg = colorscheme.editorBackground,
              italic = italic,
            },
            error_diagnostic = { fg = colorscheme.syntaxError, bg = bg },
            error_diagnostic_visible = { fg = colorscheme.syntaxError, bg = bg },
            error_diagnostic_selected = {
              fg = colorscheme.syntaxError,
              bg = colorscheme.editorBackground,
            },

            warning = { fg = colorscheme.warningEmphasis, bg = bg },
            warning_visible = { fg = colorscheme.warningEmphasis, bg = bg },
            warning_selected = {
              fg = colorscheme.warningEmphasis,
              bg = colorscheme.editorBackground,
              italic = italic,
            },
            warning_diagnostic = { fg = colorscheme.warningEmphasis, bg = bg },
            warning_diagnostic_visible = { fg = colorscheme.warningEmphasis, bg = bg },
            warning_diagnostic_selected = {
              fg = colorscheme.warningEmphasis,
              bg = colorscheme.editorBackground,
            },

            info = { fg = colorscheme.syntaxFunction, bg = bg },
            info_visible = { fg = colorscheme.syntaxFunction, bg = bg },
            info_selected = {
              fg = colorscheme.syntaxFunction,
              bg = colorscheme.editorBackground,
              italic = italic,
            },
            info_diagnostic = { fg = colorscheme.syntaxFunction, bg = bg },
            info_diagnostic_visible = { fg = colorscheme.syntaxFunction, bg = bg },
            info_diagnostic_selected = {
              fg = colorscheme.syntaxFunction,
              bg = colorscheme.editorBackground,
            },

            hint = { fg = colorscheme.successText, bg = bg },
            hint_visible = { fg = colorscheme.successText, bg = bg },
            hint_selected = {
              fg = colorscheme.successText,
              bg = colorscheme.editorBackground,
              italic = italic,
            },
            hint_diagnostic = { fg = colorscheme.successText, bg = bg },
            hint_diagnostic_visible = { fg = colorscheme.successText, bg = bg },
            hint_diagnostic_selected = {
              fg = colorscheme.successText,
              bg = colorscheme.editorBackground,
            },

            diagnostic = { fg = colorscheme.lineNumberText, bg = bg },
            diagnostic_visible = { fg = colorscheme.lineNumberText, bg = bg },
            diagnostic_selected = {
              fg = colorscheme.lineNumberText,
              bg = colorscheme.editorBackground,
              italic = italic,
            },

            modified = { fg = colorscheme.warningText, bg = bg },
            modified_selected = {
              fg = colorscheme.warningText,
              bg = colorscheme.editorBackground,
            },
          },
        })
        vim.keymap.set("n", "<S-Tab>", function()
          bufferline.cycle(-1)
        end)
        vim.keymap.set("n", "<Tab>", function()
          bufferline.cycle(1)
        end)
        vim.keymap.set("n", "<A-,>", function()
          bufferline.move(-1)
        end)
        vim.keymap.set("n", "<A-.>", function()
          bufferline.move(1)
        end)
        vim.keymap.set("n", "<leader>bc", function()
          bufferline.pick()
        end)
        vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>")
        vim.keymap.set("n", "<leader>bq", function()
          bufferline.close_others()
        end)
        for i = 1, 9 do
          vim.keymap.set("n", string.format("<leader>%d", i), function()
            bufferline.go_to(i)
          end)
        end
      end,
    },
    close_tabs = {
      "famiu/bufdelete.nvim",
      config = function()
        vim.keymap.set("n", "<leader>q", function()
          require("bufdelete").bufdelete(0, false)
        end)
      end,
    },
  }
end

local function markdown()
  return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({})
      vim.keymap.set("n", "<leader>md", require("render-markdown").toggle)
    end,
  }
end

local function universal_snacks()
  return {
    "folke/snacks.nvim",
    enabled = true,
    opts = {
      image = {},
    },
  }
end

local function file_tree()
  return {
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

        vim.keymap.set("n", "<leader>tr", function()
          require("neo-tree.command").execute({ toggle = true })
        end),
      })
    end,
  }
end

local function telescope()
  return {
    trouble = {
      "folke/trouble.nvim",
      config = function()
        require("trouble").setup({})
      end,
    },

    telescope = {
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
            -- aerial = {
            --   col1_width = 4,
            --   col2_width = 30,
            --   format_symbol = function(symbol_path, filetype)
            --     if filetype == "json" or filetype == "yaml" then
            --       return table.concat(symbol_path, ".")
            --     else
            --       return symbol_path[#symbol_path]
            --     end
            --   end,
            --   show_columns = "both",
            -- },
          },
        })
        telescope.load_extension("fzf")
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
        vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Telescope help commands" })
        vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Telescope help quickfix" })
        -- telescope.load_extension("aerial")
        -- vim.keymap.set("n", "<leader>ft", telescope.extensions.aerial.aerial, { desc = "Telescope help language tags" })
      end,
    },
  }
end

local function npm()
  return {
    "vuki656/package-info.nvim",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require("package-info").setup({
        autostart = false,
      })
      vim.keymap.set({ "n" }, "<leader>nt", function()
        require("package-info").toggle()
      end)
      vim.keymap.set({ "n" }, "<leader>nu", function()
        require("package-info").change_version()
      end)
      vim.keymap.set({ "n" }, "<leader>nd", function()
        require("package-info").delete()
      end)
      vim.keymap.set({ "n" }, "<leader>ni", function()
        require("package-info").install()
      end)
    end,
  }
end

local function flash_move()
  return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      highlight = {
        backdrop = true,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
    config = function()
      vim.api.nvim_command("hi clear FlashMatch")
      vim.api.nvim_command("hi clear FlashCurrent")
      vim.api.nvim_command("hi clear FlashLabel")

      vim.api.nvim_command("hi FlashMatch guibg=#4A47A3 guifg=#B8B5FF")
      vim.api.nvim_command("hi FlashCurrent guibg=#456268 guifg=#D0E8F2")
      vim.api.nvim_command("hi FlashLabel guibg=#A25772 guifg=#EEF5FF")
    end,
  }
end

local function noice_ui()
  return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        lsp = {
          -- override = {
          --   ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          --   ["vim.lsp.util.stylize_markdown"] = true,
          --   ["cmp.entry.get_documentation"] = true,
          -- },
          -- hover = {
          --   enabled = true,
          --   silent = true,
          --   view = "hover",
          -- },
          -- signature = {
          --   enabled = true,
          --   view = "hover",
          -- },
        },
        views = {
          cmdline_popup = {
            position = {
              row = "95%",
              col = "5%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },
          popupmenu = {
            position = {
              row = "90%",
              col = "5%",
            },
            size = {
              width = 60,
              height = 10,
            },
          },
        },
      })
    end,
  }
end

local file_info_plugins = file_info_incline()
local auto_comment_plugins = auto_comment()
local git_plugins = git()
local tabs_plugins = tabs()
local telescope_plugins = telescope()

return {
  autoclose(),
  clipboard_in_ssh(),
  ts_autotag(),
  surround(),
  file_info_plugins.navic,
  file_info_plugins.incline,
  fold_ufo(),
  status_line(),
  todo_comments(),
  check_startup_performance(),
  terminal(),
  tagbar(),
  smart_splits(),
  auto_comment_plugins.tsx,
  auto_comment_plugins.core,
  git_plugins.signs,
  git_plugins.diff,
  git_plugins.git,
  multicursor(),
  sessions(),
  tabs_plugins.tabs,
  tabs_plugins.close_tabs,
  markdown(),
  universal_snacks(),
  file_tree(),
  telescope_plugins.trouble,
  telescope_plugins.telescope,
  npm(),
  flash_move(),
  -- noice_ui(),
}
