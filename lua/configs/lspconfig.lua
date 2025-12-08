local M = {}

M.setup = function()
	-- Function for setting up key mappings
	local function setup_lsp_keymaps(bufnr)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
		end

		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(event)
			setup_lsp_keymaps(event.buf)
		end,
	})
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

	-- LSP servers setup
	local servers = {
		ts_ls = {},
		pylsp = {},
		lua_ls = {},
		html = { filetypes = { "html", "twig", "hbs" } },
		cssls = {},
		tailwindcss = {},
		dockerls = {},
		jsonls = {},
		clangd = {},
		lemminx = { filetypes = { "xml", "sdf" } },
	}

	-- Mason setup
	require("mason").setup({
		PATH = "prepend", -- "skip" seems to cause the spawning error
	})
	require("mason-tool-installer").setup({
		ensure_installed = vim.tbl_keys(servers),
	})

	require("mason-lspconfig").setup({
		handlers = {
			function(server_name)
				local config = servers[server_name] or {}
				config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
				require("lspconfig")[server_name].setup(config)
			end,
		},
	})

	-- Diagnostics setup
	vim.diagnostic.config({
		virtual_text = {
			enabled = true,
			source = "if_many",
			spacing = 10,
			current_line = true,
			format = function(diagnostic)
				if diagnostic.severity == vim.diagnostic.severity.ERROR then
					return string.format("󰅚 %s", diagnostic.message)
				elseif diagnostic.severity == vim.diagnostic.severity.WARN then
					return string.format("󰀪 %s", diagnostic.message)
				elseif diagnostic.severity == vim.diagnostic.severity.INFO then
					return string.format("󰋽 %s", diagnostic.message)
				elseif diagnostic.severity == vim.diagnostic.severity.HINT then
					return string.format("󰌶 %s", diagnostic.message)
				end
				return diagnostic.message
			end,
		},
		signs = {
			active = true,
		},
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})
end

return M
