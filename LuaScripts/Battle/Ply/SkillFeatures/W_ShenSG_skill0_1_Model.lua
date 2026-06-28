--神水宫的技能和普攻在命中敌人时，会为其附加一层“弱水”状态，每层弱水状态会使敌人的攻速和攻击力降低5%，最多叠加5层
---@class W_ShenSG_skil0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenSG_skil0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buff = self:getParam(1) --攻击buff
end


--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local skill = data.attackData.skillConfig
    local victim = data["victim"]
    victim.bufMgr:addBufById(self.buff, self.player, self.skill)
end


function M:destroy()
    TimeTools:stopTask(self.delayTime)
    M.super.destroy(self)
end

return M