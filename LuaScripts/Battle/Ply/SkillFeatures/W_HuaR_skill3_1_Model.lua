--花荣瞄准一名血量比例最低的敌方侠客，对其造成400%攻击力的伤害，该技能无法被闪避，若该技能成功击杀了敌方侠客，则花荣会立刻恢复500点内力
---@class W_HuaR_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill3 W_HuaR_skill3_1_Model
local M = class("W_HuaR_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData = self:getParam(1)    -- Buff[] 该技能击杀敌人给自己加的BUFF
end

---@param data Battle_EventData_KillPlayer 本技能杀死敌人
function M:killPlayer(data)
    if data.attackData.skillConfig and data.attackData.skillConfig.anim_name == "skill3" then
        self.player.bufMgr:addBufById(self.buffData, self.player)
    end
end

return M