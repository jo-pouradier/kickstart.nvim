-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

local function on_attach_tree(bufnr)
  local api = require 'nvim-tree.api'
  local FloatPreview = require 'float-preview'

  FloatPreview.attach_nvimtree(bufnr)
  local close_wrap = FloatPreview.close_wrap

  vim.keymap.set('n', '<C-t>', close_wrap(api.node.open.tab), { desc = 'Open: New Tab', buffer = bufnr })
  vim.keymap.set('n', '<C-v>', close_wrap(api.node.open.vertical), { desc = 'Open: Vertical Split', buffer = bufnr })
  vim.keymap.set('n', '<C-s>', close_wrap(api.node.open.horizontal), { desc = 'Open: Horizontal Split', buffer = bufnr })
  vim.keymap.set('n', '<CR>', close_wrap(api.node.open.edit), { desc = 'Open', buffer = bufnr })
  vim.keymap.set('n', '<Tab>', close_wrap(api.node.open.preview), { desc = 'Open preview', buffer = bufnr })

  vim.keymap.set('n', 'o', close_wrap(api.node.open.edit), { desc = 'Open', buffer = bufnr })
  vim.keymap.set('n', 'O', close_wrap(api.node.open.no_window_picker), { desc = 'Open: No Window Picker', buffer = bufnr })
  vim.keymap.set('n', 'a', close_wrap(api.fs.create), { desc = 'Create', buffer = bufnr })
  vim.keymap.set('n', 'd', close_wrap(api.fs.remove), { desc = 'Delete', buffer = bufnr })
  vim.keymap.set('n', 'r', close_wrap(api.fs.rename), { desc = 'Rename', buffer = bufnr })
end

local function calculate_window_size(width_ratio, height_ratio, col_offset, margin)
  local ui_info = vim.api.nvim_list_uis()[1]
  local gwidth = ui_info.width
  local gheight = ui_info.height
  local width = math.floor(gwidth * width_ratio)
  local height = math.floor(gheight * height_ratio)
  local col = (gwidth - width) * col_offset

  return {
    width = width,
    height = height,
    row = (gheight - height) * 0.5,
    col = col + (margin or 0),
  }
end

local function tree_window_size()
  local size = calculate_window_size(0.25, 0.7, 0.25)
  return {
    relative = 'editor',
    border = 'rounded',
    width = size.width,
    height = size.height,
    row = size.row,
    col = size.col,
  }
end

local function tree_preview_window_size()
  local size = calculate_window_size(0.25, 0.7, 0.5, 13)
  return {
    style = 'minimal',
    relative = 'editor',
    border = 'rounded',
    row = size.row,
    col = size.col,
    width = size.width,
    height = size.height,
  }
end

local tree_preview = {
  'JMarkin/nvim-tree.lua-float-preview',
  lazy = true,
  -- -- default
  opts = {
    -- Whether the float preview is enabled by default. When set to false, it has to be "toggled" on.
    toggled_on = true,
    -- wrap nvimtree commands
    wrap_nvimtree_commands = true,
    -- lines for scroll
    scroll_lines = 20,
    -- window config
    window = {
      wrap = false,
      trim_height = false,
      open_win_config = tree_preview_window_size,
    },
    mapping = {
      -- scroll down float buffer
      down = { '<C-d>' },
      -- scroll up float buffer
      up = { '<C-e>', '<C-u>' },
      -- enable/disable float windows
      toggle = { '<C-x>' },
    },
    -- hooks if return false preview doesn't shown
    hooks = {
      pre_open = function(path)
        -- if file > 5 MB or not text -> not preview
        local size = require('float-preview.utils').get_size(path)
        if type(size) ~= 'number' then
          return false
        end
        local is_text = require('float-preview.utils').is_text(path)
        return size < 5 and is_text
      end,
      post_open = function(bufnr)
        return true
      end,
    },
  },
}

return {
  {
    'ray-x/go.nvim',
    dependencies = { -- optional packages
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup()
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = tree_preview,
    config = function()
      require('nvim-tree').setup {
        on_attach = on_attach_tree,
        modified = {
          enable = true,
        },
        sort = {
          folders_first = true,
          sorter = 'case_sensitive',
        },
        view = {
          number = true,
          relativenumber = true,
          width = 20,
          float = {
            enable = true,
            open_win_config = tree_window_size,
          },
        },
        renderer = {
          group_empty = true,
          add_trailing = true,
          highlight_git = 'all',
        },
        filters = {
          dotfiles = false,
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },
        update_focused_file = {
          enable = true,
          -- update_cwd = true,
        },
      }
    end,
  },
}
