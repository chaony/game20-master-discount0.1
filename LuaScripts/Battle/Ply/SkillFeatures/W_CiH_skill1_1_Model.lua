-- 治疗一名最虚弱的己方侠客，为其随机清除一层负面状态，并使其每秒恢复50%攻击力的生命值，持续6秒
---@class W_CiH_skill1_1_Model : SkillFeatures_Model
local M = class("W_CiH_skill1_1_Model", SkillFeatures_Model)

function M:init(player, skill, className)
    M.super.init(self, player, skill, className)
    self.removeCnt = self:getParam(1)
    if self.removeCnt > 10 then
        self.removeCnt = 10
    end
end

---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if data.victim ~= nil and data.attackData.skillConfig == self.skill then
        for i = 1, self.removeCnt do
            if data.victim.bufMgr:removeRandomOneBufByTag("debuff", false) == 0 then
                break   -- 没有debuff，可以中断逻辑
            end
        end
    end
end

return M