return {

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {},
      })
      local mason_registry = require("mason-registry")
      local ensure_installed = {
        "typescript-language-server",
        "lua-language-server",
        "gopls",
        "pyright",
        "bash-language-server",
        "css-lsp",
        "vue-language-server",
        "svelte-language-server",
        "clangd",
        "html-lsp",
        "marksman",

        "eslint_d",
        "stylelint",
        "golangci-lint",
        "selene",
        "shellcheck",
        "cpplint",

        "prettierd",
        "ruff",
        "stylua",
        "goimports",
        "clang-format",
        "shfmt",
      }

      -- Функция для установки всех инструментов
      local function ensure_tools_installed()
        for _, tool in ipairs(ensure_installed) do
          local p = mason_registry.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      ensure_tools_installed()

      vim.diagnostic.config({
        virtual_text = {
          severity = {
            min = vim.diagnostic.severity.WARN,
          },
          prefix = "▶",
        },
        signs = true,
        underline = true,
      })
      vim.lsp.config("ts_ls", {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              languages = { "vue" },
              configNamespace = "typescript",
              location = vim.fn.stdpath("data")
                .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
            },
          },
        },
      })
    end,
  },

  -- linter
  {
    "mfussenegger/nvim-lint",
    config = function()
      vim.env.ESLINT_D_PPID = vim.fn.getpid()
      require("lint").linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        svelte = { "eslint_d" },
        -- css = { "stylelint" },
        -- scss = { "stylelint" },
        lua = { "selene" },
        python = { "ruff" },
        c = { "cpplint" },
        cpp = { "cpplint" },
        -- go = { "golangci-lint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
      -- eslint
      local function find_eslint_config()
        local current_file = vim.api.nvim_buf_get_name(0)
        if current_file == "" then
          return nil
        end
        local config_files = {
          "eslint.config.js",
          "eslint.config.cjs",
          ".eslintrc.cjs",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          ".eslintrc.json",
          ".eslintrc",
        }
        local file_dir = vim.fn.fnamemodify(current_file, ":h")
        local found = vim.fs.find(config_files, {
          upward = true,
          path = file_dir,
          stop = vim.loop.cwd(),
        })
        if #found == 0 then
          found = vim.fs.find(config_files, {
            path = vim.loop.cwd(),
          })
        end
        return found[1] or nil
      end

      require("lint").linters.eslint_d.args[6] = "--config"
      require("lint").linters.eslint_d.args[7] = find_eslint_config

      require("lint").linters.eslint_d.args[8] = "--ext"
      require("lint").linters.eslint_d.args[9] = ".js,.jsx,.ts,.tsx,.vue,.svelte"
      -- debug
      vim.api.nvim_create_user_command("LintInfo", function()
        local filetype = vim.bo.filetype
        local linters = require("lint").linters_by_ft[filetype]

        if linters then
          print("Linters" .. vim.env.ESLINT_D_PPID .. " for " .. filetype .. ": " .. table.concat(linters, ", "))
        else
          print("No linters configured for filetype: " .. filetype)
        end
        print("Config: " .. find_eslint_config())
      end, {})
    end,
  },

  -- formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>F",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        vue = { "prettierd" },
        svelte = { "prettierd" },
        json = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        markdown = { "prettierd" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "goimports" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
    -- init = function()
    --     -- If you want the formatexpr, here is the place to set it
    --     vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    -- end,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    -- dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip").setup({})
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets" })
    end,
  },

  -- autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/nvim-cmp" },
      { "saadparwaiz1/cmp_luasnip" },
      { "L3MON4D3/LuaSnip" },
      { "onsails/lspkind.nvim" },
      -- { "f3fora/cmp-spell" },
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      cmp.setup({
        completion = {
          max_height = math.floor(vim.o.lines * 0.3),
          min_height = 5,
          scrolloff = 2,
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item = require("lspkind").cmp_format({
              mode = "symbol_text",
              maxwidth = 20,
              ellipsis_char = "...",
            })(entry, vim_item)

            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
              nvim_lua = "[Lua]",
            })[entry.source.name]

            if entry.source.name == "nvim_lsp" then
              local item = entry:get_completion_item()
              if item.labelDetails and item.labelDetails.description then
                vim_item.menu = vim_item.menu .. " " .. item.labelDetails.description
              elseif item.detail then
                vim_item.menu = vim_item.menu .. " " .. item.detail
              end

              if item.documentation then
                local doc_text = ""
                if type(item.documentation) == "string" then
                  doc_text = item.documentation
                elseif item.documentation.value then
                  doc_text = item.documentation.value
                end

                if #doc_text > 0 and #doc_text < 30 then
                  vim_item.menu = vim_item.menu .. " - " .. doc_text
                end
              end
            end

            return vim_item
          end,
        },
      })
      -- `/` cmdline setup.
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          {
            name = "path",
          },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = {
                "Man",
                "!",
              },
            },
          },
        }),
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "html",
          "vim",
          "lua",
          "rust",
          "python",
          "yaml",
          "vimdoc",
          "vue",
          "svelte",
          "javascript",
          "typescript",
          "markdown",
          "gleam",
          "hyprlang",
          "helm",
          "gotmpl",
          "go",
          "css",
          "scss",
        },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
      })
    end,
  },
}
