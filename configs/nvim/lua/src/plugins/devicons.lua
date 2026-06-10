vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
})

vim.cmd("packadd " .. "nvim-web-devicons")

require("nvim-web-devicons").setup()

require("nvim-web-devicons").set_icon({
  gql = {
    icon = "",
    color = "#e535ab",
    cterm_color = "199",
    name = "GraphQL",
  },
})
