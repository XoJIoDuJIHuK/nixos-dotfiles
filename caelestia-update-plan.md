# Caelestia-Shell Update Plan

## Current Setup

- **Service**: `caelestia.service` runs `/nix/store/l5c0j2742k34ra3xnrckipfcya2grxzb-caelestia-shell-1.0.0/bin/caelestia-shell`
- **Config path**: `/nix/store/.../share/caelestia-shell/shell.qml`
- **Cloned repo**: `~/caelestia-shell`
- **Service status**: Running with PID 1699

## Key Files to Modify

- `shell.qml` - Main entry point defining all widgets (Background, Drawers, AreaPicker, Lock, Shortcuts, BatteryMonitor, IdleMonitors)
- `modules/` - Contains all widget modules:
  - `background/` - Desktop background and visualizer
  - `bar/` - Status bar with workspaces, clock, tray
  - `dashboard/` - Main dashboard widgets
  - `launcher/` - Application/launcher
  - `drawers/` - Drawer widgets
  - `controlcenter/` - Control center
  - `notifications/` - Notification system
  - `sidebar/` - Sidebar widgets
  - `lock/` - Lock screen
  - `session/` - Session management
  - `utilities/` - Utility widgets
- `config/` - QML configuration files for each module
- `components/` - Reusable UI components

## Options to Use Modified Code

### Option 1: Development Mode (Recommended for Testing)

The repo has direnv setup for local development:

```bash
cd ~/caelestia-shell
direnv allow
# This will:
# 1. Build the C++ plugin to build/lib
# 2. Set CAELESTIA_LIB_DIR to build/lib
# 3. Add build/qml to QML2_IMPORT_PATH

# Then run quickshell pointing to your local repo:
/nix/store/hpaasjlqrjivw7w4az6071z9rk7wbvk4-quickshell-wrapped-0.2.1/bin/qs -p ~/caelestia-shell
```

**Update systemd service**:

```bash
systemctl --user edit caelestia.service
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/nix/store/hpaasjlqrjivw7w4az6071z9rk7wbvk4-quickshell-wrapped-0.2.1/bin/qs -p /home/aleh/caelestia-shell
```

### Option 2: Manual Installation via CMake

Build and install your modified version:

```bash
cd ~/caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build

# Or install to a custom location (e.g., ~/.local):
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=~/.local \
  -DINSTALL_QSCONFDIR=~/.local/share/caelestia-shell
cmake --build build
cmake --install build
```

Then update the systemd service `ExecStart` to point to your custom installation.

### Option 3: Build via Nix Flake

Build your modified version:

```bash
cd ~/caelestia-shell
nix build .#caelestia-shell
```

This will create a `result` symlink with your modified package.

**Update systemd service**:

```bash
systemctl --user edit caelestia.service
```

Change:

```ini
[Service]
ExecStart=
ExecStart=/home/aleh/caelestia-shell/result/bin/caelestia-shell
```

### Option 4: Override in NixOS/Home Manager

Add to your NixOS/home-manager config:

```nix
# In flake.nix or system config
{
  inputs.caelestia-shell-local.url = "path:/home/aleh/caelestia-shell";

  # For home-manager:
  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell-local.packages.x86_64-linux.default;
  };
}
```

Then rebuild your system/home-manager configuration.

### Option 5: Quick Direct Override (Simplest)

Update the systemd service to use quickshell directly:

```bash
systemctl --user edit caelestia.service
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/nix/store/hpaasjlqrjivw7w4az6071z9rk7wbvk4-quickshell-wrapped-0.2.1/bin/qs -p /home/aleh/caelestia-shell
```

## Testing Changes

After making changes:

1. **If using Option 1 or 5**: Just restart the service - the QML changes will be picked up automatically
   ```bash
   systemctl --user restart caelestia.service
   ```

2. **If using C++ changes**: Rebuild the plugin first
   ```bash
   cd ~/caelestia-shell
   cmake --build build
   systemctl --user restart caelestia.service
   ```

3. **For Nix-based options**: Rebuild and restart
   ```bash
   nix build .#caelestia-shell
   systemctl --user restart caelestia.service
   ```

## Configuration Files

Current configuration is in `~/.config/caelestia/shell.json`. You can modify:

- Widget appearance (fonts, colors, transparency)
- Which widgets are enabled/disabled
- Widget behavior and settings
- Animation speeds and transitions

## Available IPC Commands

View available commands with:
```bash
caelestia shell -s
```

Examples:
- `caelestia shell mpris playPause` - Control media
- `caelestia shell wallpaper set ~/path/to/image` - Set wallpaper
- `caelestia shell lock lock` - Lock screen

## Recommended Workflow

**For development and testing**: Use **Option 1**
- Fast iteration (QML changes don't need rebuilding)
- Keeps system intact
- Easy to switch back to stable version
- Directly uses your cloned repo

**For production use**: Use **Option 4** (Nix integration)
- Integrates cleanly with your NixOS/Home Manager setup
- Reproducible builds
- Easy rollback via Nix generations

## Quick Start Commands

```bash
# Enable development mode
cd ~/caelestia-shell
direnv allow

# Test manually before updating service
/nix/store/hpaasjlqrjivw7w4az6071z9rk7wbvk4-quickshell-wrapped-0.2.1/bin/qs -p /home/aleh/caelestia-shell

# Update service to use local repo
systemctl --user edit caelestia.service
# Add ExecStart=/nix/store/.../qs -p /home/aleh/caelestia-shell

# Restart to apply changes
systemctl --user restart caelestia.service

# Check logs
journalctl --user -u caelestia.service -f
```

## Notes

- The service is managed by systemd: `caelestia.service`
- Quickshell binary location: `/nix/store/hpaasjlqrjivw7w4az6071z9rk7wbvk4-quickshell-wrapped-0.2.1/bin/qs`
- The `caelestia-shell` wrapper is a shell script that calls quickshell with the config path
- QML files can be edited directly and changes are hot-reloaded (if watchFiles is enabled)
- C++ plugin changes require rebuilding with cmake
