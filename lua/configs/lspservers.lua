require("configs.lspconfig").defaults()

local servers = {
    ts_ls = {},
    pylsp = {},
    lua_ls = {},
    html = { filetypes = { "html", "twig", "hbs" } },
    cssls = {},
    tailwindcss = {},
    dockerls = {},
    jsonls = {},
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- IMPORTANT: This tells clangd it is okay to use your cross-compiler
            "--query-driver=**/*gcc*,**/*g++*,**/bin/*",
        },
    },
    lemminx = { filetypes = { "xml", "sdf" } },
}

require("mason-lspconfig").setup {
    ensure_installed = vim.tbl_keys(servers),
    automatic_enable = false,
}

for server, config in pairs(servers) do
    if next(config) ~= nil then
        vim.lsp.config(server, config)
    end
    vim.lsp.enable(server)
end
