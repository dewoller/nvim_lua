-- Headless smoke tests for this Neovim config.
-- Run via tests/run.sh, which loads the real config and executes this file.
-- Exits 0 when every case passes, 1 otherwise.

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local fixtures = root .. "/tests/fixtures/"

local results = {}
local function case(group, name, fn)
  local ok, err = pcall(fn)
  table.insert(results, { group = group, name = name, ok = ok, err = err })
end

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error(("%s: expected %s, got %s"):format(msg, vim.inspect(expected), vim.inspect(actual)), 0)
  end
end

local function assert_true(v, msg)
  if not v then error(msg, 0) end
end

local function open(file)
  vim.cmd("silent edit! " .. fixtures .. file)
  return vim.api.nvim_get_current_buf()
end

local function wait_for_client(bufnr, name)
  local found
  vim.wait(15000, function()
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if c.name == name then found = c return true end
    end
    return false
  end, 100)
  return found
end

-- Telescope and treesitter both load on demand; capture anything noisy.
local captured = {}
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  table.insert(captured, msg)
  return orig_notify(msg, level, opts)
end

---------------------------------------------------------------------------
-- Unit: keymaps and options, no buffers involved
---------------------------------------------------------------------------

case("unit", "lsp rename map has a single <CR>", function()
  open("sample.lua")
  wait_for_client(0, "lua_ls")
  local m = vim.fn.maparg("<Space>r", "n", false, true)
  assert_true(m.rhs ~= nil or m.callback ~= nil, "<Space>r not mapped in an LSP buffer")
  if m.rhs then
    assert_true(not m.rhs:upper():find("<CR><CR>$"), "rename rhs ends in <CR><CR>: " .. m.rhs)
  end
end)

case("unit", "lsp-zero default keymaps (gd) apply in LSP buffers", function()
  open("sample.lua")
  wait_for_client(0, "lua_ls")
  local gd = vim.fn.maparg("gd", "n", false, true)
  assert_eq(gd.buffer, 1, "gd buffer-local LSP map")
end)

case("unit", "no builtin gr* maps make gr ambiguous", function()
  open("sample.lua")
  wait_for_client(0, "lua_ls")
  for _, lhs in ipairs({ "grr", "grn", "gri", "gra", "grt", "grx" }) do
    assert_eq(vim.fn.maparg(lhs, "n"), "", "nmap " .. lhs)
  end
end)

-- In a terminal (Claude Code's ctrl-g editor), nvim only recolours the
-- cursor when 'guicursor' names a highlight group; otherwise the terminal's
-- own cursor colour is used and vanishes against tokyonight's cursorline.
case("unit", "terminal cursor takes its colour from the Cursor group", function()
  for _, mode in ipairs({ "n", "i" }) do
    local entry
    for part in vim.o.guicursor:gmatch("[^,]+") do
      local modes = part:match("^([^:]+):")
      if modes and vim.tbl_contains(vim.split(modes, "-"), mode) then entry = part break end
    end
    assert_true(entry and entry:find("Cursor"), mode .. "-mode guicursor lacks Cursor: " .. tostring(entry))
  end
  local hl = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
  local cl = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
  assert_true(hl.bg ~= nil, "Cursor has no bg")
  assert_true(hl.bg ~= cl.bg, "Cursor bg equals CursorLine bg")
end)

case("unit", "cmp <C-d> scrolls docs down, <C-u> up", function()
  local cmp = require("cmp")
  local mapping = require("cmp.config").get().mapping
  local orig_visible, orig_scroll = cmp.visible_docs, cmp.scroll_docs
  local got = {}
  cmp.visible_docs = function() return true end
  cmp.scroll_docs = function(delta) table.insert(got, delta) return true end
  local ok, err = pcall(function()
    mapping["<C-D>"].i(function() end)
    mapping["<C-U>"].i(function() end)
  end)
  cmp.visible_docs, cmp.scroll_docs = orig_visible, orig_scroll
  assert_true(ok, tostring(err))
  assert_true(got[1] and got[1] > 0, "<C-d> delta " .. vim.inspect(got[1]))
  assert_true(got[2] and got[2] < 0, "<C-u> delta " .. vim.inspect(got[2]))
end)

case("unit", "lazy health has no errors", function()
  vim.cmd("silent checkhealth lazy")
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  vim.cmd("bwipeout!")
  assert_true(not text:find("ERROR"), "lazy health:\n" .. text)
end)

case("unit", "LSP keymaps are buffer-local, not global", function()
  vim.cmd("enew")
  local k = vim.fn.maparg("K", "n", false, true)
  assert_true(vim.tbl_isempty(k) or k.buffer == 1,
    "K is mapped globally: " .. vim.inspect(k.rhs or k.callback))
end)

---------------------------------------------------------------------------
-- Integration: filetype + treesitter + LSP
---------------------------------------------------------------------------

for _, ft in ipairs({ "lua", "py", "js", "ts" }) do
  case("integration", "treesitter highlighting active for ." .. ft, function()
    local b = open("sample." .. ft)
    vim.wait(2000, function() return vim.treesitter.highlighter.active[b] ~= nil end, 50)
    assert_true(vim.treesitter.highlighter.active[b] ~= nil, "no treesitter highlighter on sample." .. ft)
  end)
end

case("integration", "treesitter indentexpr set for .py", function()
  open("sample.py")
  assert_true(vim.bo.indentexpr:find("nvim%-treesitter") ~= nil,
    "indentexpr is " .. vim.inspect(vim.bo.indentexpr))
end)

case("integration", "treesitter textobject af is mapped", function()
  open("sample.py")
  assert_true(vim.fn.maparg("af", "o") ~= "", "omap af is empty")
end)

case("integration", "lua_ls receives diagnostics.globals = vim", function()
  local b = open("sample.lua")
  local c = wait_for_client(b, "lua_ls")
  assert_true(c ~= nil, "lua_ls did not attach")
  local globals = vim.tbl_get(c.settings, "Lua", "diagnostics", "globals") or {}
  assert_true(vim.tbl_contains(globals, "vim"), "globals = " .. vim.inspect(globals))
end)

case("integration", "r_language_server does not start", function()
  local b = open("sample.R")
  assert_true(not vim.lsp.is_enabled("r_language_server"), "r_language_server is enabled")
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = b })) do
    assert_true(c.name ~= "r_language_server", "r_language_server attached")
  end
