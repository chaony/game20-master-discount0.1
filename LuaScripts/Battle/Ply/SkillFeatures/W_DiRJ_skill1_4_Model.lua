--lv4击杀我方单位的敌方侠客将立刻被施加一层断狱状态
local W_DiRJ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_DiRJ_skill1_1_Model")
---@class W_DiRJ_skill1_3_Model : W_DiRJ_skill1_1_Model @
---@field super W_DiRJ_skill1_1_Model @W_DiRJ_skill1_1_Model
local M = class("W_DiRJ_skill1_3_Model", W_DiRJ_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler2})
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler2(eventName, data)
    local victim = data.victim
    local killer = data.killer
    if victim and self.player.camp == victim.camp and killer and killer.bufMgr then
        killer.bufMgr:addBufById(self.duanYuBuffId, self.player, self.skill)    
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler2})
    M.super.destroy(self)
end

return M