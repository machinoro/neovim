local M = {}
local map = vim.keymap.set

-- export on_attach & capabilities
M.on_attach = function(_, bufnr)
    local function opts(desc)
        return { buffer = bufnr, desc = "LSP " .. desc }
    end

    map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
    map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

    map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts "List workspace folders")

    map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
    map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
end

-- disable semanticTokens
M.on_init = function(client, _)
    if vim.fn.has "nvim-0.11" ~= 1 then
        if client.supports_method "textDocument/semanticTokens" then
            client.server_capabilities.semanticTokensProvider = nil
        end
    else
        if client:supports_method "textDocument/semanticTokens" then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}

M.defaults = function()
    dofile(vim.g.base46_cache .. "lsp")
    require("nvchad.lsp").diagnostic_config()

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            M.on_attach(_, args.buf)
        end,
    })

    -- Disable warning diagnostics overall across virtual text, signs, and underline
    local severities = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
    }
    vim.diagnostic.config {
        virtual_text = { severity = severities },
        signs = { severity = severities },
        underline = { severity = severities },
    }

    -- Suppress all LSP warning diagnostics
    local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if result and result.diagnostics then
            result.diagnostics = vim.tbl_filter(function(d)
                return d.severity ~= vim.lsp.protocol.DiagnosticSeverity.Warning
            end, result.diagnostics)
        end
        return orig_publish(err, result, ctx, config)
    end

    local orig_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]
    if orig_diagnostic then
        vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, config)
            if result and result.items then
                result.items = vim.tbl_filter(function(d)
                    return d.severity ~= vim.lsp.protocol.DiagnosticSeverity.Warning
                end, result.items)
            end
            return orig_diagnostic(err, result, ctx, config)
        end
    end

    local lua_lsp_settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
                library = {
                    vim.fn.expand "$VIMRUNTIME/lua",
                    vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/luv/library",
                },
            },
            diagnostics = {
                globals = { "vim" },
                disable = { "trailing-space" },
            },
        },
    }
    -- Use new vim.lsp.config API for Neovim 0.11+
    vim.lsp.config("*", { capabilities = M.capabilities, on_init = M.on_init })
    vim.lsp.config("lua_ls", { settings = lua_lsp_settings })
    vim.lsp.enable "lua_ls"
end

return M
