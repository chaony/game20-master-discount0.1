--羽人非獍釋放絕技飛到空中，隨後攻擊所有敵人6次，前5次每次造成120%攻擊力的傷害，最後一次會造成200%攻擊力的傷害，技能釋放期間自身無敵
-- 使用該技能成功擊殺敵人後，羽人非獍會額外恢復300點內力
---@class W_YuRFJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuRFJ_skill3_1_Model", SkillFeatures_Model)

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

function M:destroy()
    M.super.destroy(self)
end

return M