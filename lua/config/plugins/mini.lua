return {
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.statusline').setup()
      require('mini.icons').setup({ style = "nvim-web-devicons" })
    end,
    version = false
  },
}
