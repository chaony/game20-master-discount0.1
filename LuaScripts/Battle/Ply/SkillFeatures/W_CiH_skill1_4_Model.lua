-- 治疗一名最虚弱的友军，使其每秒恢复5%最大生命值的血量，持续6秒,
-- 该技能对生命值低于20%的友军造成的治疗效果额外提升30%
--- 随机清1层负面buff
---@class W_CiH_skill1_4_Model : W_CiH_skill1_1_Model
local M = class("W_CiH_skill1_4_Model", require("Battle.Ply.SkillFeatures.W_CiH_skill1_1_Model"))

function M:init(player, skill, className)
    M.super.init(self, player, skill, className)
    self.hpRate = self:getParam(2)
    self.cureRate = self:getParam(3)
    EventDispatcher:registerEvent("add_W_CiH_skill1", {self,self.addBuffHandler})
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        if buff.player.data:get_hpRate() < self.hpRate then
            buff.bufWork.curAtkblood = GlobalTools:Mul(buff.bufWork.curAtkblood, GlobalTools.base1 + self.cureRate)
        end

    end
end
--
--function M:injureHandler(eventName, data)
--    local killer = data["killer"]
--    local victim = data["victim"]
--    local skillConfig = data["attackData"]["skillConfig"]
--    if killer ~= nil and killer:equal(self.player) == true and skillConfig.anim_name == "skill1" then
--        self.target = nil
--        self.improve = false
--    end
--end
--
----作为攻击者的属性临时调整
--function M:killerDataChangeTemp(victim, skill)
--    if victim ~= nil and skill ~= nil and skill.anim_name == "skill1" then
--        if self.target == nil then
--            self.target = victim
--            if self.target.data:get_hpRate() < self.hpRate then
--                self.improve = true
--            end
--        end
--        if self.improve == true then
--            self.player.data.cureRate:addToMulListTemp(self.cureRate)
--        end
--    end
--end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_CiH_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M