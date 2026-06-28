-- lv4 该技能每成功命中一个敌人，唐伯虎便获得一层60%攻击力的护盾，持续5秒

local W_BaWQ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_BaWQ_skill2_1_Model")

---@class W_BaWQ_skill2_4_Model : W_BaWQ_skill2_1_Model @
---@field super W_BaWQ_skill2_1_Model @W_BaWQ_skill2_1_Model
local M = class("W_BaWQ_skill2_4_Model", W_BaWQ_skill2_1_Model)

function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and (data.attackData and data.attackData.skillConfig == self.skill) then
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
end

return M
