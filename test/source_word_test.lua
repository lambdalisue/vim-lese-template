local t = require("lese.testing")
local host = require("lese.host")
local builtin = require("lese.builtin")
local word = require("lese-zorvex.source.word")

local function scratch(lines)
  host.cmd("silent! enew")
  host.cmd("setlocal bufhidden=hide")
  host.fn.setline(1, lines)
  return host.fn.bufnr("%")
end

t.describe("lese-zorvex.source.word", function()
  t.it("emits each word of the current buffer once, where it first occurs", function()
    local bufnr = scratch({ "foo bar", "  bar baz_1 foo" })
    local items = t.collect(word())
    t.eq(t.values(items), { "foo", "bar", "baz_1" })
    t.eq(items[3], {
      id = "baz_1",
      value = "baz_1",
      detail = { bufnr = bufnr, line = 2, column = 7 },
    })
  end)

  t.it("treats only ASCII letters, digits and underscores as word characters", function()
    scratch({ "a-b.c(d) e/f_g 42" })
    t.eq(t.values(t.collect(word())), { "a", "b", "c", "d", "e", "f_g", "42" })
  end)

  t.it("skips words shorter than min_length", function()
    scratch({ "a an the a" })
    t.eq(t.values(t.collect(word({ min_length = 3 }))), { "the" })
  end)

  t.it("reads the file named by the first argument", function()
    local path = host.fn.tempname()
    host.fn.writefile({ "alpha beta", "gamma" }, path)
    scratch({ "unrelated" })
    local items = t.collect(word(), { args = { path } })
    t.eq(t.values(items), { "alpha", "beta", "gamma" })
    t.eq(items[3].detail, { bufnr = host.fn.bufnr(path), line = 2, column = 1 })
  end)

  t.it("emits nothing for an empty buffer", function()
    scratch({})
    t.eq(t.collect(word()), {})
  end)

  t.it("keeps each word once across the chunks it reads", function()
    scratch({ "foo", "bar", "foo", "baz" })
    t.eq(t.values(t.collect(word({ chunk_size = 1 }))), { "foo", "bar", "baz" })
  end)

  t.it("narrows the words with fzf in a picker", function()
    scratch({ "lorem ipsum dolor sit amet", "consectetur adipiscing elit" })
    local screen =
      t.picker({ source = word(), matchers = { builtin.matcher.fzf() } }):type("it"):screen()
    t.snapshot(screen)
  end)
end)
