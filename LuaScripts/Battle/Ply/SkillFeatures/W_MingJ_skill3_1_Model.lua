
--明教瞬移到敌方血量最少的悟性型侠客身后，并对其造成300%攻击力的外功伤害，若该技能击杀了目标，
--明教会获得20%的攻击提升，该状态会持续到战斗结束，且最多可以叠加3层。
---@class W_MingJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MingJ_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) --攻击提升buf
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player) == false then
        if player.killer_player ~= nil and player.killer_player:equal(self.player) then
            local skillConfig = player.killer_player:get_curSkillConfig();
           if skillConfig ~= nil and skillConfig == self.skill then
               player.killer_player.bufMgr:addBufById(self.buffId, self.player) 
           end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end


return M