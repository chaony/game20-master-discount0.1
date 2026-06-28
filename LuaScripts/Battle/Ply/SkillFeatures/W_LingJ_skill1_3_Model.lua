-- 冰犬死亡时,降低周围敌方侠客15%攻速,持续8秒

---@class W_LingJ_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local W_LingJ_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_LingJ_skill1_2_Model")
local M = class("W_LingJ_skill1_3_Model", W_LingJ_skill1_2_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 冰犬死亡降攻速addbuff
    self.reduceBuf = self:getParam(5)
end


--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
end

--死亡回调
function M:langDead( player )
    M.super.langDead(self, player)
    if player ~= nil then
        player.bufMgr:addBufById( self.reduceBuf, self.player)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M