# Neovim Keymaps Cheatsheet

**Leader key:** `Space`
**Source:** `plugins.lua`

---

## File Tree — `nvim-tree`

| Key | Mode | Action |
|---|---|---|
| `<leader>e` (`Space e`) | Normal | Toggle the file tree sidebar |

Once the tree is focused, these are nvim-tree's own *built-in* keys (not set in your config, but worth knowing):
`Enter`/`o` open, `a` create, `d` delete, `r` rename, `x`/`c`/`p` cut/copy/paste, `R` refresh.

---

## Fuzzy Finder — `Telescope`

| Key | Mode | Action |
|---|---|---|
| `<leader>ff` (`Space ff`) | Normal | Find files by name in the project |
| `<leader>fg` (`Space fg`) | Normal | Find files, but only ones tracked by git |
| `<leader>fr` (`Space fr`) | Normal | Live grep — search text *inside* files |
| `<leader>fb` (`Space fb`) | Normal | Search through currently open buffers |
| `<leader>fh` (`Space fh`) | Normal | Find files, including hidden/dotfiles |

Inside the results popup: arrows or `Ctrl+j`/`Ctrl+k` to move, `Enter` to open, `Ctrl+x`/`Ctrl+v`/`Ctrl+t` to open in split/vsplit/tab, `Esc` to cancel.

---

## LSP — `nvim-lspconfig`

These only activate **on a buffer where a language server has attached** (e.g. you have a `.c` or `.py` file open and the relevant LSP is installed via Mason).
If no LSP is attached, these keys do nothing.

| Key | Mode | Action |
|---|---|---|
| `K` | Normal | Show hover docs for symbol under cursor |
| `<leader>k` (`Space k`) | Normal | Show diagnostic (error/warning) in a floating window |
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gi` | Normal | Go to implementation |
| `go` | Normal | Go to type definition |
| `gr` | Normal | List references |
| `gs` | Normal | Show function signature help |
| `F2` | Normal | Rename symbol (renames everywhere it's used) |
| `F4` | Normal | Show code actions (quick fixes, refactors) |

---

## Completion — `nvim-cmp`

Active while typing in **Insert mode**, when the completion popup is relevant.

| Key | Action |
|---|---|
| `Ctrl+j` | Next suggestion |
| `Ctrl+k` | Previous suggestion |
| `Ctrl+f` | Scroll docs preview down |
| `Ctrl+b` | Scroll docs preview up |
| `Ctrl+Space` | Manually trigger completion menu |
| `Ctrl+e` | Abort / close completion menu |
| `Ctrl+y` | Disabled — does nothing (intentionally) |
| `Enter` | Confirm/insert selected suggestion |
| `Tab` | Next suggestion if menu is open, otherwise normal Tab |
| `Shift+Tab` | Previous suggestion if menu is open, otherwise normal Shift+Tab |

---

## Scrolling — `neoscroll`

These are **standard Vim keys** — neoscroll doesn't add new ones, it just makes the existing scroll/jump behavior smoothly animated instead of an instant snap.

| Key | Action |
|---|---|
| `Ctrl+u` | Scroll up half a page |
| `Ctrl+d` | Scroll down half a page |
| `Ctrl+b` | Scroll up a full page |
| `Ctrl+f` | Scroll down a full page |
| `Ctrl+y` | Scroll up one line |
| `Ctrl+e` | Scroll down one line |
| `zt` | Move current line to top of screen |
| `zz` | Move current line to center of screen |
| `zb` | Move current line to bottom of screen |

---

## Fully Automatic — no keys to remember

| Plugin | What it does |
|---|---|
| `ultimate-autopair.nvim` | Auto-closes brackets/quotes as you type — fires on `InsertEnter`, no manual key needed |
| `smear-cursor.nvim` | Animated cursor-trail visual effect — purely cosmetic, always on |

---

## Appendix: Editing keymaps in `plugins.lua`

### 1. The anatomy of a keymap

Most of your keymaps use this function:

```lua
vim.keymap.set(mode, lhs, rhs, opts)
```

- **`mode`** — which Vim mode the key works in. A string, or a table of strings.
- **`lhs`** ("left-hand side") — the key combo you press.
- **`rhs`** ("right-hand side") — what happens. Either a string command (`":NvimTreeToggle<cr>"`) or a Lua function (`b.find_files`).
- **`opts`** — optional table, e.g. `{ buffer = ... }` or `{ desc = "..." }`.

**Common mode strings:**

| String | Mode |
|---|---|
| `"n"` | Normal |
| `"i"` | Insert |
| `"v"` | Visual |
| `"x"` | Visual block |
| `"c"` | Command-line |
| `"t"` | Terminal |
| `{"n", "v"}` | Normal *and* Visual |

**Common key notation:**

| Notation | Means |
|---|---|
| `<leader>` | Your leader key (currently `Space`) |
| `<C-x>` | Ctrl + x |
| `<S-x>` | Shift + x |
| `<A-x>` / `<M-x>` | Alt + x |
| `<CR>` | Enter |
| `<Esc>` | Escape |
| `<Tab>` | Tab |
| `<F2>`, `<F4>`, etc. | Function keys |
| `<BS>` | Backspace |


### 2. Changing an existing keymap

Example — say you want nvim-tree's toggle to be `<leader>t` instead of `<leader>e`. Find this line:

```lua
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
```

and change the `lhs`:

```lua
vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<cr>")
```

That's it — save the file and restart Neovim (or `:source %` the file).

### 3. Adding a brand new keymap

Add a new line near the others in the relevant plugin's `config` function. Example — adding a Telescope keymap to search help docs:

```lua
vim.keymap.set("n", "<leader>fH", b.help_tags, {})
```

You can drop a new `vim.keymap.set(...)` line basically anywhere inside a plugin's `config = function() ... end` block — order among them doesn't matter.

### 4. Special case: LSP keymaps

These live **inside the `LspAttach` autocmd callback**, not as standalone lines:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local o = { buffer = event.buf }
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", o)
    -- edit/add lines HERE, inside this callback
  end,
})
```

The `{ buffer = event.buf }` makes these keymaps apply *only* to the buffer the LSP just attached to (not global) — keep that `o` argument when editing or adding lines here.

### 5. Special case: completion (`cmp`) keymaps

These don't use `vim.keymap.set` at all — they're a table passed straight into `cmp.setup()`:

```lua
mapping = {
  ["<C-k>"] = cmp.mapping.select_prev_item(),
  -- edit/add entries HERE
},
```

To change one, edit the key string on the left (e.g. `["<C-k>"]` → `["<C-p>"]`).
To change *what* it does, swap the `cmp.mapping.xxx()` call on the right for a different one from `cmp`'s API.

### 6. After any change

Save the file, then either:
- Restart Neovim, or
- Run `:source %` while the file is open (only reloads that file — fine for most keymap tweaks, but plugin installs/configs added for the first time still need `:Lazy sync`).
