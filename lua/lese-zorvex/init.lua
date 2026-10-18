-- Loading this module declares nothing; users bring the pickers in from their
-- custom.lua with define_pickers.

local M = {}

---Declare the pickers this extension recommends:
---
---  - `zorvex-word`: the words of the current buffer, or of the file given as
---    the first argument
---
---Call it from custom.lua: `require("lese-zorvex").define_pickers(x)`.
---@param x lese.Entrypoint
function M.define_pickers(x)
  local builtin = require("lese.builtin")
  x.define_picker_from_source("zorvex-word", require("lese-zorvex.source.word")(), {
    matchers = { builtin.matcher.fzf() },
    actions = {
      echo = builtin.action.echo(),
      yank = builtin.action.yank(),
    },
    default_action = "echo",
  })
end

return M
