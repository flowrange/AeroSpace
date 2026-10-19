# Sticky window borders

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
and run the script once to mark windows that are already sticky. Sticky windows
use bright orange when focused and darker orange when unfocused. Other windows
keep green/gray borders. Edit the four colors at the top of the script to change
the palette.

The script updates every sticky window without changing focus, workspaces, or
monitors. It runs only when invoked, with no background polling. If another
binding or external script changes sticky state, invoke it after the layout
command too; otherwise its next focus event will update the indicator. After
restarting Borders or changing its global colors, invoke it to restore markers.

To remove the integration, first run `sticky-borders.sh reset`, then remove the
callbacks from the configuration. State stored in
`~/Library/Caches/aerospace-sticky-borders/` contains only window IDs.
