vim.g.vimtex_view_method = "zathura_simple"
vim.g.vimtex_view_automatic = 0
vim.g.vimtex_view_zathura_use_synctex = 0
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_latexmk = {
    aux_dir = "/tmp/latexmk",
    options = { "-verbose", "-file-line-error", "-synctex=0", "-interaction=nonstopmode" },
}

local launching = false
local function ensure_zathura()
    if launching then
        return
    end
    local vt = vim.b.vimtex
    local pdf = vt and vt.root and vt.name and (vt.root .. "/" .. vt.name .. ".pdf") or ""
    if pdf ~= "" and vim.fn.filereadable(pdf) == 1 then
        if vim.fn.system("pgrep -f 'zathura.*" .. vt.name .. "\\.pdf'") == "" then
            launching = true
            vim.cmd "silent! VimtexView"
            vim.defer_fn(function()
                launching = false
            end, 1500)
        end
    end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.tex",
    callback = function()
        vim.cmd "silent! VimtexCompile!"
        ensure_zathura()
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "VimtexEventCompileSuccess",
    callback = ensure_zathura,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "VimtexEventQuit",
    callback = function()
        local vt = vim.b.vimtex
        if vt and vt.name then
            vim.fn.system("pkill -f 'zathura.*" .. vt.name .. "\\.pdf'")
        end
        vim.cmd "silent! VimtexClean"
    end,
})
