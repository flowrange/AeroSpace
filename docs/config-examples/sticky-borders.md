# Window state borders

JankyBorders supports per-window colors through `apply-to=<window-id>` (confirmed
in version 1.8.4). See the [maintainer's explanation](https://github.com/FelixKratz/JankyBorders/issues/57).

Copy `sticky-borders.sh` to `~/.config/aerospace/`, make it executable, and add:

```toml
# Top-level configuration, before any [table].
on-focus-changed = ['exec-and-forget "$HOME/.config/aerospace/sticky-borders.sh"']

[mode.main.binding]
alt-cmd-ctrl-s = [
    'layout sticky floating',
    'exec-and-forget "$HOME/.config/aerospace/sticky-borders.sh"'
]
alt-cmd-ctrl-shift-space = [
    'layout floating tiling',
    'exec-and-forget "$HOME/.config/aerospace/sticky-borders.sh"'
]
```

Keep the existing command that starts Borders. Reload AeroSpace's configuration
and run the script once to color existing windows:

- Tiled windows (including accordion layouts): green.
- Floating windows, including maximized floating windows: blue with a soft halo.
- Sticky windows: orange, taking precedence over floating mode.

Each state uses a brighter color when focused and a darker shade of the same
color when unfocused. Edit the `tiling_*`, `floating_*` and `sticky_*` colors at
the top of the script to change the palette. The `normal_*` colors restore the
original green/gray defaults when resetting or clearing a marker.
Floating colors use `glow(0xAARRGGBB)` with reduced opacity, and a subtler shade
when unfocused. JankyBorders fixes the glow blur radius; it has no separate
intensity setting.

The script updates window borders without changing focus, workspaces, or
monitors. It runs only when invoked, with no background polling. If another
binding or external script changes floating, tiling or sticky state, invoke it
after the layout command too; otherwise its next focus event will update the indicator. After
restarting Borders or changing its global colors, invoke it to restore markers.

To remove the integration, first run `sticky-borders.sh reset`, then remove the
callbacks from the configuration. State stored in
`~/Library/Caches/aerospace-sticky-borders/` contains only window IDs.
