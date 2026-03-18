local M = {}

M.setup = function()
    require("conform").setup {
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "black" },
            rust = { "rustfmt", lsp_format = "fallback" },
            javascript = { "prettierd", "prettier", stop_after_first = true },
            c = { "my_formatter" },
            cpp = { "my_formatter" },
            css = { "prettier" },
            java = { "google-java-format" },
            html = { "prettier" },
            sh = { "beautysh" },
            xml = { "xmlformatter" },
            -- sdf = { "xmlformatter" },
            -- xacro = { "xmlformatter" },
            -- urdf = { "xmlformatter" },
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback",
        },
        formatters = {
            my_formatter = {
                command = "clang-format",
                args = '--style="{BasedOnStyle: llvm, IndentWidth: 4, ColumnLimit: 10000}"',
            },
        },
    }
end
return M.setup()
