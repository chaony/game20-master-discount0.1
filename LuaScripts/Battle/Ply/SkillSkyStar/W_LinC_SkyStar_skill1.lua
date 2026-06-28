--"刹那阎罗：
--林冲“风雪神威”3次攻击附加10%敌方最大生命值的伤害

---@class W_LinC_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LinC_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId1 = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if self.player:equal(ply) and skillConfig ~= nil and skillConfig.anim_name == "skill1" and victim and victim.bufMgr and BattleTool:isSkillInjure(data.attackData) then
        victim.bufMgr:addBufById(self.buffId1, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M;