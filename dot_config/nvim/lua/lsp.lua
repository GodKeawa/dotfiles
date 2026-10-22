-- ===========================================================================
-- |                            LSP 客户端配置                              |
-- ===========================================================================

-- 从 nvim-cmp 获取 capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 通用的 LSP 快捷键配置
local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    
    -- LSP 相关快捷键
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)           -- 跳转到声明
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)            -- 跳转到定义
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)                  -- 显示悬浮文档
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)        -- 跳转到实现
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)     -- 显示签名帮助
    vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)    -- 添加工作区文件夹
    vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts) -- 移除工作区文件夹
    vim.keymap.set("n", "<Leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts) -- 列出工作区文件夹
    vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts) -- 跳转到类型定义
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)         -- 重命名
    vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)    -- 代码操作
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)             -- 查找引用
    vim.keymap.set("n", "<Leader>f", function()
        vim.lsp.buf.format({ async = true })
    end, bufopts) -- 格式化代码

    -- 诊断相关快捷键
    vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, bufopts)   -- 显示诊断浮动窗口
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)           -- 跳转到上一个诊断
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)           -- 跳转到下一个诊断
    vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, bufopts)   -- 将诊断添加到位置列表
end

-- 配置诊断显示
vim.diagnostic.config({
    virtual_text = true,    -- 在行尾显示诊断信息
    signs = true,          -- 在符号列显示诊断标志
    underline = true,      -- 在诊断位置显示下划线
    update_in_insert = false, -- 在插入模式下不更新诊断
    severity_sort = true,  -- 按严重程度排序诊断
    float = {
        source = "always",  -- 始终显示诊断来源
        border = "rounded", -- 浮动窗口边框样式
    },
})

-- ===========================================================================
-- |                           语言服务器配置                               |
-- ===========================================================================

-- 使用新 Neovim 推荐的 vim.lsp.config API（兼容 nvim-lspconfig 0.11+）
if not vim.lsp or not vim.lsp.config then
    vim.notify("vim.lsp.config API not available", vim.log.levels.WARN)
    return {}
end

-- C/C++ - clangd 配置
vim.lsp.config('clangd', {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {
        'clangd',
        '--background-index',
        '--suggest-missing-includes',
        '--all-scopes-completion',
        '--completion-style=detailed',
        '--header-insertion=iwyu',
        '--header-insertion-decorators',
        '--pch-storage=memory',
        '--clang-tidy',
        '--fallback-style=llvm',
        '--query-driver=**',  -- 允许查询所有编译器驱动
        '--cross-file-rename', -- 跨文件重命名支持
    },
    root_markers = {
        ".clangd",
        ".clang-tidy", 
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac",
        ".git",
        "Makefile"
    },
    settings = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
})

-- Rust - rust-analyzer 配置
vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        ["rust-analyzer"] = {
            assist = {
                importGranularity = "module",
                importPrefix = "self",
            },
            cargo = {
                loadOutDirsFromCheck = true,
            },
            procMacro = {
                enable = true,
            },
            checkOnSave = {
                command = "clippy",
            },
            completion = {
                addCallParentheses = false,
                addCallArgumentSnippets = true,
            },
            diagnostics = {
                enable = true,
                experimental = {
                    enable = true,
                },
            },
            hover = {
                actions = {
                    enable = true,
                },
            },
            inlayHints = {
                enable = true,
                showParameterNames = true,
                parameterHintsPrefix = "<- ",
                otherHintsPrefix = "=> ",
            },
        },
    },
})

-- Python - pyright 配置
vim.lsp.config('pyright', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
            },
        },
    },
})

-- Lua - lua_ls 配置
vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})


-- ===========================================================================
-- |                              Mason 配置                                |
-- ===========================================================================

-- 检查 mason-lspconfig 是否可用
local mason_lspconfig_available, mason_lspconfig = pcall(require, "mason-lspconfig")

if mason_lspconfig_available then
    -- 自动安装语言服务器并在当前 Neovim 版本 (0.11+) 下使用 vim.lsp.enable
    mason_lspconfig.setup({
        ensure_installed = {
            "clangd",          -- C/C++
            "rust_analyzer",   -- Rust
            "pyright",         -- Python
            "lua_ls",          -- Lua
        },
        automatic_enable = true,
    })
else
    vim.notify("mason-lspconfig is not available, language servers need to be configured manually", vim.log.levels.WARN)
end

return {}
