-- ===========================================================================
-- |                             通用 Neovim 设置                           |
-- ===========================================================================
local opt = vim.opt

-- 设置行号
opt.number = true
-- 软制表符（softtabstop），在输入模式下按退格键会退4个空格
opt.softtabstop = 4
-- 制表符（tabstop）的宽度
opt.tabstop = 4
-- 自动缩进（shiftwidth）的宽度
opt.shiftwidth = 4
-- 将制表符（tab）转换为空格
opt.expandtab = true
-- 智能缩进
opt.smartindent = true
-- 关闭自动换行
opt.wrap = false
-- 在所有模式下启用鼠标支持
opt.mouse:append("a")
-- 启用系统剪贴板
opt.clipboard:append("unnamedplus")
-- 窗口垂直分割时，新窗口显示在右边
opt.splitright = true
-- 窗口水平分割时，新窗口显示在下边
opt.splitbelow = true
-- 搜索时忽略大小写
opt.ignorecase = true
-- 搜索时如果包含大写字母，则开启大小写敏感
opt.smartcase = true
-- 启用真彩色
opt.termguicolors = true
-- 即使没有LSP或诊断信息，也始终显示左侧的符号列
opt.signcolumn = "yes"
-- 允许某些键（如<,>等）在行尾/行首换行
opt.whichwrap = '<,>,[,]'
-- 显示不可见字符
vim.o.list = true
-- 设置不可见字符的显示样式
vim.o.listchars = "space: ,tab:  "

-- ===========================================================================
-- |                             自动命令 (Autocmds)                         |
-- ===========================================================================
-- 开启 Treesitter 高亮和缩进
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- 尝试启动原生 Treesitter 高亮
        pcall(vim.treesitter.start)
        -- 启用 Treesitter 缩进
        pcall(function() vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end)
    end,
})

-- 复制文本后高亮显示
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({
            timeout = 600,
        })
    end,
})

-- ===========================================================================
-- |                                  快捷键                                 |
-- ===========================================================================
vim.g.mapleader = " " -- 设置 Leader 键为 <Space>
vim.keymap.set("n", "<C-s>", ":w<CR>")      -- 普通模式下 Ctrl + s 保存文件
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>a") -- 插入模式下 Ctrl + s 保存文件
vim.keymap.set("n", "<Leader>v", "<C-w>v")   -- Leader + v 垂直分割窗口
vim.keymap.set("n", "<Leader>s", "<C-w>s")   -- Leader + s 水平分割窗口
vim.keymap.set("n", "<C-Left>", "<C-w>h")  -- Ctrl + Left 移动到左边窗口
vim.keymap.set("n", "<C-Right>", "<C-w>l")   -- Ctrl + Right 移动到右边窗口
vim.keymap.set("n", "<C-Down>", "<C-w>j")    -- Ctrl + Down 移动到下边窗口
vim.keymap.set("n", "<C-Up>", "<C-w>k")    -- Ctrl + Up 移动到上边窗口

-- Telescope 快捷键（文件搜索和项目导航）
vim.keymap.set("n", "<Leader>ff", ":Telescope find_files<CR>")    -- 搜索文件
vim.keymap.set("n", "<Leader>fg", ":Telescope live_grep<CR>")     -- 全局搜索
vim.keymap.set("n", "<Leader>fb", ":Telescope buffers<CR>")       -- 搜索缓冲区
vim.keymap.set("n", "<Leader>fh", ":Telescope help_tags<CR>")     -- 搜索帮助

-- LSP 诊断和项目管理快捷键
vim.keymap.set("n", "<Leader>lr", ":LspRestart<CR>")              -- 重启 LSP 服务器
vim.keymap.set("n", "<Leader>li", ":LspInfo<CR>")                 -- 显示 LSP 信息

-- ===========================================================================
-- |                             插件管理 (Lazy.nvim)                        |
-- ===========================================================================
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

-- 插件列表
require("lazy").setup({
    -- 主题插件
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    -- 模糊查找插件
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
    },
    -- 语法高亮
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      lazy = false,
      config = function()
        require("nvim-treesitter").setup()
        -- 异步安装常用的解析器
        require("nvim-treesitter").install({ "make", "lua", "c", "cpp", "rust", "python" })
      end
    },
    -- 标签页
    {
        "akinsho/bufferline.nvim",
    },
    -- 底部状态栏
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    -- 文件树
    {
        "nvim-tree/nvim-tree.lua",
    },
    -- 自动补全括号
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },
    -- Treesitter 彩虹括号 (升级为 rainbow-delimiters)
    {
        "HiPhish/rainbow-delimiters.nvim",
        lazy = true,
        event = {"BufReadPost", "BufNewFile"},
    },
    -- LSP 支持
    {
        "neovim/nvim-lspconfig",
    },
    -- LSP/DAP/Linting 等管理工具
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
    },
    -- Mason 与 LSP 的桥梁
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
    },
    -- 补全引擎
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",  -- LuaSnip 与 nvim-cmp 的集成
        },
    },
    -- 交互式终端
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        config = true,
        opts = {
            size = 20,
            open_mapping = [[<C-/>]],
            direction = "float",       -- 终端以浮动窗口形式打开
            float_opts = {
                border = "curved",
            },
        }
    },
})

-- ===========================================================================
-- |                                  插件配置                               |
-- ===========================================================================
-- 颜色主题
vim.cmd.colorscheme("tokyonight")

-- Bufferline 配置
require("bufferline").setup({
    options = {
        offsets = {{
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
        }},
    }
})

-- Lualine 配置
require("lualine").setup({
    options = {
        theme = "gruvbox", -- 虽然主题是tokyonight，但状态栏lualine可以独立设置
    }
})

-- 禁用内置的文件树 netrw，使用 nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Nvim-tree 配置
require("nvim-tree").setup({})
vim.keymap.set("n", "<Leader>t", ":NvimTreeToggle<CR>") -- 设置快捷键 Leader + t 来切换文件树

-- Nvim-autopairs 配置
require("nvim-autopairs").setup({
    disable_filetype = { "TelescopePrompt" , "vim" },
})

-- Mason 配置
require("mason").setup({})

-- Nvim-lspconfig 配置
-- 从 nvim-cmp 获取默认的LSP capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- nvim-cmp (补全引擎) 配置
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- 一个用于判断是否可以退格的辅助函数
local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- 向上滚动文档
    ['<C-f>'] = cmp.mapping.scroll_docs(4),  -- 向下滚动文档
    ['<C-e>'] = cmp.mapping.abort(),         -- 退出补全
    ['<Esc>'] = cmp.mapping.abort(),         -- 退出补全
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 确认补全

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),

  -- 补全源
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },  -- 来自 LSP 的补全
    { name = 'luasnip' },   -- 来自代码片段的补全
    { name = 'path' },      -- 来自文件路径的补全
  }, {
    { name = 'buffer' },    -- 来自当前缓冲区的补全
  })
})

-- 加载 LSP 配置
require("lsp")
