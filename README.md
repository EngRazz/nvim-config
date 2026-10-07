# Neovim Config

My personal Neovim configuration for C/C++, Python, ROS 2, Jupyter notebooks, and general development.

The configuration is managed with [`lazy.nvim`](https://github.com/folke/lazy.nvim) and is designed around:

- Native Neovim LSP
- Autocompletion with `nvim-cmp`
- Treesitter
- Telescope
- nvim-tree
- tmux integration
- Jupyter notebooks
- Markdown and LaTeX rendering
- Monokai Pro
- System clipboard integration

The configuration is mainly used on:

- macOS
- Ubuntu ARM64
- Neovim 0.12+

---

# Installation

## 1. Install system dependencies

### Ubuntu

```bash
sudo apt update

sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    tar \
    build-essential \
    ripgrep \
    fd-find \
    xclip \
    python3 \
    python3-pip \
    python3-venv \
    clangd \
    tmux
```

Ubuntu installs `fd` as `fdfind`.

Create an `fd` command:

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

Make sure `~/.local/bin` is in your `PATH`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
rg --version
fd --version
clangd --version
git --version
```

---

## 2. Install Neovim

This configuration expects a recent Neovim version.

Check your current version:

```bash
nvim --version
```

The configuration is currently tested with:

```text
Neovim 0.12+
```

### Ubuntu ARM64

The Ubuntu 24.04 repository may provide an older Neovim version, so using the official Neovim release is recommended.

Remove the old Ubuntu package if necessary:

```bash
sudo apt remove neovim
```

Download the Linux ARM64 Neovim release from:

https://github.com/neovim/neovim/releases

Extract it and install it under `/opt`.

For example:

```bash
cd ~/Downloads

tar xzf nvim-linux-arm64.tar.gz

sudo rm -rf /opt/nvim-linux-arm64
sudo mv nvim-linux-arm64 /opt/

sudo ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
```

Verify:

```bash
which nvim
nvim --version
```

You should be using the version under `/opt`, not `/usr/bin/nvim`.

### macOS

With Homebrew:

```bash
brew install neovim
```

---

# 3. Install Rust

Rust is needed for:

- `tree-sitter-cli`
- building `jupynvim-core` on platforms without a prebuilt binary

Install Rust using `rustup`:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Select the default installation.

Then:

```bash
source "$HOME/.cargo/env"
```

Verify:

```bash
rustc --version
cargo --version
which cargo
```

The binaries should normally be under:

```text
~/.cargo/bin/
```

---

# 4. Install the Tree-sitter CLI

The current `nvim-treesitter` configuration requires the Tree-sitter CLI.

Install it with:

```bash
cargo install tree-sitter-cli
```

Verify:

```bash
tree-sitter --version
```

If the command cannot be found:

```bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

# 5. Clone the configuration

If you already have a Neovim configuration, back it up first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

Clone this repository:

```bash
git clone https://github.com/EngRazz/nvim-config.git ~/.config/nvim
```

Then start Neovim:

```bash
nvim
```

`lazy.nvim` will automatically bootstrap itself and install the configured plugins.

---

# 6. Install/update plugins

Inside Neovim:

```vim
:Lazy sync
```

You can open the Lazy UI with:

```vim
:Lazy
```

Update all plugins with:

```vim
:Lazy update
```

---

# 7. Treesitter setup

The configuration installs Treesitter parsers for languages including:

```text
C
C++
Python
HTML
CSS
JavaScript
Lua
Vim
Vimdoc
Markdown
LaTeX
```

After installing the configuration, run:

```vim
:TSUpdate
```

Check Treesitter health with:

```vim
:checkhealth nvim-treesitter
```

If you get:

```text
tree-sitter-cli not found
```

verify:

```bash
tree-sitter --version
```

---

# 8. LSP setup

The configuration uses:

- Neovim's native LSP client
- `nvim-lspconfig`
- Mason
- `mason-lspconfig`
- `nvim-cmp`
- `cmp-nvim-lsp`

Open Mason with:

```vim
:Mason
```

Use Mason to install language servers supported on your platform.

---

## C/C++

On Linux ARM64, Mason may not provide a compatible `clangd` binary.

Install it directly through Ubuntu:

```bash
sudo apt install clangd
```

Verify:

```bash
which clangd
clangd --version
```

You should normally get:

```text
/usr/bin/clangd
```

To check that `clangd` is attached to the current Neovim buffer:

```vim
:checkhealth vim.lsp
```

or:

```vim
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
```

You should see a `clangd` client when editing a `.cpp` or `.h` file.

---

# 9. CMake projects and clangd

For good C/C++ completion, clangd should know the exact compiler flags used by CMake.

Configure your CMake project with:

```bash
cmake -S . -B build \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

This creates:

```text
build/compile_commands.json
```

Create a link in the project root:

```bash
ln -sf build/compile_commands.json compile_commands.json
```

Your project will then look roughly like:

```text
MyProject/
├── CMakeLists.txt
├── compile_commands.json -> build/compile_commands.json
├── build/
├── include/
└── src/
```

This allows clangd to correctly understand:

- include directories
- C++ version
- compiler definitions
- external libraries
- project headers

If completion behaves incorrectly, rebuild the compilation database:

```bash
rm -rf build

cmake -S . -B build \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

cmake --build build
```

Then restart Neovim.

---

# 10. Python

Python itself is required by several Neovim tools.

Verify:

```bash
python3 --version
```

To install a Python LSP, open:

```vim
:Mason
```

and install your preferred Python language server.

For example:

```text
pyright
```

or another server supported by your setup.

---

# 11. Jupyter / Jupynvim

The configuration uses:

```text
sheng-tse/jupynvim
```

On Linux ARM64 there may be no prebuilt `jupynvim-core`, so the plugin must build it from source with Cargo.

After Rust is installed, open Neovim and run:

```vim
:JupynvimInstall
```

Check its status with:

```vim
:checkhealth jupynvim
```

A successful configuration should report that `jupynvim-core` exists.

---

## Install Jupyter

A clean way is to use a Python virtual environment:

```bash
python3 -m venv ~/.venvs/jupyter
```

Activate it:

```bash
source ~/.venvs/jupyter/bin/activate
```

Install Jupyter and IPython kernel support:

```bash
pip install jupyter ipykernel
```

Verify:

```bash
jupyter --version
```

You can create additional Python environments and register them as Jupyter kernels as needed.

---

# 12. Markdown and LaTeX rendering

The configuration includes:

- `render-markdown.nvim`
- `nabla.nvim`

For Markdown rendering, simply open a `.md` file.

For LaTeX-to-text conversion, install `pylatexenc`:

```bash
python3 -m pip install --user pylatexenc --break-system-packages
```

Make sure:

```text
~/.local/bin
```

is in your `PATH`.

Verify:

```bash
which latex2text
```

---

## Nabla keybindings

Inside a Markdown file:

```text
<leader>mp
```

opens a LaTeX equation popup.

```text
<leader>mt
```

toggles virtual LaTeX rendering.

Since the leader key is Space, these correspond to:

```text
Space m p
Space m t
```

---

# 13. Clipboard support

The configuration uses:

```lua
vim.opt.clipboard = "unnamedplus"
```

On Ubuntu:

```bash
sudo apt install xclip
```

Check clipboard support inside Neovim:

```vim
:checkhealth vim.provider
```

You should see:

```text
Clipboard tool found: xclip
```

You can then use the normal Vim clipboard registers and system copy/paste.

---

# 14. Nerd Font

The configuration is designed to work well with a Nerd Font, especially:

```text
JetBrainsMono Nerd Font
```

Install the font on the machine running your terminal and select it in your terminal emulator.

This is needed for the icons used by plugins such as:

- nvim-tree
- Telescope
- nvim-web-devicons

---

# 15. tmux integration

Install tmux:

```bash
sudo apt install tmux
```

The Neovim configuration uses:

```text
christoomey/vim-tmux-navigator
```

This allows the same keys to move between Neovim splits and tmux panes:

```text
Ctrl+h   left
Ctrl+j   down
Ctrl+k   up
Ctrl+l   right
```

For full tmux integration, also install the matching plugin in your tmux configuration:

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
```

If using TPM, reload your tmux configuration and install the plugin.

---

# Usage

## Leader key

The leader key is:

```text
Space
```

---

## File tree

Toggle nvim-tree:

```text
Space e
```

---

## Telescope

Find files:

```text
Space f f
```

Find Git files:

```text
Space f g
```

Search text through the project:

```text
Space f r
```

List open buffers:

```text
Space f b
```

Find hidden files:

```text
Space f h
```

---

# LSP keybindings

When an LSP server is attached:

| Key | Action |
|---|---|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `go` | Go to type definition |
| `gr` | Find references |
| `gs` | Signature help |
| `<F2>` | Rename symbol |
| `<F4>` | Code action |
| `<leader>k` | Show diagnostic message |

---

# Autocompletion

Completion is provided by:

```text
nvim-cmp
```

Useful keys:

| Key | Action |
|---|---|
| `Ctrl+Space` | Open completion menu |
| `Ctrl+j` | Next item |
| `Ctrl+k` | Previous item |
| `Tab` | Next item when menu is visible |
| `Shift+Tab` | Previous item |
| `Enter` | Confirm selected completion |
| `Ctrl+e` | Close completion menu |

If the completion menu is not visible, `Tab` behaves normally.

---

# Buffer navigation

Next buffer:

```text
Shift+l
```

Previous buffer:

```text
Shift+h
```

---

# Scrolling

Scroll down and keep the cursor centered:

```text
Ctrl+d
```

Scroll up and keep the cursor centered:

```text
Ctrl+u
```

Smooth scrolling is provided by:

```text
neoscroll.nvim
```

---

# Visual mode

Move selected text down:

```text
Alt+j
```

Move selected text up:

```text
Alt+k
```

The configuration also preserves the copied text when pasting over a visual selection.

---

# File tree

Toggle the tree:

```text
Space e
```

---

# Health checks

If something is not working, start with:

```vim
:checkhealth
```

Specific checks:

```vim
:checkhealth vim.lsp
```

```vim
:checkhealth nvim-treesitter
```

```vim
:checkhealth jupynvim
```

```vim
:checkhealth vim.provider
```

---

# Troubleshooting

## C++ completion does not work

Check clangd:

```bash
clangd --version
```

Then open a C++ file and run:

```vim
:checkhealth vim.lsp
```

Check attached clients:

```vim
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
```

For CMake projects, make sure this exists:

```text
compile_commands.json
```

Generate it with:

```bash
cmake -S . -B build \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

ln -sf build/compile_commands.json compile_commands.json
```

---

## Treesitter says `tree-sitter` is missing

Check:

```bash
tree-sitter --version
```

If it is missing:

```bash
cargo install tree-sitter-cli
```

Then:

```vim
:TSUpdate
```

---

## Jupynvim says there is no prebuilt binary

This is expected on some architectures, including Linux ARM64.

Install Rust and then run:

```vim
:JupynvimInstall
```

The plugin will build `jupynvim-core` locally using Cargo.

---

## Clipboard does not work

Install:

```bash
sudo apt install xclip
```

Then:

```vim
:checkhealth vim.provider
```

---

## Icons do not render correctly

Install and select a Nerd Font in your terminal.

Recommended:

```text
JetBrainsMono Nerd Font
```

---

# Updating the configuration

Pull the latest config:

```bash
cd ~/.config/nvim
git pull
```

Update plugins:

```vim
:Lazy sync
```

Update Treesitter:

```vim
:TSUpdate
```

Then:

```vim
:checkhealth
```

---

# Repository structure

```text
~/.config/nvim/
├── init.lua
├── lazy-lock.json
└── lua/
    └── conf/
        ├── init.lua
        ├── keymap.lua
        ├── lazy_init.lua
        ├── options.lua
        └── plugins.lua
```

### `init.lua`

Entry point of the configuration.

### `options.lua`

Contains Neovim options such as:

- indentation
- line numbers
- clipboard
- search
- scrolling
- invisible characters
- file-type-specific indentation

### `keymap.lua`

Contains custom keyboard mappings.

### `lazy_init.lua`

Bootstraps and configures `lazy.nvim`.

### `plugins.lua`

Contains all plugin declarations and plugin-specific configuration.

---

# Main plugins

## Package management

- `folke/lazy.nvim`

## Theme

- `loctvl842/monokai-pro.nvim`

## File navigation

- `nvim-tree/nvim-tree.lua`
- `nvim-tree/nvim-web-devicons`

## Fuzzy finding

- `nvim-telescope/telescope.nvim`
- `nvim-lua/plenary.nvim`

## Syntax parsing

- `nvim-treesitter/nvim-treesitter`

## LSP

- `neovim/nvim-lspconfig`
- `mason.nvim`
- `mason-lspconfig.nvim`

## Completion

- `hrsh7th/nvim-cmp`
- `hrsh7th/cmp-nvim-lsp`

## Editing

- `altermo/ultimate-autopair.nvim`

## UI

- `sphamba/smear-cursor.nvim`
- `karb94/neoscroll.nvim`

## Markdown / LaTeX

- `MeanderingProgrammer/render-markdown.nvim`
- `jbyuki/nabla.nvim`

## Jupyter

- `sheng-tse/jupynvim`

## tmux

- `christoomey/vim-tmux-navigator`

---

# Quick installation summary

On a fresh Ubuntu system:

```bash
sudo apt update

sudo apt install -y \
    git curl wget unzip tar \
    build-essential \
    ripgrep fd-find xclip \
    python3 python3-pip python3-venv \
    clangd tmux
```

Install Rust:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

Install Tree-sitter:

```bash
cargo install tree-sitter-cli
```

Clone the config:

```bash
git clone https://github.com/EngRazz/nvim-config.git ~/.config/nvim
```

Launch:

```bash
nvim
```

Then run:

```vim
:Lazy sync
:TSUpdate
:JupynvimInstall
:checkhealth
```

The environment should now be ready for development.

---

# License

Feel free to use, modify, and adapt this configuration for your own setup.
