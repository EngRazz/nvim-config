-- =============================================================================
-- plugins.lua — all plugins and their configs in one place
-- Managed by lazy.nvim. Grouped by category for easy navigation.
-- =============================================================================

return {

  -- ===========================================================================
  -- COLORSCHEME
  -- ===========================================================================

--  {
--    "folke/tokyonight.nvim",
--    lazy = false,    -- load immediately (it's the colorscheme)
--    priority = 1000, -- load before everything else
--    config = function()
--      require("tokyonight").setup({
--        style = "night",
--        styles = {
--          comments = { italic = true },
--          keywords = { italic = false },
--        },
--        on_highlights = function(hl, c)
--          hl.LineNr       = { fg = "#7aa2f7", bold = true }
--          hl.CursorLineNr = { fg = "#ff9e64", bold = true }
--          hl.Comment      = { fg = "#7aa2f7", italic = true }
--        end,
--      })
--      vim.cmd([[colorscheme tokyonight-night]])
--    end,
--  },

  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,    -- load immediately (it's the colorscheme)
    priority = 1000, -- load before everything else
    config = function()
      require("monokai-pro").setup({
        filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
      })
      vim.cmd.colorscheme("monokai-pro")
    end,
  },

  -- ===========================================================================
  -- FILE TREE
  -- ===========================================================================

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
    end,
  },

  -- ===========================================================================
  -- FUZZY FINDER
  -- ===========================================================================

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()

      local b = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", b.find_files,  {})
      vim.keymap.set("n", "<leader>fg", b.git_files,   {})
      vim.keymap.set("n", "<leader>fr", b.live_grep,   {})
      vim.keymap.set("n", "<leader>fb", b.buffers,     {})
      vim.keymap.set("n", "<leader>fh", ":Telescope find_files hidden=true<CR>")
    end,
  },

  -- ===========================================================================
  -- SYNTAX HIGHLIGHTING & TREESITTER
  -- ===========================================================================

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "c", "cpp", "python",
        "html", "css", "javascript",
        "lua", "vim", "vimdoc",
        "query", "markdown", "markdown_inline", "latex",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "python", "html", "css", "javascript", "lua", "vim", "markdown", "latex" },
        callback = function()
          vim.treesitter.start()
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },

  -- ===========================================================================
  -- LSP + COMPLETION
  -- ===========================================================================

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",           -- LSP installer UI
      "williamboman/mason-lspconfig.nvim", -- bridges mason ↔ lspconfig
      "hrsh7th/cmp-nvim-lsp",             -- LSP source for nvim-cmp
      "hrsh7th/nvim-cmp",                 -- completion engine
    },
    config = function()

      -- ── LSP keymaps (set when a language server attaches) ──────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP keymaps",
        callback = function(event)
          local o = { buffer = event.buf }
          vim.keymap.set("n", "K",          "<cmd>lua vim.lsp.buf.hover()<cr>",          o)
          vim.keymap.set("n", "<leader>k",  "<cmd>lua vim.diagnostic.open_float()<cr>",  o)
          vim.keymap.set("n", "gd",         "<cmd>lua vim.lsp.buf.definition()<cr>",     o)
          vim.keymap.set("n", "gD",         "<cmd>lua vim.lsp.buf.declaration()<cr>",    o)
          vim.keymap.set("n", "gi",         "<cmd>lua vim.lsp.buf.implementation()<cr>", o)
          vim.keymap.set("n", "go",         "<cmd>lua vim.lsp.buf.type_definition()<cr>",o)
          vim.keymap.set("n", "gr",         "<cmd>lua vim.lsp.buf.references()<cr>",     o)
          vim.keymap.set("n", "gs",         "<cmd>lua vim.lsp.buf.signature_help()<cr>", o)
          vim.keymap.set("n", "<F2>",       "<cmd>lua vim.lsp.buf.rename()<cr>",         o)
          vim.keymap.set("n", "<F4>",       "<cmd>lua vim.lsp.buf.code_action()<cr>",    o)
        end,
      })

      -- ── Mason: auto-install LSP servers via :Mason ─────────────────────────
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Give all LSP servers nvim-cmp capabilities
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- clangd is installed by Ubuntu, not Mason
      vim.lsp.config("clangd", {
        cmd = { "clangd" },
      })

      vim.lsp.enable("clangd")

      -- Mason manages the servers it can install
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          -- put Mason-supported servers here
          -- e.g. "pyright",
        },
      })

      -- ── nvim-cmp: completion ───────────────────────────────────────────────
      local cmp = require("cmp")

      local kind_icons = {
        Text = "", Method = "m", Function = "", Constructor = "",
        Field = "", Variable = "", Class = "", Interface = "",
        Module = "", Property = "", Unit = "", Value = "",
        Enum = "", Keyword = "", Snippet = "", Color = "",
        File = "", Reference = "", Folder = "", EnumMember = "",
        Constant = "", Struct = "", Event = "", Operator = "",
        TypeParameter = "",
      }

      cmp.setup({
        sources = { { name = "nvim_lsp" } },

        mapping = {
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-b>"]     = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"]     = cmp.mapping(cmp.mapping.scroll_docs(1),  { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(),      { "i", "c" }),
          ["<C-y>"]     = cmp.config.disable,
          ["<C-e>"]     = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
          ["<CR>"]      = cmp.mapping.confirm { select = false },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
          end, { "i", "s" }),
        },

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              buffer   = "[Buffer]",
              path     = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },

  -- ===========================================================================
  -- EDITING UTILITIES
  -- ===========================================================================

  {
    -- Auto-close brackets, quotes, etc.
    "altermo/ultimate-autopair.nvim",
    event = "InsertEnter",
    config = true, -- calls require("ultimate-autopair").setup() with defaults
  },

  -- ===========================================================================
  -- VISUAL / UX ENHANCEMENTS
  -- ===========================================================================

  {
    -- Animated cursor smear effect
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    config = function()
      require("smear_cursor").setup({
        smear_between_buffers      = true,
        smear_between_neighbor_lines = true,
        legacy_computing_symbols_support = false,
        hide_target_hack           = true,
        scroll_buffer_space        = true,
        distance_stop_animating    = 0.5,
        stiffness                  = 0.6,
        trailing_stiffness         = 0.3,
        trailing_exponent          = 0.1,
        gamma                      = 2.2,
        smear_insert_mode          = false,
        min_width                  = 3,
      })
    end,
  },

  {
    -- Smooth scrolling for <C-u>/<C-d>/etc.
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        mappings         = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor      = true,
        stop_eof         = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function  = "quadratic",
      })
    end,
  },

  -- ===========================================================================
  -- MARKDOWN RENDERING
  -- ===========================================================================

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      latex = {
        enabled = true,
        converter = "latex2text", -- pip install pylatexenc --break-system-packages
        highlight = "RenderMarkdownMath",
        top_pad = 0,
        bottom_pad = 0,
      },
      heading = { enabled = true },
      code = { enabled = true, style = "full" },
      bullet = { enabled = true },
      checkbox = { enabled = true },
    },
  },

  {
    -- true image-rendered LaTeX equations, reuses your existing image.nvim backend
    "jbyuki/nabla.nvim",
    ft = "markdown",
    config = function()
      vim.keymap.set("n", "<leader>mp", require("nabla").popup, {})
      vim.keymap.set("n", "<leader>mt", require("nabla").toggle_virt, {})
    end,
  },

  -- ===========================================================================
  -- JUPYTER NOTEBOOKS
  -- ===========================================================================

  {
    "sheng-tse/jupynvim",

    build = function(plugin)
      local install = loadfile(plugin.dir .. "/lua/jupynvim/install.lua")()
      install.run(plugin)
    end,

    config = function()
      require("jupynvim").setup({
        log_level = "info",

        -- Good default because you use tmux.
        -- Jupynvim handles inline image placeholders properly there.
        image_renderer = "placeholder",
      })
    end,
  },

  -- ===========================================================================
  -- TMUX INTEGRATION
  -- ===========================================================================

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

}

