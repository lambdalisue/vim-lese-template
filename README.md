# vim-lese-zorvex

An extension for [lese](https://github.com/lambdalisue/vim-lese), the Lua
fuzzy finder for Vim and Neovim.

> [!NOTE]
> This is **vim-lese-template**, the repository a lese extension starts
> from. It holds a small but working extension under the placeholder name
> `zorvex`: a source that lists the words of a buffer, its tests, a picker
> for `custom.lua`, a help file, and the Nix/just/CI setup that checks it on
> Neovim, Vim with PUC Lua and Vim with LuaJIT.

## Start an extension

1. Click **Use this template** on GitHub and name the repository
   `vim-lese-<name>`, then clone it.
2. Replace the placeholder `zorvex` with `<name>` everywhere, contents and
   paths alike. It is a coined word, so nothing else matches:

   ```sh
   rg -il zorvex | xargs perl -pi -e 's/zorvex/<name>/g; s/Zorvex/<Name>/g; s/ZORVEX/<NAME>/g'
   mv lua/lese-zorvex lua/lese-<name>
   mv doc/lese-zorvex.txt doc/lese-<name>.txt
   rm -r test/__snapshots__ && just deps && just snapshot
   rg -i zorvex; rg --files | rg -i zorvex   # both must print nothing
   ```

   Run it inside the development shell (below). The snapshots are written
   anew because their file names carry the test names.
3. Replace the sample source with your own modules, test first.
   [AGENTS.md](AGENTS.md) is the guide, for people and coding agents alike:
   the rules an extension follows, the test-first steps, and how to try a
   picker without opening the editor.

With [Claude Code](https://claude.com/claude-code), the `lese` plugin from
`lambdalisue/vim-lese` provides the `lese-extension` skill, which carries the
same guide.

## Development

Enter the development shell with `nix develop` (or copy `.envrc.sample` to
`.envrc` and `direnv allow`), then:

```sh
just deps   # clone lese into .deps/vim-lese (once; again to update it)
just ci     # everything CI runs: format check, lint, tests on every host,
            # and the sample picker on Neovim and Vim
```

To develop against a lese checkout of your own, set `LESE_PATH` to it; every
recipe then uses that checkout and `just deps` does nothing:

```sh
LESE_PATH=~/src/vim-lese just ci
```

Other recipes:

```sh
just fmt                    # format every source
just test [filter]          # the tests on every host, or those matching filter
just test-on nvim           # the tests on one host: nvim, vim or vim-luajit
just snapshot               # write the snapshots anew; read the diff after
just run zorvex-word LICENSE --query soft   # a picker, on both editors, diffed
```

## Usage

Install this plugin next to lese with any plugin manager. It adds nothing on
load; bring its pickers in from your `custom.lua` (`:LeseCustom` opens it):

```lua
return function(x)
  -- ... your own pickers ...
  require("lese-zorvex").define_pickers(x)
end
```

Then `:Lese zorvex-word` lists the words of the current buffer. See
`:help lese-zorvex` for the modules, to use them in pickers of your own.

## License

MIT. See [LICENSE](LICENSE).
