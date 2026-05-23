# Session Handoff

## Branches and PRs

- Current branch: `issue-12-activity-launcher`
- Launcher draft PR: https://github.com/jcearnal/magnetile/pull/13
- Launcher issue: https://github.com/jcearnal/magnetile/issues/12
- Base activity branch: `issue-10-activity-layouts`
- Activity draft PR: https://github.com/jcearnal/magnetile/pull/11
- Activity issue: https://github.com/jcearnal/magnetile/issues/10

## Known Good Activity Work

The activity layout/placement feature is working locally and is split into
revertable commits:

- `5b75a5e` - Add activity-scoped layout tracking.
- `7ec8398` - Restore placements per activity.

Behavior confirmed by user:

- `Track active layout per activity` works.
- Existing/shared windows can restore different runtime placements per KDE
  Activity.

One bug remains to investigate later:

- A window on the side monitor using the `Horizontal Split` layout can move to
  the top zone after switching activities.

## Launcher Work Current State

Current launcher branch commits:

- `5600373` - Add manual activity launcher profiles.
- `fec5be6` - Use basic DBusCall for KRunner launcher.
- `5536b4f` - Avoid nested DBus calls during profile launch.
- `ddf7513` - Use dedicated KRunner DBus call.
- `f7186d6` - Use KWin DBus API for KRunner query.
- `ef1dc31` - Launch profile apps from desktop entries.
- `d25cb84` - Avoid window scan during manual profile launch.
- `2128300` - Document launcher desktop entry ids.

Manual app launching from inside the KWin script is not working reliably. Tried
backends:

- `DBusCall` to `org.kde.krunner /App query`
- dedicated `DBusCall` object for KRunner
- `KWin.callDBus(...)` to KRunner
- `Qt.openUrlExternally("applications:...")`

Observed failure:

- Pressing the Magnetile launcher shortcut reaches the script, but KWin logs
  `RangeError: Maximum call stack size exceeded`.
- This persisted after KWin restarts.
- The stack overflow happened even after removing the missing-window scan and
  launching the first configured app directly.

Conclusion so far:

- Launching apps directly from inside the KWin script is probably the wrong
  boundary on this Plasma 6 setup.
- Magnetile should likely own activity profile config and placement detection,
  while actual app launch should be handled by KDE app shortcuts or a small
  external helper.

## Local Test Config

Current activity ids:

- `Activity A`: `57f07b40-68cb-4c02-b70f-3c76a40948aa`
- `Default`: `ee8f04ee-0bb1-486f-89fd-cf31a2b31fbb`

Current `activityProfilesJson` test config in `kwinrc`:

```json
{
  "activities": {
    "ee8f04ee-0bb1-486f-89fd-cf31a2b31fbb": {
      "launchMode": "manual",
      "apps": [
        {
          "name": "Ghostty",
          "desktopEntry": "com.mitchellh.ghostty",
          "class": "com.mitchellh.ghostty",
          "zone": 2
        }
      ]
    }
  }
}
```

Current shortcut test setup:

- `Ctrl+Alt+L` was removed from `Magnetile: Launch current activity profile`.
- `Ctrl+Alt+L` was bound to KDE's `Ghostty` application launch action:
  `['com.mitchellh.ghostty.desktop', '_launch', 'Ghostty', 'Ghostty']`.

This tests a better practical model:

- KDE/application shortcut launches the app.
- Magnetile watches `windowAdded` and snaps matching windows based on the
  activity profile.

## Useful Commands

Check current branch:

```sh
git status --short --branch
```

Check relevant KWin logs:

```sh
journalctl --user -u plasma-kwin_wayland --since "10 minutes ago" | rg "Magnetile|RangeError|ReferenceError|TypeError|Error|Ghostty|Alacritty"
```

Check activity ids:

```sh
qdbus6 --literal org.kde.ActivityManager /ActivityManager/Activities ListActivitiesWithInformation
```

Check launcher test bindings:

```sh
gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel --method org.kde.KGlobalAccel.shortcut "['kwin','Magnetile: Launch current activity profile','KWin','Magnetile: Launch current activity profile']"
gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel --method org.kde.KGlobalAccel.shortcut "['com.mitchellh.ghostty.desktop','_launch','Ghostty','Ghostty']"
```

Reload installed script:

```sh
tools/reload-clean.sh --normal
```

Restart KWin if callbacks are stale:

```sh
tools/reload-clean.sh --restart
```

## Recommended Next Steps

1. Do not keep trying more direct launch APIs from KWin until there is a clear
   reason. It has repeatedly caused stack overflow.
2. Test whether the current external-app-shortcut approach works:
   - close Ghostty,
   - press `Ctrl+Alt+L`,
   - verify Ghostty opens,
   - verify Magnetile snaps it to zone 2.
3. If external-app-shortcut launch plus Magnetile placement works, refocus the
   feature as:
   - activity profiles define expected apps and zones,
   - Magnetile places matching windows,
   - launching is delegated to KDE shortcuts or an optional helper.
4. If a true "launch current profile" command is still desired, implement a
   small external helper/service and have Magnetile call only that helper, or
   document a KDE shortcut-based setup.
5. After launcher direction is settled, investigate the side-monitor
   `Horizontal Split` activity-switch placement bug.
