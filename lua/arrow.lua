-- ~/.config/nvim/lua/arrow.lua
-- Draw ASCII arrows aligned to visual block columns/rows.
-- Vertical: <leader>u (up, ^) and <leader>d (down, v)
-- Horizontal: <leader>l (left, <) and <leader>r (right, >)
-- Invoked via visual-range mappings so marks are fresh on first run.
vim.opt.virtualedit = "all"

local M = {}

local function send_escape()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", true)
end

-- Binary-search helper: smallest character count i such that display width(prefix) >= target_display
local function chars_before_for_display(line, target_display)
  local total_chars = vim.fn.strchars(line)
  local lo, hi = 0, total_chars
  while lo < hi do
    local mid = math.floor((lo + hi) / 2)
    local prefix = vim.fn.strcharpart(line, 0, mid)
    local w = vim.fn.strdisplaywidth(prefix)
    if w >= target_display then
      hi = mid
    else
      lo = mid + 1
    end
  end
  return lo
end

-- Vertical arrow drawer (force direction: "up" or "down")
function M.draw_vertical_arrow_visual(direction)
  direction = direction or "down"

  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")
  local s_line = s_pos[2] or 0
  local e_line = e_pos[2] or 0

  local top = math.min(s_line, e_line)
  local bottom = math.max(s_line, e_line)

  local target_display = math.min(vim.fn.virtcol("'<"), vim.fn.virtcol("'>"))
  if target_display < 1 then target_display = 1 end

  local is_upward = (direction == "up")

  for lnum = top, bottom do
    local is_tip = false
    local arrow
    if is_upward then
      if lnum == top then arrow = "^"; is_tip = true else arrow = "|" end
    else
      if lnum == bottom then arrow = "v"; is_tip = true else arrow = "|" end
    end

    local line = vim.fn.getline(lnum) or ""
    local cur_display = vim.fn.strdisplaywidth(line)
    local desired_prefix_display = target_display - 1

    if cur_display < desired_prefix_display then
      local needed = desired_prefix_display - cur_display
      line = line .. string.rep(" ", needed)
      vim.fn.setline(lnum, line .. arrow)
    else
      local chars_before = chars_before_for_display(line, desired_prefix_display)
      local prefix = vim.fn.strcharpart(line, 0, chars_before)
      local prefix_w = vim.fn.strdisplaywidth(prefix)
      if prefix_w > desired_prefix_display and chars_before > 0 then
        chars_before = chars_before - 1
      end
      local before = vim.fn.strcharpart(line, 0, chars_before) or ""
      local after  = vim.fn.strcharpart(line, chars_before + 1, 1000000) or ""
      vim.fn.setline(lnum, before .. arrow .. after)
    end
  end

  send_escape()
end

-- Horizontal arrow drawer (force direction: "left" or "right")
-- Behavior:
--  - Use the visual block's left/right display columns as the horizontal span.
--  - Replace the character range between left and right with '-' and place tip '<' or '>' at the chosen end.
--  - Pads lines with spaces if they are too short to reach the right column.
function M.draw_horizontal_arrow_visual(direction)
  direction = direction or "right"

  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")
  local s_line = s_pos[2] or 0
  local e_line = e_pos[2] or 0

  local top = math.min(s_line, e_line)
  local bottom = math.max(s_line, e_line)

  -- compute left/right display columns (1-based)
  local left_display = math.min(vim.fn.virtcol("'<"), vim.fn.virtcol("'>"))
  local right_display = math.max(vim.fn.virtcol("'<"), vim.fn.virtcol("'>"))
  if left_display < 1 then left_display = 1 end
  if right_display < 1 then right_display = 1 end

  -- desired prefix displays (we treat prefix display as display columns before the insertion point)
  local left_prefix_display = left_display - 1
  local right_prefix_display = right_display - 1

  for lnum = top, bottom do
    local line = vim.fn.getline(lnum) or ""
    local cur_display = vim.fn.strdisplaywidth(line)

    -- ensure the line is long enough to reach the right prefix display
    if cur_display < right_prefix_display then
      local needed = right_prefix_display - cur_display
      line = line .. string.rep(" ", needed)
      -- update the buffer now so subsequent char-index calculations are consistent
      vim.fn.setline(lnum, line)
    end

    -- recompute on the (possibly) padded line
    line = vim.fn.getline(lnum) or ""
    -- find character indices for left and right prefix positions
    local chars_left = chars_before_for_display(line, left_prefix_display)
    local prefix_left = vim.fn.strcharpart(line, 0, chars_left)
    local prefix_left_w = vim.fn.strdisplaywidth(prefix_left)
    if prefix_left_w > left_prefix_display and chars_left > 0 then
      chars_left = chars_left - 1
    end

    local chars_right = chars_before_for_display(line, right_prefix_display)
    local prefix_right = vim.fn.strcharpart(line, 0, chars_right)
    local prefix_right_w = vim.fn.strdisplaywidth(prefix_right)
    if prefix_right_w > right_prefix_display and chars_right > 0 then
      chars_right = chars_right - 1
    end

    if chars_right < chars_left then
      -- nothing to draw; place tip at left position
      local before = vim.fn.strcharpart(line, 0, chars_left) or ""
      local after  = vim.fn.strcharpart(line, chars_left + 1, 1000000) or ""
      if direction == "right" then
        vim.fn.setline(lnum, before .. ">" .. after)
      else
        vim.fn.setline(lnum, before .. "<" .. after)
      end
    else
      local before = vim.fn.strcharpart(line, 0, chars_left) or ""
      local after  = vim.fn.strcharpart(line, chars_right + 1, 1000000) or ""
      local middle_len = chars_right - chars_left
      if middle_len < 0 then middle_len = 0 end
      local middle = string.rep("-", middle_len)
      if direction == "right" then
        -- place '>' at the right tip
        vim.fn.setline(lnum, before .. middle .. ">" .. after)
      else
        -- place '<' at the left tip
        vim.fn.setline(lnum, before .. "<" .. middle .. after)
      end
    end
  end

  send_escape()
end

-- Visual-range mappings (force directions explicitly)
vim.api.nvim_set_keymap('x', '<leader>u', ":<C-U>lua require('arrow').draw_vertical_arrow_visual('up')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>d', ":<C-U>lua require('arrow').draw_vertical_arrow_visual('down')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>r', ":<C-U>lua require('arrow').draw_horizontal_arrow_visual('right')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>l', ":<C-U>lua require('arrow').draw_horizontal_arrow_visual('left')<CR>", { noremap = true, silent = true })

return M
