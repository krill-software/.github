# krill — Philosophy

Small native Linux apps that don't make you read a manual.

## Who these are for

Everyone — with one specific bar to clear: **don't be ugly Linux software**. Win/Mac users don't move to Linux because the apps look stuck in 1998 and act like they want you to read a manual. The krill brand lives in the *design*: calm, familiar, beautiful enough that the look itself isn't the barrier. What the apps actually *do* is fair game — krill builds tools that are useful, including ones a typical Win/Mac switcher wouldn't reach for first. The design is the constant; the domain isn't.

We optimize for the median user's *experience*. We do not optimize for power users with strong opinions about configuration.

## Krill principles

Four words that anchor every decision. Everything else in this
document is downstream of these.

- **Focus.** Each app does one thing. One file, one window — no
  tabs, no project trees, no mode pickers. The work in front of
  you is the work.
- **Beauty.** A locked palette, careful typography, chrome that
  sits still. Linux software has a reputation for looking stuck
  in 1998; krill exists in part to push back on that. The apps
  shouldn't be the part of your desktop you have to forgive.
- **Simplicity.** No settings panel, no plugin system, no
  power-user knobs. The decisions are made on your behalf; the
  surface is bounded. If a feature can't be explained in a
  sentence, it doesn't ship.
- **Ownership.** Your files live on your disk in their original
  format. No accounts, no cloud, no telemetry, no upload-on-
  launch. MIT licensed; build it yourself if you don't trust
  ours.

## What a krill app is

- **One job, done well.** Markdown. Image. Colors. Each app has a sentence-long purpose; if it can't be said in a sentence, it isn't a krill app.
- **One file at a time.** No tabs, no project trees, no vaults. One window per document.
- **Familiar.** File / Edit / View where Win/Mac users expect them. `Ctrl+S` saves. Drag-drop opens. No invented metaphors.
- **Discoverable for the task at hand.** Manipulation apps surface controls in the working view, next to what the user is working on. Quiet apps (writing, reading) stay quiet. Neither hides essential actions behind keyboard chords.
- **Beautiful, but not weird.** A locked light palette. Calm chrome. The *content* is the show.
- **Native Linux.** Tauri-built; real binaries; real file associations; XDG dirs. No Electron, no browser tabs, no web app pretending to be desktop.

## What a krill app is not

These are non-negotiable:

- **Not GIMP.** No 400-pane toolbox. No nested dialogs to find a basic operation. If a user has to ask "how do I export?", the app failed.
- **Not configurable.** No themes, no plugins, no skins. There is one palette and one shape, on purpose.
- **Not cloud.** No accounts, no sign-in, no sync. Files are files.
- **Not phoning home.** No telemetry, no crash reporters, no analytics.
- **Not cross-platform.** Linux x86_64 only. Windows and macOS are someone else's job.
- **Not a window manager.** One document equals one window. No multi-tab, no split panes.
- **Not dark.** A single light palette is part of the brand.

## How we ship

AppImage as the primary artifact. `.deb` as the secondary. GitHub Releases only. No Flatpak, no Snap, no PPAs. The release tag is the source of truth.

## When an app is "done"

When it does its one job well and stops. krill apps reach 1.0 and then mostly receive bug fixes. Feature creep is the failure mode — every "small addition" is one more thing the next user has to learn.
