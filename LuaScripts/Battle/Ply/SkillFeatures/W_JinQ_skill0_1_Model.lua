---@class W_JinQ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinQ_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.leeching = self:getParam(1)
    self.list = Battle.List.new()
    EventDispatcher:registerEvent("spawn", {self,self.SpawnHandler})
end


function M:SpawnHandler( eventName, data )
    local player = data["player"]
    --对自己生效
    if player ~= nil and player.camp == self.player.camp then
        self.list:add(player)
        player.data.leeching:addToAddList(self.leeching)
        self:changeValue(player)
    end
end

function M:changeValue(player)
    -- body
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("spawn", {self,self.SpawnHandler})
    for i = 1, self.list.Count do
        local ply = self.list:get(i - 1)
        if ply ~= nil and ply:isLive() then
            ply.data.leeching:removeFromAddList(self.leeching)
        end
    end
    self.list:clear()
end

return M