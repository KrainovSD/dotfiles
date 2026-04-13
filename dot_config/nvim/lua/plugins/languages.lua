local function lsp()
  return {
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
        "dockerfile-language-server",
        "docker-compose-language-service",
        "yaml-language-server",
        "angular-language-server",
        -- "csharp-language-server",
        "omnisharp",
        "phpactor",
        -- "sqls",

        "eslint_d",
        "stylelint",
        "golangci-lint",
        "selene",
        "shellcheck",
        "cpplint",
        "hadolint",

        "prettierd",
        "ruff",
        "stylua",
        "goimports",
        "clang-format",
        "shfmt",
        "yamlfmt",
        "sql-formatter",
        "pgformatter",
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
      vim.lsp.config("html", {
        filetypes = {
          "html",
          "gotmpl",
        },
      })

      vim.keymap.set("n", "<leader>gb", "<C-o>")
      vim.keymap.set("n", "<leader>gf", "<C-i>")
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation)
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references)
      vim.keymap.set("n", "I", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>gpe", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "<leader>gne", vim.diagnostic.goto_next)
      vim.keymap.set("n", "<leader>fe", vim.diagnostic.setloclist)
      vim.keymap.set("n", "<leader>fea", vim.diagnostic.setqflist)
    end,
  }
end

local function linter()
  return {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      vim.env.ESLINT_D_PPID = vim.fn.getpid()
      lint.linters_by_ft = {
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
        html = { "eslint_d" },
        gotmpl = { "eslint_d" },
        dockerfile = { "hadolint" },
      }
      -- eslint_d
      local function find_project_root()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          return vim.loop.cwd()
        end
        local root = vim.fs.find({ "package.json" }, {
          upward = true,
          path = vim.fn.fnamemodify(file, ":h"),
        })[1]
        return root and vim.fn.fnamemodify(root, ":h") or vim.loop.cwd()
      end

      lint.linters.eslint_d.root_dir = find_project_root
      vim.env.PATH = find_project_root() .. "/node_modules/.bin:" .. vim.env.PATH

      -- exec
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        callback = function()
          local linters = require("lint").linters_by_ft[vim.bo.filetype]
          if linters ~= nil and linters[1] == "eslint_d" then
            require("lint").try_lint(nil, { cwd = find_project_root() })
          else
            require("lint").try_lint()
          end
        end,
      })

      -- debug
      vim.api.nvim_create_user_command("LintInfo", function()
        local filetype = vim.bo.filetype
        local linters = require("lint").linters_by_ft[filetype]

        if linters then
          print("Linters" .. vim.env.ESLINT_D_PPID .. " for " .. filetype .. ": " .. table.concat(linters, ", "))
        else
          print("No linters configured for filetype: " .. filetype)
        end

        if linters[1] == "eslint_d" then
          vim.notify(
            "ESLint args: " .. vim.inspect(vim.tbl_get(require("lint").linters, "eslint_d", "args")),
            vim.log.levels.INFO
          )
          print("Root: " .. find_project_root())
        end
      end, {})
    end,
  }
end

local function formatter()
  return {
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
        jsonc = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        markdown = { "prettierd" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "goimports" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        gotmpl = { "prettierd" },
        yaml = { "prettierd" },
        dockerfile = { "hadolint" },
        sql = { "pgformatter" },
      },
      formatters = {
        pgformatter = {
          command = "pg_format",
          args = {
            "--function-case=1",
            "--keyword-case=1",
            "--type-case=1",
            "--comma-break",
            "--spaces=4",
            "--wrap-limit=80",
            "--no-extra-line",
          },
          stdin = true,
        },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
    -- init = function()
    --     -- If you want the formatexpr, here is the place to set it
    --     vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    -- end,
  }
end

local function snippets()
  return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    -- dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip").setup({})
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets" })
    end,
  }
end

local function autocomplete()
  return {
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
  }
end

local function treesitter()
  return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    lazy = false,
    branch = "main",
    commit = "4916d6592ede8c07973490d9322f187e07dfefac",
    config = function()
      local ensure_installed = {
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
      }
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install(ensure_installed)
      -- only for master branch
      -- require("nvim-treesitter.configs").setup({
      --   ensure_installed = ensure_installed,
      --   sync_install = true,
      --   auto_install = true,
      --   highlight = {
      --     enable = true,
      --     additional_vim_regex_highlighting = false,
      --   },
      -- })
      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
      })
      vim.filetype.add({
        extension = {
          gotmpl = "gotmpl",
        },
      })
      vim.filetype.add({
        pattern = {
          ["^.env"] = "env",
          [".env"] = "env",
        },
      })
      vim.treesitter.language.register("html", "gotmpl")
      vim.api.nvim_command("autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>")
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local treesitter_plugin = require("nvim-treesitter")
          local lang = vim.treesitter.language.get_lang(args.match)
          if vim.list_contains(treesitter_plugin.get_available(), lang) then
            if not vim.list_contains(treesitter_plugin.get_installed(), lang) then
              treesitter_plugin.install(lang):wait()
            end

            vim.treesitter.start(args.buf)
          end
        end,
        desc = "enable nvim-treesitter and install parser if not installed",
      })
    end,
  }
end

return {
  lsp(),
  linter(),
  formatter(),
  snippets(),
  autocomplete(),
  treesitter(),
}
