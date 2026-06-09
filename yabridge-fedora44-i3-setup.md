# Yabridge on Fedora 44 i3 Spin — Setup Documentation

A practical guide based on a real installation session. Documents what worked,
what didn't, and known limitations as of June 2025.

---

## What is yabridge?

Yabridge lets you use Windows VST2, VST3, and CLAP plugins in Linux DAWs (like
Reaper, Ardour, Bitwig) by bridging them through Wine. The plugin appears to
your DAW as a native Linux plugin.

---

## System context

- **OS:** Fedora 44 i3 Spin (i3 window manager)
- **DAW:** Reaper
- **Plugin type tested:** VST3 (Neural DSP Archetype Mateus Asato)
- **Plugin installed via:** Windows `.exe` installer run through Wine

---

## Step 1 — Install Wine Staging from WineHQ

**When necessary:** Always. Yabridge requires a recent Wine Staging build.
Fedora's default Wine from `dnf install wine` works for installation but has a
known mouse click regression (see Known Issues).

### Add the WineHQ repository

On Fedora 44, the `--add-repo` flag doesn't exist. Use `addrepo` instead:

```bash
sudo rpm --import https://dl.winehq.org/wine-builds/winehq.key

sudo dnf config-manager addrepo \
  --from-repofile=https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo

sudo dnf install winehq-staging
```

### Verify

```bash
wine --version
# Should show: wine-X.X (Staging)
```

---

## Step 2 — Install yabridge (prebuilt binary method)

**When necessary:** Always. The `patrickl/yabridge` COPR does not support
Fedora 44 as of June 2025, so the prebuilt binary is the only reliable method.

```bash
cd /tmp
wget https://github.com/robbert-vdh/yabridge/releases/download/5.1.0/yabridge-5.1.0.tar.gz
mkdir -p ~/.local/share
tar -xzf /tmp/yabridge-5.1.0.tar.gz -C ~/.local/share
```

### Add yabridgectl to PATH

```bash
echo 'export PATH="$PATH:$HOME/.local/share/yabridge"' >> ~/.bashrc
source ~/.bashrc
```

### Verify

```bash
yabridgectl --version
# Should show: yabridgectl 5.1.0
```

---

## Step 3 — Install Windows plugins via Wine

**When necessary:** Only if you have Windows-only VST plugins. Skip if you only
use native Linux plugins.

Run the Windows `.exe` installer through Wine:

```bash
wine /path/to/PluginInstaller.exe
```

Plugins typically install to one of these Wine prefix paths:

- `~/.wine/drive_c/Program Files/Common Files/VST3/` (VST3)
- `~/.wine/drive_c/Program Files/VSTPlugins/` (VST2)
- Or a vendor-specific folder like `~/.wine/drive_c/Program Files/Neural DSP/`

You can also create a custom folder (e.g. `~/.vst`) and install there.

---

## Step 4 — Add plugin directories to yabridgectl

**When necessary:** Every time you add a new plugin directory.

```bash
yabridgectl add ~/.vst
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Neural DSP"
```

> **Important:** Always quote paths with spaces. Use `$HOME` or quotes — do not
> use backslash-escaped spaces, as they cause "directory not found" errors.

Check what directories are registered:

```bash
yabridgectl status
```

---

## Step 5 — Sync plugins

**When necessary:** After adding directories, after installing new plugins, and
after updating yabridge itself.

```bash
yabridgectl sync
```

This creates the Linux bridge `.so` files next to your Windows DLLs. Your DAW
will scan these and see the plugins as native Linux plugins.

---

## Step 6 — Configure Reaper to find the plugins

**When necessary:** First time only, or after adding new plugin directories.

In this setup, Reaper found the plugins automatically after `yabridgectl sync`
without any manual configuration. If it doesn't, go to:

**Options → Preferences → Plug-ins → VST** and add the plugin directories
manually.

---

## Step 7 — Install DXVK (fixes UI rendering issues)

**When necessary:** If the plugin GUI is black, not updating when moved, or
visually glitching. In this setup, DXVK was needed to fix the UI redraw bug.

```bash
sudo dnf install wine-dxvk
wineboot --init
yabridgectl sync
```

> The Fedora 44 `wine-dxvk` package integrates automatically — no setup script
> is needed. The DLLs are placed directly into the Wine system directory.

---

## Step 8 — i3 window manager: make plugin windows float

**When necessary:** On i3 (and other tiling WMs). Without this, plugin windows
get tiled, which interferes with input handling.

