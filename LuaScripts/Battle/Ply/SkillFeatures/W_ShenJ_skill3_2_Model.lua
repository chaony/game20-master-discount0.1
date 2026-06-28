--神机 若大招成功击杀敌人，会恢复自身200点内力
---@class W_ShenJi_skil3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenJi_skil3_2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.anger = self:getParam(2)
end


--杀死敌人
function M:killPlayer(data)
    local skillConfig = data.attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
        --self.player.data:addAnger(self.anger, true)
        self.player.bufMgr:addBufById(self.anger,self.player, self.skill)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M