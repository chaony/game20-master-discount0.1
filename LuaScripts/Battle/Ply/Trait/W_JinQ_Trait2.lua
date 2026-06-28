--金钱帮角色的专属装备

--该技能将拥有额外30%的吸血

local W_JinQ_Trait1 = require("Battle.Ply.Trait.W_JinQ_Trait1")

---@class W_JinQ_Trait2 : W_JinQ_Trait1 @
---@field super W_JinQ_Trait1 @W_JinQ_Trait1
local M = class("W_JinQ_Trait2", W_JinQ_Trait1)

M.leeching = nil
function M:init()
    M.super.init(self)
    self.leeching = self:getValue(2)
    
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEnd_Handler})
end

function M:SkillEnterHandler(eventName, data)

    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and "skill2" == config.anim_name then
        self.player.data.leeching:addToAddList(self.leeching)
    end
end

function M:SkillEnd_Handler(eventName, data)

    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and "skill2" == config.anim_name then
        self.player.data.leeching:removeFromAddList(self.leeching)
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEnd_Handler})
end

return M