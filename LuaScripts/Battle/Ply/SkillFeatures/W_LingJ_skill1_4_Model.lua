-- 冰犬死亡时,额外对周围敌方侠客附加一个印记,复活冰犬所需的时间缩短至10秒

---@class W_LingJ_skill1_4_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local W_LingJ_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_LingJ_skill1_3_Model")
local M = class("W_LingJ_skill1_4_Model", W_LingJ_skill1_3_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 冰犬死亡印记addbuf
    self.yinjiBuf = self:getParam(6)
end


--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
end

--死亡回调
function M:langDead(player)
    M.super.langDead(self,player)
    if player ~= nil then
        player.bufMgr:addBufById( self.yinjiBuf, self.player)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M