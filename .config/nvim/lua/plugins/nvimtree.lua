return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        local is_dir = data.file ~= "" and vim.fn.isdirectory(data.file) == 1
        local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

        if is_dir then
          vim.cmd.cd(data.file)
          vim.cmd "NvimTreeOpen"
        elseif no_name then
          vim.cmd "NvimTreeOpen"
        end
      end,
    })
  end,
  opts = {
    filters = {
      git_ignored = false,
    },
    actions = {
      open_file = {
        quit_on_open = false,
      },
    },
  },
}
