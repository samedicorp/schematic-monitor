-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = { }

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop")
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Schematic Monitor started.")

    self:attachToScreen()
end

function Module:onStop()
    debugf("Schematic Monitor stopped.")
end

function Module:onScreenReply(reply)
    -- handle screen messages here
end


-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:attachToScreen()
    -- TODO: send initial container data as part of render script
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end

Module.renderScript = [[

containers = containers or {}

if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end

local screen = toolkit.Screen.new()
local layer = screen:addLayer()

state = state or { lines = { "hello world" }}
local chart = layer:addField(layer.rect:inset(10), state)

layer:render()
screen:scheduleRefresh()
]]

return Module