require "nvchad.mappings"

local map = vim.keymap.set

-- General mappings
map("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "TMUX window left" })
map("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "TMUX window right" })
map("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "TMUX window down" })
map("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "TMUX window up" })

-- Use j and k as gj and gk
map("n", "j", "gj", { desc = "Move down by visual line" })
map("n", "k", "gk", { desc = "Move up by visual line" })
map("v", "j", "gj", { desc = "Move down by visual line" })
map("v", "k", "gk", { desc = "Move up by visual line" })

vim.keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete the whole word in insert mode" })

map({ "n", "t" }, "<leader>tv", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal vertical toggle" })

map({ "n", "t" }, "<leader>tt", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal horizontal toggle" })

-- Persistence mappings
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Persistence Restore Session" })
map("n", "<leader>ql", function()
  require("persistence").load { last = true }
end, { desc = "Persistence Restore Last Session" })
map("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Persistence Don't Save Current Session" })

-- LSP mappings

map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "LSP Info" })
map("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "LSP Mason" })
map("n", "<leader>lf", function()
  vim.diagnostic.open_float { border = "rounded" }
end, { desc = "LSP Floating diagnostic" })

-- gitsigns mappings
map("n", "<leader>ph", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Gitsigns Git preview hunk" })
map("n", "<leader>ph", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Gitsigns Preview hunk" })
map("n", "<leader>bl", "<cmd>Gitsigns blame_line<CR>", { desc = "Gitsigns Blame line" })
map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Gitsigns Toggle line blame" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Gitsigns Diff this" })
map("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Gitsigns Next hunk" })
map("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Gitsigns Previous hunk" })
