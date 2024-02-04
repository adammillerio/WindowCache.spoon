# WindowCache.spoon
Hammerspoon - Utility for quickly retrieving windows

This uses a hs.window.filter to maintain a Least Recently Used cache which can be searched either by window title or application name. This is useful for automations which benefit from quick access to windows.

This was implemented based entirely off of the source of [hs_select_window.spoon](https://github.com/dmgerman/hs_select_window.spoon) and split out to be used across other Spoons.

# Installation

## Automated

WindowCache can be automatically installed from my [Spoon Repository](https://github.com/adammillerio/Spoons) via [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html). See the repository README or the SpoonInstall docs for more information.

Example `init.lua` configuration which configures `SpoonInstall` and uses it to install and start WindowCache:

```lua
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.adammillerio = {
    url = "https://github.com/adammillerio/Spoons",
    desc = "adammillerio Personal Spoon repository",
    branch = "main"
}

spoon.SpoonInstall:andUse("WindowCache", {repo = "adammillerio", start = true})
```

## Manual

Download the latest WindowCache release from [here.](https://github.com/adammillerio/Spoons/raw/main/Spoons/MenuBarApps.spoon.zip)

Unzip and either double click to load the Spoon or place the contents manually in `~/.hammerspoon/Spoons`

Then load the Spoon in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("WindowCache")

hs.spoons.use("WindowCache", {start = true})
```

# Usage

Refer to the [hosted documentation](https://adammiller.io/Spoons/WindowCache.html) for information on usage.
