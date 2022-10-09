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

    self.industry = modula:getService("industry")

    self:attachToScreen()
    self:scanIndustry()
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
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end

function Module:scanIndustry()
    local industry = self.industry
    local alerts = {}

    if industry then
        local machines = industry:getMachines()
        for i,machine in ipairs(machines) do
            local product = machine.mainProduct
            if product then
                local state = machine.state
                if state > 0 then
                    local name = product:getName()
                    -- local icon = product:getIcon()
                    if machine:isRunning() or machine:isPending() then
                        local remaining = machine.schematicsRemaining
                        if (remaining > 0) and (remaining < 10) then
                            local alert = string.format("%s: Schematics Low (%s)", name, remaining)
                            table.insert(alerts, alert)
                        end
                    elseif machine:isMissingSchematics() then
                        local alert = string.format("%s: Out Of Schematics", name)
                        table.insert(alerts, alert)
                    end
                end
            end
        end
    end

    self.screen:send(alerts)
end


Module.renderScript = [[

state = state or { lines = { "hello world" }}

if payload then
    state.lines = payload
    reply = { result = "ok" }
end

local screen = toolkit.Screen.new()
local layer = screen:addLayer()
local font = toolkit.Font.new("Play", 40)
local chart = layer:addField(layer.rect:inset(10), state, font)

layer:render()
screen:scheduleRefresh()
]]

return Module