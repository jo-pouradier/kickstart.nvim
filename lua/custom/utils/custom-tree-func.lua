local M = {}

function M.on_attach_tree(bufnr)
  local api = require 'nvim-tree.api'
  local FloatPreview = require 'float-preview'
  -- api.node.open.preview = Open_or_expand_or_dir_up_with_node_no_edit()
  api.node.open.preview = M.open_or_expand_or_dir_up_with_node_no_edit()

  FloatPreview.attach_nvimtree(bufnr)
  local close_wrap = FloatPreview.close_wrap
  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
  -- BEGIN_DEFAULT_ON_ATTACH
  M.keymaps(api, close_wrap, opts)
end

--- Rewrite of nvim-tree open_or_expand_or_dir_up
--- so it does not open the preview in the background
---@param mode string
---@return fun(node: table)
local function open_or_expand_or_dir_up(mode, toggle_group)
  local lib = require 'nvim-tree.lib'
  local actions = require 'nvim-tree.actions'
  return function(node)
    if node.name == '..' then
      actions.root.change_dir.fn '..'
    elseif node.nodes then
      lib.expand_or_collapse(node, toggle_group)
    end
    -- elseif not toggle_group then
    --   edit(mode, node)
    -- end
  end
end

---Inject the node as the first argument if absent.
---@param fn function function to invoke
local function wrap_node(fn)
  local lib = require 'nvim-tree.lib'
  return function(node, ...)
    node = node or lib.get_node_at_cursor()
    if node then
      fn(node, ...)
    end
  end
end

function M.open_or_expand_or_dir_up_with_node_no_edit()
  return wrap_node(open_or_expand_or_dir_up 'preview')
end

function M.calculate_window_size(width_ratio, height_ratio, col_offset, margin)
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

function M.tree_window_size()
  local size = M.calculate_window_size(0.25, 0.7, 0.25)
  return {
    relative = 'editor',
    border = 'rounded',
    width = size.width,
    height = size.height,
    row = size.row,
    col = size.col,
  }
end

function M.tree_preview_window_size()
  local size = M.calculate_window_size(0.25, 0.7, 0.5, 13)
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

--- Set keymaps
--- @param api any
--- @param close_wrap function
--- @param opts function
--- @return boolean
function M.keymaps(api, close_wrap, opts)
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
  vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts 'Info')
  -- vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
  vim.keymap.set('n', '<C-s>', close_wrap(api.node.open.horizontal), opts 'Open: Horizontal Split')
  vim.keymap.set('n', '<CR>', close_wrap(api.node.open.edit), opts 'Open')
  vim.keymap.set('n', '<C-t>', close_wrap(api.node.open.tab), opts 'Open: New Tab')
  vim.keymap.set('n', '<C-v>', close_wrap(api.node.open.vertical), opts 'Open: Vertical Split')
  -- vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
  vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
  -- vim.keymap.set('n', '<Tab>',   api.node.open.preview,               opts('Open Preview'))
  vim.keymap.set('n', '<Tab>', close_wrap(api.node.open.preview), opts 'Open preview')
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
  vim.keymap.set('n', '.', api.node.run.cmd, opts 'Run Command')
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts 'Up')
  -- vim.keymap.set('n', 'a', api.fs.create, opts 'Create File Or Directory')
  vim.keymap.set('n', 'a', close_wrap(api.fs.create), opts 'Create')
  vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts 'Delete Bookmarked')
  vim.keymap.set('n', 'bt', api.marks.bulk.trash, opts 'Trash Bookmarked')
  vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
  vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle Filter: No Buffer')
  vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
  vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Filter: Git Clean')
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
  -- vim.keymap.set('n', 'd', api.fs.remove, opts 'Delete')
  vim.keymap.set('n', 'd', close_wrap(api.fs.remove), opts 'Delete')
  vim.keymap.set('n', 'D', api.fs.trash, opts 'Trash')
  vim.keymap.set('n', 'E', api.tree.expand_all, opts 'Expand All')
  vim.keymap.set('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
  vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
  vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
  vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Live Filter: Clear')
  vim.keymap.set('n', 'f', api.live_filter.start, opts 'Live Filter: Start')
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts 'Help')
  vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
  vim.keymap.set('n', 'ge', api.fs.copy.basename, opts 'Copy Basename')
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Filter: Dotfiles')
  vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Filter: Git Ignore')
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
  vim.keymap.set('n', 'L', api.node.open.toggle_group_empty, opts 'Toggle Group Empty')
  vim.keymap.set('n', 'M', api.tree.toggle_no_bookmark_filter, opts 'Toggle Filter: No Bookmark')
  vim.keymap.set('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
  -- vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
  -- vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
  vim.keymap.set('n', 'o', close_wrap(api.node.open.edit), opts 'Open')
  vim.keymap.set('n', 'O', close_wrap(api.node.open.no_window_picker), opts 'Open: No Window Picker')

  vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
  vim.keymap.set('n', 'q', close_wrap(api.tree.close), opts 'Close')
  vim.keymap.set('n', '<ESC>', close_wrap(api.tree.close), opts 'Close')
  -- vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
  vim.keymap.set('n', 'r', close_wrap(api.fs.rename), opts 'Rename')
  vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
  vim.keymap.set('n', 's', api.node.run.system, opts 'Run System')
  vim.keymap.set('n', 'S', api.tree.search_node, opts 'Search')
  vim.keymap.set('n', 'u', api.fs.rename_full, opts 'Rename: Full Path')
  vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Filter: Hidden')
  vim.keymap.set('n', 'W', api.tree.collapse_all, opts 'Collapse')
  vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
  vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
  vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')

  -- END_DEFAULT_ON_ATTACH

  return true
end

return M
