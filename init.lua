-- ~/.config/nvim/init.lua
--
-- Basic settings
vim.opt.number = true          -- Show line numbers
--vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.tabstop = 2            -- 2 spaces for tabs
vim.opt.shiftwidth = 2         -- 2 spaces for indent width
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.smartindent = true     -- Auto-indent new lines
vim.opt.termguicolors = true   -- Enable 24-bit RGB colors
vim.opt.cursorline = true      -- Highlight current line

-- Set clipboard to use the system clipboard
-- `vim.o` is used to set global options
vim.o.clipboard = 'unnamedplus'


-- Leader key (set before plugins)
vim.g.mapleader = " "          -- Set leader to spacebar
vim.g.maplocalleader = " "     -- Set local leader to spacebar

-- Basic keybindings
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })  -- Save with <leader>w
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })       -- Quit with <leader>q
-- vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })  -- Navigate windows
-- vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
-- vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
-- vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- init.lua

-- Ensure Lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup Lazy.nvim and define plugins
require('lazy').setup({
  -- Treesitter
  {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},

  -- Gruvbox color scheme
  { 'morhetz/gruvbox' },

  -- Catppuccin color scheme
  { 'catppuccin/nvim', as = 'catppuccin' },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Telescope file browser
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },

  -- Oil
  {
    "stevearc/oil.nvim"
  },

  -- lualine
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Optional: for filetype icons
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto', -- or choose a specific theme like 'dracula', 'tokyonight', etc.
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'filetype', 'encoding', 'fileformat'},
          lualine_y = {'progress'},
          lualine_z = {'location', {
            function()
	      local clock_icon = '' -- Ensure it's like this, with proper quotes.
              return clock_icon .. ' ' .. os.date("%H:%M") -- Displays current time in HH:MM format
            end,
          }},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        extensions = {},
      }
    end,
  },
  -- blink.cmp
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  },
  -- render-markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  }
})

-- Set Catppuccin color scheme
vim.cmd('colorscheme catppuccin')

-- Telescope Key bindings
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope file_browser<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })


require('telescope').setup {
  defaults = {
    -- You might put global defaults here, but specific picker configs are often better
  },
  pickers = {
    find_files = {
      -- This will sort by modification time (most recent first)
      find_command = {"rg", "--files", "--sortr=modified"},
    },
    -- You might need to configure file_browser specifically if it doesn't
    -- pick up the find_files default automatically for its listing.
    -- However, it often does.
  },
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      display_stat = false,  -- Enable display_stat
      mappings = {
        ["i"] = {
          -- Your custom insert mode mappings
        },
        ["n"] = {
          -- Your custom normal mode mappings
        },
      },
    },
  },
}

-- Function to save a file with a given base name and append the date
-- Returns true on success, false on failure (e.g., file already exists or no filename given)
local function save_file_with_dated_name(args)
    -- Check if a filename was provided
    if not args or args.fargs[1] == nil or args.fargs[1] == '' then
        vim.notify('Usage: :SaveDatedNew <filename> (e.g., :SaveDatedNew MyDocument)', vim.log.levels.ERROR)
        return false -- Indicate failure
    end

    local base_name = args.fargs[1]
    local date = os.date('%Y%m%d')
    local extension = 'md' -- Assuming you always want .md for this command

    local new_filename = base_name .. '_' .. date .. '.' .. extension

    -- Get the current working directory to save the file
    local current_dir = vim.fn.getcwd()
    local new_filepath = current_dir .. '/' .. new_filename

    -- Check if the file already exists
    if vim.fn.filereadable(new_filepath) == 0 then
        -- Write the current buffer content to the new file path
        vim.cmd('write ' .. new_filepath)

        -- Change the current buffer's name to the newly saved file
        vim.cmd('file ' .. new_filepath)
        -- *** CRITICAL ADDITION: Mark the current buffer as no longer modified ***
        -- This tells Neovim the buffer is now clean relative to its current filename.
        vim.cmd('set nomodified')

        return true -- Indicate success
    else
        -- If the file exists, notify the user and do not overwrite
        vim.notify("Error: File already exists with dated name: " .. new_filepath .. ". Not overwriting.", vim.log.levels.ERROR)
        return false -- Indicate failure
    end
end

-- New command: WQDated - saves and then quits
local function wq_dated_command(args)
    -- Reuse the existing save_file_with_dated_name function
    local success = save_file_with_dated_name(args)

    -- Only proceed to quit if the save operation was successful
    if success then
        vim.notify("Save was successful. Attempting to quit...", vim.log.levels.INFO) -- DEBUG INFO
        -- Using 'quit!' to force exit, discarding changes in other unsaved buffers.
        -- WARNING: This will discard changes in other buffers if they are unsaved.
        -- If you want to save *all* modified buffers before quitting, consider 'wqall'.
        vim.cmd('quit!')
    else
        vim.notify("Save was NOT successful. Not quitting.", vim.log.levels.WARN) -- DEBUG INFO
        -- An error message would have already been displayed by save_file_with_dated_name
        -- No need to do anything further here, as the user needs to resolve the save issue.
    end
end

-- Define the custom command for WQDated
vim.api.nvim_create_user_command('WQDated', wq_dated_command, {
    nargs = 1, -- The command takes exactly one argument (the base filename)
    complete = 'file', -- Provide file completion for the argument
    bar = false, -- It's generally not recommended to chain commands after a 'quit' command
    desc = 'Save the current buffer with a given name and date suffix, then quit (e.g., :WQDated MyDoc -> MyDoc_YYYYMMdd.md)',
})

-- Define the custom command
vim.api.nvim_create_user_command('SaveDated', save_file_with_dated_name, {
    nargs = 1, -- The command takes exactly one argument (the base filename)
    complete = 'file', -- Provide file completion for the argument (optional, but good practice)
    bar = true, -- Allows chaining other commands
    desc = 'Save the current buffer with a given name and date suffix (e.g., :SaveDatedNew MyDoc -> MyDoc_YYYYMMdd.md)',
})

-- Oil
require("oil").setup()

-- arrow
require("arrow")
-- box
require("box")
