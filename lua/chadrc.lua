-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "catppuccin",
}

local function get_avante_width()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].ft == "Avante" or vim.bo[buf].ft == "AvanteInput" then
                return vim.api.nvim_win_get_width(win)
            end
        end
    end
    return 0
end

M.ui = {
    tabufline = {
        order = { "avanteOffset", "buffers", "tabs", "btns", "treeOffset" },
        modules = {
            avanteOffset = function()
                local w = get_avante_width()
                if w == 0 then
                    return ""
                end
                return "%#NvimTreeNormal#" .. string.rep(" ", w) .. "%#NvimTreeWinSeparator#" .. "│"
            end,
        },
    },
}

return M
