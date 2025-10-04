-- init.lua

-- Leader
vim.g.mapleader = " "

-- Core
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.swapfile = false

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "williamboman/mason.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "L3MON4D3/LuaSnip" },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                integrations = {
                    alpha = true,
                    treesitter = true,
                    telescope = true,
                    nvimtree = true,
                    cmp = true,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                      ",
                "              ███████╗██╗███╗   ██╗██╗  ██╗           ",
                "              ██╔════╝██║████╗  ██║██║  ██║           ",
                "              ███████╗██║██╔██╗ ██║███████║           ",
                "              ╚════██║██║██║╚██╗██║██╔══██║           ",
                "              ███████║██║██║ ╚████║██║  ██║           ",
                "              ╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝           ",
                "                                                      ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
                dashboard.button("n", "  New file", ":ene <BAR> startinsert<CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("g", "󰱼  Find text", ":Telescope live_grep<CR>"),
                dashboard.button("t", "󰙅  File tree", ":NvimTreeToggle<CR>"),
                dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
                dashboard.button("s", "  Restore Session", [[:lua require("persistence").load() <CR>]]),
                dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
                dashboard.button("q", "  Quit", ":qa<CR>"),
            }

            local function footer()
                local total_plugins = require("lazy").stats().count
                local datetime = os.date("  %d-%m-%Y   %H:%M:%S")
                local v = vim.version()
                local nvim_version = "   v" .. v.major .. "." .. v.minor .. "." .. v.patch
                return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version
            end

            dashboard.section.footer.val = footer()

            dashboard.section.header.opts.hl = "Include"
            dashboard.section.buttons.opts.hl = "Keyword"
            dashboard.section.footer.opts.hl = "Type"

            dashboard.opts.opts.noautocmd = true
            alpha.setup(dashboard.opts)
        end,
    }

})


-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)
map("n", "<leader>h", ":nohlsearch<CR>", opts)
map("n", "<leader>f", ":Telescope find_files<CR>", opts)
map("n", "<leader>g", ":Telescope live_grep<CR>", opts)
map("n", "<leader>r", ":Telescope oldfiles<CR>", opts)
map("n", "gd", vim.lsp.buf.definition, opts)
map("n", "K", vim.lsp.buf.hover, opts)
map("n", "gr", vim.lsp.buf.references, opts)
map("n", "<leader>rn", vim.lsp.buf.rename, opts)
map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<F5>", ":w<CR>:!clang % -o %< && ./%<<CR>", opts)
map("n", "<F6>", ":w<CR>:!uv run %<CR>", opts)

map({"n", "v"}, "<leader>y", '"+y', opts)
map({"n", "v"}, "<leader>p", '"+p', opts)
map("n", "<leader>Y", '"+Y', opts)
map("n", "<leader>P", '"+P', opts)

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "python", "lua" },
  highlight = { enable = true },
})

-- File tree
require("nvim-tree").setup({
  view = { width = 30, side = "left" },
  renderer = { group_empty = true },
})
map("n", "<leader>t", ":NvimTreeToggle<CR>", opts)

-- Mason
require("mason").setup()

-- LSP (Native Neovim 0.11+)
vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        typeCheckingMode = "basic",
      },
    },
  },
  before_init = function(_, config)
    local uv_venv = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.executable(uv_venv) == 1 then
      config.settings.python.pythonPath = uv_venv
    end
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ "clangd", "pyright", "lua_ls" })

-- CMP
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})