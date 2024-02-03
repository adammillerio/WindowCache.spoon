--- === WindowCache ===
---
--- Utility for quickly retrieving windows
---
--- Download: https://github.com/adammillerio/Spoons/raw/main/Spoons/WindowCache.spoon.zip
--- 
--- Example Usage (Using [SpoonInstall](https://zzamboni.org/post/using-spoons-in-hammerspoon/)):
--- spoon.SpoonInstall:andUse(
---   "WindowCache",
---   {
---     start = true
---   }
--- )
local WindowCache = {}

WindowCache.__index = WindowCache

-- Metadata
WindowCache.name = "WindowCache"
WindowCache.version = "0.1"
WindowCache.author = "Adam Miller <adam@adammiller.io>"
WindowCache.homepage = "https://github.com/adammillerio/WindowCache.spoon"
WindowCache.license = "MIT - https://opensource.org/licenses/MIT"

--- WindowCache.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log
--- level for the messages coming from the Spoon.
WindowCache.logger = nil

--- WindowCache.windowFilter
--- Variable
--- Main hs.window.filter. This is what is used to enumerate and maintain the window
--- cache. It is a copy of the "default" window filter with WindowCache specific
--- sort order and callback configurations applied in the start method.
WindowCache.windowFilter = nil

--- WindowCache.currentWindows
--- Variable
--- Table containing the window cache, ordered by the time it was added to the
--- cache.
WindowCache.currentWindows = nil

WindowCache.subscribedFunctions = nil

function WindowCache:init()
    self.logger = hs.logger.new("WindowCache")
    self.windowFilter = hs.window.filter.new(false)
    self.currentWindows = {}
    self.subscribedFunctions = {}
end

function WindowCache:findWindowByTitle(title)
    for i, currentWindow in ipairs(self.currentWindows) do
        if string.find(currentWindow:title(), title) then
            return currentWindow
        end
    end

    return nil
end

function WindowCache:focusWindowByTitle(title)
    window = self:findWindowByTitle(title)

    if window then window:focus() end

    return window
end

function WindowCache:findWindowByApp(appName)
    for i, currentWindow in ipairs(self.currentWindows) do
        if string.find(currentWindow:application():name(), appName) then
            return currentWindow
        end
    end

    return nil
end

function WindowCache:focusWindowByApp(appName)
    window = self:findWindowByApp(appName)

    if window then window.focus() end

    return window
end

function WindowCache:_callbackWindowCreated(window, appName, event)
    self.logger.vf("Caching created window %s", window)
    table.insert(self.currentWindows, 1, window)
end

function WindowCache:_callbackWindowDestroyed(window, appName, event)
    for i, currentWindow in ipairs(self.currentWindows) do
        if currentWindow == window then
            self.logger.vf("Removing destroyed window: %s", window)
            table.remove(self.currentWindows, i)

            return
        end
    end

    -- No cached window, this can happen if it is being cached for the first time
    -- on the destroy call, so it's verbose and not a warning.
    self.logger.vf("Could not find destroyed window in cache: %s", window)
end

function WindowCache:_callbackWindowFocused(window, appName, event)
    self.logger.vf("Window focused: %s", window)
    self:_callbackWindowDestroyed(window, appName, "windowDestroyed")
    self:_callbackWindowCreated(window, appName, "windowCreated")
end

-- Utility function to allow for subscribing to callbacks at the instance level.
-- Creates a partial function with the callback call, including the instance, and
-- inserts it in a table to be unsubscribed later.
function WindowCache:_subscribe(event, callback)
    partialFunction = hs.fnutils.partial(callback, self)
    self.windowFilter:subscribe(event, partialFunction)
    table.insert(self.subscribedFunctions, partialFunction)
end

-- Utility function to load all windows into the cache on initial load.
function WindowCache:_initialize()
    for i, window in ipairs(self.windowFilter:getWindows()) do
        self:_callbackWindowCreated(window, window:application():name(),
                                    "windowCreated")
    end
end

function WindowCache:start()
    self.logger.v("Starting window filter")

    -- The {} instead of () is important here, this specifically includes windows
    -- in all spaces and not just the current space.
    self.windowFilter:setDefaultFilter{}
    self.windowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)

    -- Initialize window cache.
    self:_initialize()

    self:_subscribe(hs.window.filter.windowCreated, self._callbackWindowCreated)
    self:_subscribe(hs.window.filter.windowDestroyed,
                    self._callbackWindowDestroyed)
    self:_subscribe(hs.window.filter.windowFocused, self._callbackWindowFocused)
end

function WindowCache:stop()
    self.logger.v("Stopping window filter")
    self.windowFilter:unsubscribe(nil, self.subscribedFunctions)
end

return WindowCache