Add to `~/.config/i3/config`:

```
for_window [class="wine"] floating enable
for_window [class="Wine"] floating enable
```

Reload i3:

```bash
$mod+Shift+r
```

---

## Step 9 — yabridge.toml configuration

**When necessary:** If mouse clicks don't register inside the plugin GUI.

Create `~/.config/yabridge/yabridge.toml`:

```toml
[defaults]
editor-force-dnd = true
editor-xembed = false
hide-daw = false

[compatibility]
editor-coordinate-hack = true
input-event-filter = false
```

After editing:

```bash
yabridgectl sync
```

> **Note on syntax:** All keys must use hyphens (`editor-force-dnd`), not
> underscores (`editor_force_dnd`). Mixed syntax is silently ignored.

---

## Known issues and limitations (as of June 2025)

### Mouse clicks only work when the plugin window is at the top-left corner

**Root cause:** A regression introduced in Wine 9.22 that breaks mouse
coordinate mapping for embedded plugin windows. All Wine versions from 9.22
onward (including 10.x and 11.x) are affected.

**Proper fix:** Wine built with the "vulkan childwindow patch" (wine-tkg).
The `patrickl/wine-tkg` COPR provides this for Fedora, but **only up to Fedora
43**. Fedora 44 is not supported as of June 2025.

**Workaround in use:** Keep the plugin window positioned at the top-left corner
of the screen. Mouse clicks work correctly there due to coordinate offset
behavior.

**Attempted fix — Kron4ek standalone wine-tkg 9.21:**

```bash
cd /opt
sudo wget https://github.com/Kron4ek/Wine-Builds/releases/download/9.21/wine-9.21-staging-tkg-amd64.tar.xz
sudo tar -xJf wine-9.21-staging-tkg-amd64.tar.xz
sudo mv wine-9.21-staging-tkg-amd64 wine-tkg-9.21
yabridgectl set --wine-home /opt/wine-tkg-9.21/bin
yabridgectl sync
```

This downloaded and extracted correctly, and the binary works (`wine-9.21 TkG
Staging Esync Fsync`), but yabridge continued using system Wine 11.0 because
`~/.config/yabridgectl/config.toml` shows `wine_version = 'wine-11.0
(Staging)'`. The `set --wine-home` command did not persist. This needs further
investigation.

**Track the upstream bug:** https://github.com/robbert-vdh/yabridge/issues/382

**Track patrickl's COPR for Fedora 44 support:**
https://copr.fedorainfracloud.org/coprs/patrickl/wine-tkg/

---

### Child/dropdown windows open behind the plugin window

**Root cause:** Same Wine childwindow regression as above.

**Workaround:** When a dropdown or child window opens behind the plugin, move
the front window aside, interact with the child window, then move the front
window back to top-left to continue using it.

---

### patrickl/yabridge COPR not available for Fedora 44

The COPR only has builds up to Fedora 43. Using the prebuilt binary from GitHub
releases (Step 2) is the correct workaround.

---

### patrickl/wine-tkg COPR not available for Fedora 44

Same situation — only Fedora 42 and 43 are supported. Manually adding the fc43
repo and forcing the install fails because the sub-packages (`wine-core`,
`wine-cms`, etc.) are not built for fc43 in that COPR, causing unresolvable
dependencies.

---

### WineHQ repo syntax difference on Fedora 44

The standard `dnf config-manager --add-repo` flag does not exist on Fedora 44.
Use `addrepo --from-repofile=` instead (see Step 1).

---

## Summary of what's installed and working

| Component | Version | Source |
|---|---|---|
| Wine | 11.0 Staging | WineHQ repo |
| wine-dxvk | 2.7.1 | Fedora default repo |
| yabridge | 5.1.0 | GitHub prebuilt binary |
| yabridgectl | 5.1.0 | GitHub prebuilt binary |
| wine-tkg 9.21 | extracted to `/opt` | Kron4ek builds (not active) |

## What works

- VST3 plugins load and produce audio in Reaper
- Plugin GUI opens and renders correctly (with DXVK)
- Mouse clicks work when plugin window is at top-left corner
- Plugin discovered automatically by Reaper after `yabridgectl sync`

## What needs improvement

- Mouse clicks only work at top-left (Wine 9.22+ regression)
- Child/dropdown windows open behind the plugin
- wine-tkg 9.21 is downloaded but not being used by yabridge
- Both `patrickl` COPRs need Fedora 44 builds
