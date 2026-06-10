-- set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- space for localleader

local keymap = vim.keymap -- for conciseness

-- better movement in wrapped text
keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

----------------------- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- Buffers
keymap.set(
	"n",
	"<leader>bo",
	'<cmd>%bdelete|edit #|normal`"<cr>',
	{ desc = "Close all buffers except the current open one" }
)
keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Close current buffer" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Keymap to add JSDoc types
keymap.set(
	"n",
	"<leader>jt",
	"O/** @type {*} */",
	{ desc = "Add JSDoc Type in the above line" },
	{ noremap = true, silent = true }
)
keymap.set(
	"n",
	"<leader>jf",
	"O/**<CR>foo<CR>@param {*} param<CR>@return {*} return<CR>/",
	{ desc = "Add JSDoc Function in the above line" },
	{ noremap = true, silent = true }
)
keymap.set(
	"n",
	"<leader>jd",
	"O/**<CR>Type Def<CR>@typedef {Object} TypeName<CR>@property {*} property<CR>/",
	{ desc = "Add JSDoc Type Definition in the above line" },
	{ noremap = true, silent = true }
)

-- JS Web Components
keymap.set(
	"n",
	"<leader>wc",
	'Oclass MyComponent extends HTMLElement {<CR>constructor() {<CR>super();<CR>}<CR><CR>connectedCallback() {}<CR><CR>render() {<CR>this.innerHTML = "<div>My Component</div>";<CR>}<CR>}<CR><CR>window.customElements.define("my-component", MyComponent);<CR>',
	{ desc = "Create basic Web Component boilerplate" },
	{ noremap = true, silent = true }
)
keymap.set(
	"n",
	"<leader>wa",
	'Ostatic get observedAttributes() {<CR>return ["example"];<CR>}<CR><CR>attributeChangedCallback(name, oldValue, newValue) {<CR>switch (name) {<CR>case "example":<CR>break;<CR>default:<CR>break;<CR>}<CR>}<CR>',
	{ desc = "Add attribute changes observer to a Web Component" },
	{ noremap = true, silent = true }
)

-- Select everything
keymap.set("n", "<C-a>", "ggVG", { desc = "Select everything inside a file" }, { noremap = true, silent = true })

-- Make Tab key do a Tab character
keymap.set("i", "<Tab>", "<C-v><Tab>", { desc = "Make Tab key do a Tab character" }, { noremap = false, silent = true })

-- Stay in indent mode
keymap.set("v", "<", "<gv^", { silent = true })
keymap.set("v", ">", ">gv^", { silent = true })

-- Move text up and down
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })
keymap.set("v", "p", '"_dP', { silent = true })

-- Moving Screen horizontaly
keymap.set("n", "zh", "zH", { silent = true })
keymap.set("n", "zl", "zL", { silent = true })
