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
    -- TODO: send initial container data as part of render script
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end

function Module:scanIndustry()
    local core = modula.core
    local elementIDs = core.getElementIdList()
    for elementID in ipairs(elementIDs) do
        local info = core.getElementIndustryInfoById(elementID)
        if info and info.state and info.state > 0 then
            local name = core.getElementDisplayNameById(elementID)

            local product = info.currentProducts[1]
            if product then
                local productItem = system.getItem(product.id)
                local name = productItem.locDisplayName
                local icon = productItem.iconPath
                local schematic = productItem.schematics[1]
                local state = info.state
                if state == 2 then
                    local remaining = info.schematicsRemaining
                    if (remaining > 0) and (remaining < 10) then
                        debugf("%s: Schematics Low (%s)", name, remaining)
                    end
                elseif state == 7 then
                    debugf("%s: Out Of Schematics", name)
                    debugf(core.getElementClassById(elementID))
                    debugf(productItem)
                end
            end

        end
    end

end

Module.renderScript = [[

state = state or { lines = { "hello world" }}

if payload then
    local text = payload.text
    if text then
        table.append(state.lines, text)
    end
    reply = { result = "ok" }
end

local screen = toolkit.Screen.new()
local layer = screen:addLayer()

local chart = layer:addField(layer.rect:inset(10), state)

layer:render()
screen:scheduleRefresh()
]]

return Module