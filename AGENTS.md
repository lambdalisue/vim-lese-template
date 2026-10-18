# vim-lese-zorvex

An extension for [lese](https://github.com/lambdalisue/vim-lese), the Lua
fuzzy finder for Vim and Neovim.

"zorvex" is a provisional name, to be replaced throughout the tree.

## Start here: replace the name

This repository is made from `lambdalisue/vim-lese-template`. `zorvex` is a
coined placeholder for the extension's name; it occurs nowhere else, so one
search-and-replace renames everything. Pick a lowercase ASCII name (`git`,
`todo`, …) and, before anything else:

```sh
rg -il zorvex | xargs perl -pi -e 's/zorvex/<name>/g; s/Zorvex/<Name>/g; s/ZORVEX/<NAME>/g'
mv lua/lese-zorvex lua/lese-<name>
mv doc/lese-zorvex.txt doc/lese-<name>.txt
rm -r test/__snapshots__ && just deps && just snapshot  # their file names carry the test names
rg -i zorvex; rg --files | rg -i zorvex                 # both must print nothing
```

Then delete this section, the provisional-name line above, and the template
note and "Start an extension" section of `README.md`; run `just ci`, and
replace the sample source with the extension's own modules.

## How it is built

- **Test first.** Red → green → refactor. Write the failing test before the
  code that makes it pass.
- **Each layer holds one thing.** Put a fact in the one layer that owns it,
  and nowhere else.

  | Layer | Holds |
  | --- | --- |
  | `README.md` | what the extension does and the `custom.lua` line that enables it |
  | `doc/lese-zorvex.txt` | the user manual: the modules, their options and the pickers |
  | Tests | the details that pin the behaviour down: rules, boundaries, tables |
  | Code | how it is done |
  | Commits | why a change was made |
  | Comments | why it is not done another way |

- **Dependencies are current.** Before adding or bumping one, look up its
  latest release in the registry. Do not copy a version from memory or from
  another repository.

## Rules of an extension

lese runs the same Lua on Neovim and on Vim (+lua). You cannot open the
picker's UI, so you prove the extension works with tests and `lese-run`, on
both editors. The module format is specified in vim-lese's
`docs/spec/modules.md`; the types are in `lua/lese/types.lua` (both under
`.deps/vim-lese/` after `just deps`).

- Lua lives under `lua/lese-zorvex/`; never add files under `lua/lese/`,
  which is lese's own namespace.
- Write only the Lua 5.1 subset: no `goto`, `//`, bitwise operators, `utf8`,
  or `table.unpack` (use `require("lese.core.compat").unpack`). `stylua.toml`
  and selene make `just ci` fail on them.
- Reach the editor only through `ctx.host` (`ctx.host.fn.getcwd()`,
  `ctx.host.cmd(...)`); tests use `require("lese.host")`. Never touch
  `vim.api`, `vim.cmd`, `vim.fn`, `vim.uv`, `vim.loop`, `vim.command` or
  `vim.list`: they differ between Neovim and Vim, and selene rejects them.
- Define every module with `require("lese.define")` (`define.source`,
  `define.matcher`, …) and give it a `name` like
  `"lese-zorvex.source.word"`. It checks the contract at run time.
- Hand items over with `ctx:emit()`; every item has `id` (unique within the
  source), `value` (a string) and `detail` (a table). Annotate the `detail`
  with a LuaCATS class.
- Call `ctx:checkpoint()` in every loop over many items. Run commands with
  `ctx:spawn(cmd, { on_stdout = function(line) ... end })`, never with
  `system()`.
- Modules that take options are functions returning the module; users always
  call them, options or not.
- Describe everything users can reach, for lua-language-server: a `---`
  line on every public function, every class and every `---@field`
  (trailing `-- text` or a `---Text.` line above it). `require("lese-zorvex")`
  returns a table declared as the class `lese-zorvex`, with a described field
  per module, so hovering `require("lese-zorvex").source.word` in custom.lua
  says what it does.
- The extension adds no picker by itself and has no `plugin/` directory.
  `require("lese-zorvex").define_pickers(x)` declares its recommended pickers
  for users to call from their `custom.lua`.
- Check for what you need from lese by feature (`pcall(require, ...)`, a
  field's presence), never by version.

## Steps

1. Write the test first, in `test/<module>_test.lua`:

   ```lua
   local t = require("lese.testing")
   local word = require("lese-zorvex.source.word")

   t.describe("lese-zorvex.source.word", function()
     t.it("emits each word once", function()
       local items = t.collect(word(), { args = { "LICENSE" } })
       t.ok(#items > 0)
     end)

     t.it("renders the picker as expected", function()
       t.snapshot(t.picker({ source = word() }):type("fo"):screen())
     end)
   end)
   ```

   `t.collect`, `t.curate`, `t.match`, `t.sort`, `t.render`, `t.preview`,
   `t.invoke` and `t.refine` run one module. `t.picker(params)` drives a
   whole picker: `:type(text)`, `:press("<C-n>")`, `:screen()`, `:items()`,
   `:preview()`, `:invoke(name)`. `t.snapshot(text)` compares with a file
   under `test/__snapshots__/`.
2. Run it and see it fail: `just test` (or `just test <filter>`,
   `just test-on nvim`).
3. Implement until `just test` passes on every host.
4. Declare the picker in `define_pickers` and try it without the UI.
   `test/custom.lua` is the `custom.lua` `lese-run` loads:

   ```sh
   just run zorvex-word LICENSE --query "soft"     # both editors, diffed
   just run zorvex-word LICENSE --preview 1 --json
   ```

   Read the output: the first line is the picker, the query and the count of
   items shown over collected; `>` marks the cursor row, `*` a selected row,
   and brackets show what matched. `just run` fails when Neovim and Vim print
   different results. `.deps/vim-lese/bin/lese-run --help` lists every option.
5. Update snapshots only when the change is intended: `just snapshot`, then
   read the diff.

## Done means

- `just ci` is green: format, selene with lese's standard,
  lua-language-server with no warning, the tests on Neovim, Vim with PUC Lua
  and Vim with LuaJIT, and the sample picker printing the same on both
  editors.
- `just run <picker>` prints the same result on both editors for every
  picker `define_pickers` declares.
- `README.md` shows the `custom.lua` line that brings the pickers in.

## When something fails

Errors name the module, the item and the field, for example
`lese: source 'lese-zorvex.source.word' emitted item #3: field 'value' must be
a string, got nil`. Fix exactly what it names. A warning that a module "ran
… ms without ctx:checkpoint()" means a loop needs a checkpoint.

## Quality gate

Run `just ci` before reporting a change as done. CI runs the same recipe.

Run `just deps` once first: it clones lese into `.deps/vim-lese`. To build
against a lese checkout of your own instead, set `LESE_PATH` to it; every
recipe then uses that checkout and `just deps` does nothing.

## Layout

| Path | What lives there |
| --- | --- |
| `lua/lese-zorvex/` | `init.lua` with `define_pickers`, and the modules (`source/`, `matcher/`, …) |
| `test/` | `run.lua`, `*_test.lua`, `custom.lua` for `lese-run`, `__snapshots__/` |
| `doc/` | the Vim help file |
| `.deps/` | the lese checkout `just deps` clones; not tracked |

## Language

- README, docs and commit messages: English
- Code comments, log and error messages: English

## Commits

Scoped Commits:

```
<scope>: <description>

<why this change is needed>
```

- The scope names where the change is, from the table below. Several scopes
  are joined with `, `; a change across the whole tree uses `treewide`.
- The description starts in lower case, has no trailing period, and stays
  within 72 characters.
- The body explains why. The code shows how; the tests show what.
- A release commit is `release: vX.Y.Z`.
- A breaking change says so in the body and carries a `BREAKING CHANGE:`
  trailer.

| Scope | Covers |
| --- | --- |
| `lua` | `lua/lese-zorvex/` |
| `test` | `test/` |
| `doc` | `doc/` |
| `docs` | `README.md` |
| `ci` | `.github/` |
| `nix` | `flake.nix`, `flake.lock` |
| `deps` | dependency updates |

Add a row when a new area appears.
