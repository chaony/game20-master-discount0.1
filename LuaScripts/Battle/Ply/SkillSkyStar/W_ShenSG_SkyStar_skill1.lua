--"碧波牢：被碧波牢困住的敌人恢复内力降低50%

---@class W_ShenSG_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ShenSG_SkyStar_skill1",SkillSkyStar)

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
    if self.player:equal(ply) and skillConfig ~= nil and skillConfig.anim_name == "skill2" and victim and victim.bufMgr then
        victim.bufMgr:addBufById(self.buffId1, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M;