local define = require("lese.define")

---@class lese-zorvex.source.WordDetail
---@field bufnr integer   -- the buffer the word was read from
---@field line integer    -- 1-based line where the word first occurs
---@field column integer  -- 1-based byte column where the word first occurs

---@class lese-zorvex.source.WordOptions
---@field min_length? integer  -- shorter words are skipped, default 1
---@field chunk_size? integer  -- lines read at once, default 1000

-- An explicit class rather than %w, whose meaning follows the C locale and so
-- may differ between the editors a test runs in.
local WORD = "[A-Za-z0-9_]+"

---Resolve the buffer named by `expr`: a buffer number, a file name (loaded
---when not yet), or nil for the current buffer.
---@param fn table
---@param expr string?
---@return integer
local function resolve_buffer(fn, expr)
  if expr == nil then
    return fn.bufnr("%")
  end
  local bufnr = tonumber(expr) or fn.bufadd(expr)
  fn.bufload(bufnr)
  return bufnr
end

---Emits each word of the buffer or file in `args[1]` (default: the current
---buffer) once, in the order the words first occur.
---@param opts? lese-zorvex.source.WordOptions
---@return lese.Source
return function(opts)
  opts = opts or {}
  local min_length = opts.min_length or 1
  local chunk_size = opts.chunk_size or 1000

  return define.source({
    name = "lese-zorvex.source.word",
    collect = function(ctx, params)
      local fn = ctx.host.fn
      local bufnr = resolve_buffer(fn, params.args[1])
      local count = fn.getbufinfo(bufnr)[1].linecount
      local seen = {}
      local lnum = 1
      while lnum <= count do
        local items = {}
        for i, text in ipairs(fn.getbufline(bufnr, lnum, lnum + chunk_size - 1)) do
          local line = lnum + i - 1
          local s, e = string.find(text, WORD)
          while s do
            local w = string.sub(text, s, e)
            if #w >= min_length and not seen[w] then
              seen[w] = true
              items[#items + 1] = {
                id = w,
                value = w,
                detail = { bufnr = bufnr, line = line, column = s },
              }
            end
            s, e = string.find(text, WORD, e + 1)
          end
        end
        ctx:emit(items)
        ctx:checkpoint()
        lnum = lnum + chunk_size
      end
    end,
  })
end
