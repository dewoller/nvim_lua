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