end)

---------------------------------------------------------------------------
-- E2E: workflows that span buffers
---------------------------------------------------------------------------

case("e2e", "opening an R file does not leak maps into other buffers", function()
  open("sample.R")
  vim.cmd("enew")
  -- X is left out: cutlass.nvim legitimately maps it globally to "_X.
  for _, lhs in ipairs({ "V", "Q", "Z", "L" }) do
    assert_eq(vim.fn.maparg(lhs, "n"), "", "global nmap " .. lhs)
  end
end)

case("e2e", "opening a Python file does not leak maps or globals", function()
  open("sample.py")
  vim.cmd("enew")
  assert_eq(vim.fn.maparg("gz", "n"), "", "global nmap gz")
  assert_eq(_G.setupKeyBindings, nil, "_G.setupKeyBindings")
end)

case("e2e", "counted j moves real lines; bare j moves screen lines", function()
  vim.cmd("enew")
  vim.wo.wrap = true
  local long = string.rep("word ", 100)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { long, long, long, long })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_feedkeys("2j", "mx", false)
  assert_eq(vim.api.nvim_win_get_cursor(0)[1], 3, "line after 2j")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_feedkeys("j", "mx", false)
  assert_eq(vim.api.nvim_win_get_cursor(0)[1], 1, "line after bare j on wrapped line")
  vim.cmd("bwipeout!")
end)

case("e2e", "ginit.vim (sourced by nvim-qt) loads the GUI helpers", function()
  local ginit = vim.fn.stdpath("config") .. "/ginit.vim"
  assert_eq(vim.fn.filereadable(ginit), 1, "ginit.vim readable")
  -- Stand-in for nvim-qt's shim function; records the requested state.
  vim.cmd("function! GuiWindowMaximized(enabled)\n let g:test_maximized = a:enabled\nendfunction")
  package.loaded["ginit"] = nil
  vim.cmd("source " .. ginit)
  assert_eq(vim.fn.exists("*AdjustFontSize"), 1, "AdjustFontSize defined")
  assert_eq(vim.g.test_maximized, 1, "GuiWindowMaximized called with")
  vim.cmd("delfunction GuiWindowMaximized")
end)

case("e2e", "Telescope opens without deprecation warnings", function()
  open("sample.py")
  captured = {}
  vim.cmd("messages clear")
  vim.cmd("Telescope find_files")
  vim.wait(1000, function() return false end, 50)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc><Esc>", true, true, true), "x", false)
  local msgs = vim.fn.execute("messages") .. table.concat(captured, "\n")
  assert_true(not msgs:find("deprecated"), "deprecation output: " .. msgs)
end)

vim.notify = orig_notify

---------------------------------------------------------------------------
local failed = 0
for _, r in ipairs(results) do
  if r.ok then
    io.stdout:write(("PASS [%s] %s\n"):format(r.group, r.name))
  else
    failed = failed + 1
    io.stdout:write(("FAIL [%s] %s\n     %s\n"):format(r.group, r.name, tostring(r.err)))
  end
end
io.stdout:write(("\n%d passed, %d failed\n"):format(#results - failed, failed))
vim.cmd(failed == 0 and "qa!" or "cquit! 1")
