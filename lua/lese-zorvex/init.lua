-- Loading this module declares nothing; users bring the pickers in from their
-- custom.lua with define_pickers.

---The sources lese-zorvex provides.
---@class lese-zorvex.Sources
---Emits each word of the buffer or file in `args[1]` (default: the current
---buffer) once, in the order the words first occur; `min_length` skips
---shorter words.
---@field word fun(opts?: lese-zorvex.source.WordOptions): lese.Source

---What `require("lese-zorvex")` returns.
---@class lese-zorvex
---Sources to build pickers of your own with.
---@field source lese-zorvex.Sources
local M = {}

M.source = {
  word = require("lese-zorvex.source.word"),
}

---Declare the pickers this extension recommends:
---
---  - `zorvex-word`: the words of the current buffer, or of the file given as
---    the first argument
---
---Call it from custom.lua: `require("lese-zorvex").define_pickers(x)`.
---@param x lese.Entrypoint
function M.define_pickers(x)
  local builtin = require("lese.builtin")
  x.define_picker_from_source("zorvex-word", M.source.word(), {
    matchers = { builtin.matcher.fzf() },
    actions = {
      echo = builtin.action.echo(),
      yank = builtin.action.yank(),
    },
    default_action = "echo",
  })
end

return M
