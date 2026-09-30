vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
-- Clipboard: let nvim auto-detect the native tool (pbcopy on macOS, xclip on desktop Linux);
-- only force OSC 52 on headless machines (no display, no native tool) so yank still
-- reaches the local clipboard through the terminal.
if vim.fn.executable("pbcopy") == 0 and not vim.env.DISPLAY and not vim.env.WAYLAND_DISPLAY then
  -- Headless: copy via OSC 52 (terminal writes it to the local clipboard).
  -- OSC 52 *paste* (clipboard query) is only answered by a few terminals;
  -- elsewhere nvim waits ~10s ("Press Ctrl-C to interrupt"). So paste is
  -- served from nvim's own last-yank cache instead: `yy` -> `p` works.
  -- For external text use the terminal paste: Ctrl-Shift-V / CMD-v.
  local osc52 = require("vim.ui.clipboard.osc52")
  local last = {} -- reg -> { lines, regtype } of last yank
  local function make(reg, sel)
    local emit = osc52.copy(sel)
    return function(lines, regtype)
      last[reg] = { lines = lines, regtype = regtype }
      pcall(emit, lines)
    end
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = make("+", "+"), ["*"] = make("*", "*") },
    paste = {
      ["+"] = function()
        local l = last["+"]
        return l and { l.lines, l.regtype } or {}
      end,
      ["*"] = function()
        local l = last["*"]
        return l and { l.lines, l.regtype } or {}
      end,
    },
  }
end
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "auto"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 4
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
