--悲魔山庄	蚀骨血刃
-- lv3 该技能每命中一个敌人，即为自身添加一层80%攻击力的护盾，持续5秒

local W_BeiMSZ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_BeiMSZ_skill2_1_Model")
---@class W_BeiMSZ_skill2_3_Model : W_BeiMSZ_skill2_1_Model @
---@field super W_BeiMSZ_skill2_1_Model @W_BeiMSZ_skill2_1_Model
local M = class("W_BeiMSZ_skill2_3_Model", W_BeiMSZ_skill2_1_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addOnHitBuffId = self:getParam(3) -- Buff[] 命中添加护盾buff
end

function M:onRealHitSomeBody(player, isFirst)
    M.super.onRealHitSomeBody(self, player, isFirst)

    self.player.bufMgr:addBufById(self.addOnHitBuffId, self.player, self.skill)
end

return M