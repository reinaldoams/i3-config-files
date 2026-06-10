vim.pack.add({
	"https://www.github.com/nvim-tree/nvim-tree.lua",
})

vim.cmd("packadd " .. "nvim-tree.lua")

require("nvim-tree").setup({
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
    git_ignored = false,
	},
	renderer = {
		group_empty = true,
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	actions = {
		open_file = {
			quit_on_open = true,
			window_picker = {
				enable = false,
			},
		},
	},
})

-- set keymaps
local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
keymap.set(
	"n",
	"<leader>ef",
	"<cmd>NvimTreeFindFileToggle<CR>",
	{ desc = "Toggle file explorer on current file" }
) -- toggle file explorer on current file

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
