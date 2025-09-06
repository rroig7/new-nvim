vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.mouse = "a"
vim.opt.splitkeep = "screen"
vim.opt.shiftwidth = 4
vim.opt.wrap = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "nvim-lua/plenary.nvim",   lazy = false },
    { "williamboman/mason.nvim", lazy = false, config = true },

    {
        "nvim-tree/nvim-tree.lua",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                disable_netrw = true,
                hijack_netrw = true,
                view = { width = 30 },
                renderer = { group_empty = true },
                filters = { dotfiles = false },
                git = { ignore = false },
            })
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
            vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", { desc = "Focus File Explorer" })
        end,
    },

    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp",
                    offsets = { { filetype = "NvimTree", text = "File Explorer", padding = 1 } },
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                },
            })
            vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePickClose<CR>", { desc = "Pick Buffer to Close" })
            vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local lsp = require("lspconfig")
            local mason_lsp = require("mason-lspconfig")
            local cap = require("cmp_nvim_lsp").default_capabilities()

            mason_lsp.setup({
                ensure_installed = { "clangd", "rust_analyzer", "lua_ls", "pyright" },
                automatic_installation = true,
            })

            lsp.clangd.setup({
                capabilities = cap,
                cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            })

            lsp.rust_analyzer.setup({
                capabilities = cap,
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = { command = "clippy" },
                        cargo = { allFeatures = true },
                        procMacro = { enable = true },
                        diagnostics = { enable = true, experimental = { enable = true } },
                    },
                },
            })

            lsp.pyright.setup({
                capabilities = cap,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "workspace",
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = "basic",
                            autoImportCompletions = true,
                        },
                    },
                },
                before_init = function(params, config)
                    local uv_venv = vim.fn.getcwd() .. "/.venv/bin/python"
                    if vim.fn.executable(uv_venv) == 1 then
                        config.settings.python.pythonPath = uv_venv
                    end
                end,
            })

            lsp.lua_ls.setup({
                capabilities = cap,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "rust", "python", "lua", "vim", "toml", "yaml", "json" },
                highlight = { enable = true },
                indent = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                },
            })
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end),
                }),
                sources = {
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "buffer",   priority = 500 },
                    { name = "path",     priority = 250 },
                },
            })
        end,
    },

    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua")

            builtin = require("fzf-lua.builtin")
            vim.keymap.set("n", "<leader>fz", builtin.files, { desc = "Find Files with fzf-lua" })
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_strategy = "vertical",
                    layout_config = {
                        prompt_position = "top",
                        width = 0.8,
                        height = 0.8,
                    },
                },
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                    },
                },
            })

            require("telescope").load_extension("fzf")

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
            vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document Symbols" })
            vim.keymap.set("n", "<leader>fw", builtin.lsp_workspace_symbols, { desc = "Workspace Symbols" })
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    rust = { "rustfmt" },
                    python = { "black", "isort" },
                    lua = { "stylua" },
                },
                format_on_save = { timeout_ms = 1000, lsp_fallback = true },
            })
            vim.keymap.set("n", "<leader>f", function()
                require("conform").format({ async = true, lsp_fallback = true })
            end, { desc = "Format File" })
        end,
    },

    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            "mfussenegger/nvim-dap-python",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()
            require("nvim-dap-virtual-text").setup()

            require("dap-python").setup(vim.fn.getcwd() .. "/.venv/bin/python")

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
            vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Step Over" })
            vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
            vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
        end,
    },

    {
        "nvim-neotest/neotest",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-neotest/neotest-python",
            "antoinemadec/FixCursorHold.nvim",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        python = vim.fn.getcwd() .. "/.venv/bin/python",
                    }),
                },
            })

            vim.keymap.set("n", "<leader>tr", require("neotest").run.run, { desc = "Run Test" })
            vim.keymap.set("n", "<leader>tf", function()
                require("neotest").run.run(vim.fn.expand("%"))
            end, { desc = "Run File Tests" })
            vim.keymap.set("n", "<leader>ts", require("neotest").summary.toggle, { desc = "Toggle Test Summary" })
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    vim.keymap.set("n", "]c", gs.next_hunk, { buffer = bufnr, desc = "Next Hunk" })
                    vim.keymap.set("n", "[c", gs.prev_hunk, { buffer = bufnr, desc = "Prev Hunk" })
                    vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage Hunk" })
                    vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset Hunk" })
                    vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
                end,
            })
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "catppuccin" },
                sections = {
                    lualine_c = {
                        { "filename", path = 1 },
                        {
                            function()
                                local venv = vim.env.VIRTUAL_ENV
                                if venv then
                                    return " " .. vim.fn.fnamemodify(venv, ":t")
                                end
                                return ""
                            end,
                            color = { fg = "#8aadf4" },
                        },
                    },
                },
            })
        end,
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = false,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    telescope = true,
                    treesitter = true,
                    mason = true,
                    dap = true,
                    dap_ui = true,
                    neotest = true,
                },
            })
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup()
            vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
            vim.keymap.set(
                "n",
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                { desc = "Buffer Diagnostics (Trouble)" }
            )
            vim.keymap.set(
                "n",
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                { desc = "Symbols (Trouble)" }
            )
            vim.keymap.set(
                "n",
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                { desc = "LSP Definitions / references / ... (Trouble)" }
            )
        end,
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = { lua = { "string" }, javascript = { "template_string" } },
            })
        end,
    },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("Comment").setup()
        end,
    },

    {
        "folke/flash.nvim",
        event = "VeryLazy",
        config = function()
            require("flash").setup()
            vim.keymap.set({ "n", "x", "o" }, "s", function()
                require("flash").jump()
            end, { desc = "Flash" })
            vim.keymap.set({ "n", "x", "o" }, "S", function()
                require("flash").treesitter()
            end, { desc = "Flash Treesitter" })
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
                dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
                dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
                dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
                dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
                dashboard.button("s", "  Restore Session", [[:lua require("persistence").load() <cr>]]),
                dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
                dashboard.button("q", "  Quit", ":qa<CR>"),
            }

            local function footer()
                local total_plugins = require("lazy").stats().count
                local datetime = os.date("  %d-%m-%Y   %H:%M:%S")
                local version = vim.version()
                local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

                return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
            end

            dashboard.section.footer.val = footer()

            dashboard.section.footer.opts.hl = "Type"
            dashboard.section.header.opts.hl = "Include"
            dashboard.section.buttons.opts.hl = "Keyword"

            dashboard.opts.opts.noautocmd = true
            alpha.setup(dashboard.opts)
        end,
    },

    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = { options = vim.opt.sessionoptions:get() },
        keys = {
            {
                "<leader>qs",
                function()
                    require("persistence").load()
                end,
                desc = "Restore Session",
            },
            {
                "<leader>ql",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Restore Last Session",
            },
            {
                "<leader>qd",
                function()
                    require("persistence").stop()
                end,
                desc = "Don't Save Current Session",
            },
        },
    },
}, {
    defaults = { lazy = true },
    performance = {
        rtp = { disabled_plugins = { "gzip", "matchit", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
})

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

vim.keymap.set("i", "jk", "<Esc>", { desc = "Fast Escape" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlighted Search" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("v", "<", "<gv", { desc = "Decrease Indent" })
vim.keymap.set("v", ">", ">gv", { desc = "Increase Indent" })

vim.keymap.set("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open Terminal" })
vim.keymap.set("n", "<leader>tp", function()
    vim.cmd("terminal uv run python")
end, { desc = "Python REPL with uv" })

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(save)
    end,
    desc = "Remove Trailing Whitespace on Save",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
    desc = "Highlight on Yank",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.supports_method("textDocument/documentHighlight") then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = args.buf,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = args.buf,
                callback = vim.lsp.buf.clear_references,
            })
        end

        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
    end,
    desc = "LSP Keymaps",
})
