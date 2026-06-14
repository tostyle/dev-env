# Neovim Config

## Structure
```
~/.config/nvim/
├── init.lua                  # Entry point, bootstraps lazy.nvim
├── lua/core/
│   ├── options.lua           # General editor settings
│   └── keymaps.lua           # Global keybindings
└── lua/plugins/
    ├── init.lua              # Plugin spec imports
    ├── completion.lua        # blink.cmp autocomplete
    ├── lsp.lua               # LSP (mason, lspconfig, roslyn)
    ├── editor.lua            # Treesitter, yazi, tokyonight, which-key
    └── formatting.lua        # conform.nvim + nvim-lint
```

## Plugins

| Plugin | Purpose |
|---|---|
| `lazy.nvim` | Package manager |
| `tokyonight.nvim` | Colorscheme (night variant) |
| `blink.cmp` | Autocomplete (LSP, path, snippets, buffer) |
| `mason.nvim` | LSP/formatter/linter installer |
| `mason-lspconfig.nvim` | Bridge mason ↔ lspconfig |
| `nvim-lspconfig` | LSP client configuration |
| `roslyn.nvim` | Roslyn LSP for C#/.NET |
| `nvim-treesitter` | Syntax highlighting & indentation |
| `nvim-treesitter-textobjects` | Text objects based on treesitter |
| `conform.nvim` | Format on save |
| `nvim-lint` | Linting |
| `yazi.nvim` | File manager (yazi integration) |
| `which-key.nvim` | Keybinding cheatsheet popup |

## LSP

| Language | Server | Install |
|---|---|---|
| TypeScript/JavaScript | `ts_ls` | Auto via mason |
| C#/.NET | Roslyn | Auto via roslyn.nvim |

## Formatting (on save)

| Filetype | Formatter |
|---|---|
| `.ts`, `.tsx`, `.js`, `.jsx`, `.json`, `.jsonc` | biome |
| `.cs` | dotnet-format |
| `.lua` | stylua |

## Linting

| Filetype | Linter |
|---|---|
| `.ts`, `.tsx`, `.js`, `.jsx` | biomejs |

## Keybindings

### Navigation
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits |
| `<C-f>` / `<C-b>` | Page down / up |
| `<C-d>` / `<C-u>` | Half-page down / up |
| `<C-o>` / `<C-i>` | Jump back / forward in jumplist |
| `gf` | Go to file under cursor |
| `gg` / `G` | Start / end of file |
| `*` / `#` | Search word under cursor forward / backward |
| `%` | Jump to matching bracket |

### LSP / IDE
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `[d` / `]d` | Previous / next diagnostic |

### General
| Key | Action |
|---|---|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>e` | Open yazi file manager |
| `<leader>` (wait) | Show which-key cheatsheet |

## Prerequisites

Install these on your system for full functionality:

```bash
# Yazi file manager
brew install yazi

# Biome formatter/linter
brew install biome
# or: npm i -g @biomejs/biome

# .NET formatter
dotnet tool install -g dotnet-format
```
