--对大范围内的敌人造成200%的伤害，若命中的敌人身上有中毒效果，则会使中毒层数翻倍，并刷新中毒效果的持续时间。
--（（中毒：每2秒发作一次，发作时造成100%攻击力的伤害并减少中毒者20点内力，持续6秒，最多叠加3层））
---@class W_ShenSG_skil3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenSG_skil3_1_Model", SkillFeatures_Model)


--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.buff = self:getParam(1) --中毒buff
--    self.time = self:getParam(2) --发作频率加速持续时间
--    self.count = self:getParam(3) --加速后生效次数
--    self.workTime = self:getParam(4) --加速后间隔时间
--end
--
--
----攻击者攻击结束处理
--function M:killerAfterAttack(data)
--    local skill = data.attackData.skillConfig
--    local victim = data["victim"]
--    if skill ~= nil and skill.anim_name == "skill3" then
--        local poisonBuff = victim.bufMgr:addBufById(self.buff, self.player, self.skill)
--        local workRound = poisonBuff.workRound
--        local workTime = poisonBuff.workTime
--        poisonBuff.workRound = self.count
--        poisonBuff.workTime = self.workTime
--        poisonBuff.curWorkTime = self.workTime
--        
--        self.delayTime = TimeTools:delayTime(self.time, function()
--            poisonBuff.workRound = workRound
--            poisonBuff.workTime = workTime
--        end)
--    end
--end
--
--
--function M:destroy()
--    TimeTools:stopTask(self.delayTime)
--    M.super.destroy(self)
--end

return M