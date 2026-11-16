# AeroSpace — sticky windows and kMeet PiP

A personal fork of [AeroSpace](https://github.com/nikitabobko/AeroSpace), the
i3-like window manager for macOS created by **Nikita Bobko** and its contributors.
See the [upstream guide](https://nikitabobko.github.io/AeroSpace/guide) for general
features and configuration.

## What changed

- **kMeet picture-in-picture fix.** Leaving a meeting's workspace no longer
  bounces back when its PiP appears. AeroSpace leaves kMeet's elevated PiP window
  unmanaged, while continuing to manage the main meeting window. kMeet controls
  when the PiP appears and disappears; kMeet itself is unchanged.
- **Sticky floating windows.** Keep a window visible across workspaces on its
  current monitor. Focusing it does not return to its original workspace. A tiled
  window becomes floating when made sticky; its owning workspace is preserved.
- **Optional window state indicator with [JankyBorders](https://github.com/FelixKratz/JankyBorders).**
  Tiled windows have green borders, floating windows blue with a soft halo, and
  sticky windows orange, with darker shades when unfocused. Maximized floating
  windows keep their blue halo. See the [setup instructions](docs/config-examples/sticky-borders.md).

## Usage

Add a shortcut to your existing configuration:

```toml
[mode.main.binding]
alt-cmd-ctrl-s = 'layout sticky floating'
```

This toggles between sticky and ordinary floating mode. `layout floating` or
`layout tiling` clears sticky mode. To use the border indicator, follow the
integration instructions above instead; they also update the border immediately.

Scripts can query the state:

```sh
aerospace list-windows --focused --format '%{window-id}|%{window-is-sticky}'
```

Sticky windows stay on their monitor rather than following focus between
monitors. Sticky state resets when AeroSpace restarts; native minimization,
hiding and fullscreen behavior still take precedence.

## Build

This fork is based on upstream commit
[`1ec4234`](https://github.com/nikitabobko/AeroSpace/commit/1ec4234).
With the required macOS and Swift build tools installed
([development guide](dev-docs/development.md)):

```sh
git clone https://github.com/flowrange/AeroSpace.git
cd AeroSpace
./build-kmeet-pip.sh
```

The script builds an ad-hoc signed app at `.local/dist/AeroSpace-kMeet.app` and a
matching CLI at `.local/dist/aerospace`. Quit the existing AeroSpace before
replacing its app and CLI, and grant Accessibility access to the new build.
This permission may need to be renewed after replacing the app.

No prebuilt release is published for this fork. The upstream Homebrew cask
installs upstream AeroSpace; use a build from this repository for these changes.

## Credits

- [Nikita Bobko](https://github.com/nikitabobko) and the
  [upstream contributors](https://github.com/nikitabobko/AeroSpace/graphs/contributors):
  original application.
- [noomz's sticky implementation](https://github.com/noomz/AeroSpace/commit/0e94059bcd5cd390a33b4e3ca8c9dfc3440965e7)
  and [LynxBay's sticky-window PR #2114](https://github.com/nikitabobko/AeroSpace/pull/2114):
  foundations adapted for this fork.
- [FelixKratz](https://github.com/FelixKratz): JankyBorders and its per-window
  border configuration.
- [flowrange](https://github.com/flowrange): fork and validation on macOS.
- [Codex](https://github.com/openai/codex), OpenAI's coding assistant: diagnosis,
  implementation, integration and tests.

[MIT License](LICENSE.txt). Original copyright notices are retained.
