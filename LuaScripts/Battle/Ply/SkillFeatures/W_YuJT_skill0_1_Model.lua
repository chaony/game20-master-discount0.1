--御竞堂向敌方最密集区域踢出蹴鞠，蹴鞠落地后会爆炸，对大范围内的敌人造成300%攻击力的伤害和2秒眩晕效果
--lv2被命中的敌人还会被施加2层“破甲”状态（破甲：防御力降低10%，持续8秒，最多可叠加5层）
---@class W_YuJT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuJT_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)--破甲buffid
    self.buffNums = self:getParam(2)--2层
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill and self.buffNums > 0 then
        for i = 1, self.buffNums do
            data.victim.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M