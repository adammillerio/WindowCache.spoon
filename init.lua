--- === WindowCache ===
---
--- Utility for quickly retrieving windows
---
--- Download: [https://github.com/adammillerio/WindowCache.spoon/archive/refs/heads/main.zip](https://github.com/adammillerio/WindowCache.spoon/archive/refs/heads/main.zip)
local obj = {}
obj.__index = obj

-- WindowCache.logger
-- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = nil

obj.windowFilter = nil

obj.currentWindows = nil

function obj:init()
    obj.logger = hs.logger.new('WindowCache')
    obj.windowFilter = hs.window.filter.new(false)
    obj.currentWindows = {}
end

function obj:findWindowByTitle(title)
    for i, currentWindow in ipairs(obj.currentWindows) do
        if string.find(currentWindow:title(), title) then
            return currentWindow
        end
    end

    return nil
end

function obj:focusWindowByTitle(title)
    window = obj:findWindowByTitle(title)

    if window then window:focus() end

    return window
end

function obj:findWindowByApp(appName)
    for i, currentWindow in ipairs(obj.currentWindows) do
        if string.find(currentWindow:application():name(), appName) then
            return currentWindow
        end
    end

    return nil
end

function obj:focusWindowByApp(appName)
    window = obj:findWindowByApp(appName)

    if window then window.focus() end

    return window
end

local function callbackWindowCreated(window, appName, event)
    obj.logger.vf("Caching created window %s", window)
    table.insert(obj.currentWindows, 1, window)
end

local function callbackWindowDestroyed(window, appName, event)
    for i, currentWindow in ipairs(obj.currentWindows) do
        if currentWindow == window then
            obj.logger.vf("Removing destroyed window: %s", window)
            table.remove(obj.currentWindows, i)

            return
        end
    end

    -- No cached window, this can happen if it is being cached for the first time
    -- on the destroy call, so it's verbose and not a warning.
    obj.logger.vf("Could not find destroyed window in cache: %s", window)
end

local function callbackWindowFocused(window, appName, event)
    obj.logger.vf("Window focused: %s", window)
    callbackWindowDestroyed(window, appName, "windowDestroyed")
    callbackWindowCreated(window, appName, "windowCreated")
end

function obj:start()
    obj.logger.v('Starting window filter')
    obj.windowFilter:setDefaultFilter()
    obj.windowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)

    obj.windowFilter:subscribe(hs.window.filter.windowCreated,
                               callbackWindowCreated)
    obj.windowFilter:subscribe(hs.window.filter.windowDestroyed,
                               callbackWindowDestroyed)
    obj.windowFilter:subscribe(hs.window.filter.windowFocused,
                               callbackWindowFocused)

    obj.windowFilter:subscribe(hs.window.filter.windowUnhidden,
                               callbackWindowCreated)
end

function obj:stop()
    obj.logger.v('Stopping window filter')
    obj.windowFilter:unsubscribe(nil, {
        callbackWindowCreated, callbackWindowDestroyed, callbackWindowFocused
    })
end

return obj
