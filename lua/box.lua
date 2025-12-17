-- ~/.config/nvim/lua/box.lua
-- Draw ASCII boxes aligned to visual block columns/rows.
-- Invoked via visual-range mapping so marks are fresh on first run.
vim.opt.virtualedit = "all"

local M = {}

-- helper: binary search to find smallest character count i
-- such that display width(prefix) >= target_display
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

local function send_escape()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", true)
end

-- Box drawer: wraps the visual block selection with +---+ / |   | / +---+
function M.draw_box_visual()
  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")
  local top = math.min(s_pos[2], e_pos[2])
  local bottom = math.max(s_pos[2], e_pos[2])

  local left_display = math.min(vim.fn.virtcol("'<"), vim.fn.virtcol("'>"))
  local right_display = math.max(vim.fn.virtcol("'<"), vim.fn.virtcol("'>"))
  if left_display < 1 then left_display = 1 end
  if right_display < 1 then right_display = 1 end

  local left_prefix_display = left_display - 1
  local right_prefix_display = right_display - 1

  for lnum = top, bottom do
    local line = vim.fn.getline(lnum) or ""
    local cur_display = vim.fn.strdisplaywidth(line)

    -- pad line if too short
    if cur_display < right_prefix_display then
      line = line .. string.rep(" ", right_prefix_display - cur_display)
      vim.fn.setline(lnum, line)
    end

    line = vim.fn.getline(lnum) or ""

    local chars_left = chars_before_for_display(line, left_prefix_display)
    local chars_right = chars_before_for_display(line, right_prefix_display)

    local before = vim.fn.strcharpart(line, 0, chars_left) or ""
    local inside = vim.fn.strcharpart(line, chars_left + 1, chars_right - chars_left) or ""
    local after  = vim.fn.strcharpart(line, chars_right + 1, 1000000) or ""

    if lnum == top or lnum == bottom then
      local middle = string.rep("-", #inside)
      vim.fn.setline(lnum, before .. "+" .. middle .. "+" .. after)
    else
      local padding = string.rep(" ", #inside - #inside) -- keep symmetry
      vim.fn.setline(lnum, before .. "|" .. inside .. padding .. "|" .. after)
    end
  end

  send_escape()
end

-- Visual-range mapping
vim.api.nvim_set_keymap('x', '<leader>b',
  ":<C-U>lua require('box').draw_box_visual()<CR>",
  { noremap = true, silent = true })

return M
