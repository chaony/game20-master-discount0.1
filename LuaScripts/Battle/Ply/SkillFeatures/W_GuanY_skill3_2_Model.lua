--武圣状态期间，关羽会获得20点吸血，期间每有一个队友死亡，还会额外获得5点吸血

local W_GuanY_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_GuanY_skill3_1_Model")
-----@class W_GuanY_skill3_2_Model : W_GuanY_skill3_1_Model @
-----@field super W_GuanY_skill3_1_Model @W_GuanY_skill3_1_Model
local M = class("W_GuanY_skill3_2_Model", W_GuanY_skill3_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    if self.alreadyAdd and not self.player:equal(data.victim) and self.player.camp == data.victim.camp then
       self.player.bufMgr:addBufById(self.extraSuckBuffId, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
	M.super.destroy(self)
end

return M