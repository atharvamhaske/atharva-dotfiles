require "nvchad.options"

-- add yours here!

local o = vim.opt
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = false
o.autoindent = true
o.smartindent = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "html" },
  callback = function()
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

pcall(function()
  require("gitsigns").setup {
    current_line_blame = true,
  }
end)
