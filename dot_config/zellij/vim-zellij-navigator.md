# vim-zellij-navigator

Fork of [hiasr/vim-zellij-navigator](https://github.com/hiasr/vim-zellij-navigator),
rebuilt for zellij **0.44.3** with the synchronous API.

## What it does

WASM plugin for zellij that intercepts `Ctrl+h/j/k/l` (and arrow keys) in locked mode:

- If **vim** or **nvim** is running in the current pane — the key is forwarded to the terminal
- If vim/nvim is **not running** — zellij pane navigation is performed (`move-focus-or-tab`)

This allows using the same keys for navigation both inside nvim (via smart-splits)
and between zellij panes.

**Critical:** the `zellij-tile` version in `Cargo.toml` must match your zellij version.
A mismatch will cause zellij to reject the plugin with a `PLUGIN_MISMATCH` error.

To verify:

```bash
zellij --version        # e.g. 0.44.3
cargo search zellij-tile | grep zellij-tile  # same version must be available
```

## Building

### Dependencies

```bash
# Arch Linux
sudo pacman -S rust rust-wasm
```

### Steps

```bash
cd ~/projects/vim-zellij-navigator # or another path to fork

# Make sure zellij-tile version matches zellij --version
# In Cargo.toml: zellij-tile = "<zellij version>"

cargo build --release --target wasm32-wasip1

# Copy the output
cp target/wasm32-wasip1/release/vim-zellij-navigator.wasm \
   ~/.config/zellij/plugins/vim-zellij-navigator-0.5.1.wasm
```

### Updating when zellij version changes

1. `zellij --version` — check the new version
2. In `Cargo.toml`, update `zellij-tile = "<new version>"`
3. `cargo build --release --target wasm32-wasip1`
4. Copy the WASM to `~/.config/zellij/plugins/`
5. Update the path in `config.kdl`

## Changelog

### 0.5.0 — fix double-move in multiplayer sessions

**Problem:** when a second client attaches to a zellij session and then detaches,
zellij does not kill the plugin instance created for that client ([zellij-org/zellij#4064](https://github.com/zellij-org/zellij/issues/4064)).
The orphaned instance keeps receiving `MessagePlugin` pipe messages alongside the
active instance, causing `move_focus_or_tab` to fire twice per keypress — focus
skips over a pane or behaves erratically.

**Fix:** subscribe to `EventType::ListClients` and call `list_clients()` on load.
In the `Event::ListClients` handler, check `is_current_client` across all clients:
if no client claims this plugin instance, set `has_active_client = false`.
The `pipe()` handler skips command execution when the flag is false.

Inspired by [hiasr/vim-zellij-navigator#35](https://github.com/hiasr/vim-zellij-navigator/pull/35).

### Changes from original 0.3.0

- **Synchronous API:** replaced async `list_clients()` + `Event::ListClients` + command queue
  with synchronous `get_focused_pane_info()` + `get_pane_running_command()`
- Removed `current_term_command` and `command_queue` from state — no longer needed
- `edition` updated from `2018` to `2021`
- `zellij-tile` updated from `0.42.2` to `0.44.3`

## Architecture

```
Ctrl+h/j/k/l (locked mode)
    │
    ▼
zellij config.kdl → MessagePlugin → vim-zellij-navigator.wasm
    │
    ├─ get_focused_pane_info()     → current PaneId
    ├─ get_pane_running_command()  → command in the pane
    │
    ├─ vim/nvim?  → write_chars()  (Ctrl+H forwarded to terminal)
    │                              → nvim catches it, smart-splits moves focus
    │
    └─ not vim?   → move_focus_or_tab()  (zellij switches pane)
```

## Configuration

Parameters are passed via payload in `config.kdl`:

- `move_mod` — modifier for navigation (default: `ctrl`)
- `resize_mod` — modifier for resizing (default: `alt`)
- `use_arrow_keys` — use arrow keys instead of hjkl (`true`/`false`)
