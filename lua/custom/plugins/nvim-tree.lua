local customTreeFunc = require 'custom.utils.custom-tree-func'

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
      open_win_config = customTreeFunc.tree_preview_window_size,
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
  'nvim-tree/nvim-tree.lua',
  dependencies = tree_preview,
  config = function()
    require('nvim-tree').setup {
      on_attach = function(bufnr)
        local api = require 'nvim-tree.api'
        local FloatPreview = require 'float-preview'
        local close_wrap = FloatPreview.close_wrap

        FloatPreview.attach_nvimtree(bufnr)

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.node.open.preview = customTreeFunc.open_or_expand_or_dir_up_with_node_no_edit()
        api.config.mappings.default_on_attach(bufnr)
        customTreeFunc.keymaps(api, close_wrap, opts)
      end,
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
          open_win_config = customTreeFunc.tree_window_size,
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
}
