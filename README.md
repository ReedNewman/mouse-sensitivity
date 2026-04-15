# mouse-sensitivity

Automatically adjusts macOS mouse tracking speed based on the connected network. Useful when switching between setups that need different sensitivity (e.g., desk with a large monitor vs. laptop on the go).

## How it works

A lightweight background process watches for two events:
- **Screen unlock** (via `com.apple.screenIsUnlocked` distributed notification)
- **Network change** (via `NWPathMonitor`)

When either fires, it checks the default gateway IP and sets the mouse tracking speed accordingly. No polling — it only runs when something actually changes.

> **Why gateway IP instead of SSID?** Starting in macOS 15, `networksetup -getairportnetwork` and `CoreWLAN` redact the SSID unless the app has Location Services permission. The default gateway uniquely identifies a network without any special entitlements.

## Configuration

Create `~/.config/mouse-sensitivity/networks.conf` with your network mappings:

```
# Format: gateway_ip speed network_name
192.168.1.1 3.0 home
10.0.0.1 2.0 office
```

To find your current gateway: `route -n get default | awk '/gateway:/{print $2}'`

See `networks.conf.example` for a template.

The `com.apple.mouse.scaling` range is roughly **0.0** (slowest) to **3.0** (fastest). For reference, the macOS System Settings slider maps approximately:

| Slider Position | Value |
|----------------|-------|
| ~25% | 0.5 |
| ~50% | 1.5 |
| ~75% | 2.5 |
| 100% | 3.0 |

## Install

```bash
./install.sh
```

This compiles the Swift watcher, copies everything to `~/.config/mouse-sensitivity/`, installs the launchd agent, and starts it immediately.

## Uninstall

```bash
./uninstall.sh
```

Stops the agent, removes all installed files, and resets mouse speed to 1.0.

## Files

| File | Purpose |
|------|---------|
| `mouse-sensitivity.sh` | Checks gateway IP, sets mouse speed if network changed |
| `screen-unlock-trigger.swift` | Background watcher — fires the script on unlock / network change |
| `networks.conf.example` | Example network config (copy to `~/.config/mouse-sensitivity/networks.conf`) |
| `com.reed.mouse-sensitivity.plist` | launchd agent definition |
| `install.sh` / `uninstall.sh` | Setup and teardown |

## Logs

```
~/.config/mouse-sensitivity/output.log
~/.config/mouse-sensitivity/error.log
```

## Requirements

- macOS 15+ (Sequoia) — should also work on older versions
- Xcode Command Line Tools (for `swiftc`)
