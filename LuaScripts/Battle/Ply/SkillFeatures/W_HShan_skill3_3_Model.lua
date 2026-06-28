--若该技能击杀了敌人，则衡山会获得持续5秒的急速效果
---@class W_HShan_skill3_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HShan_skill3_3_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.speedBuff = self:getParam(1)
end

--杀死敌人
function M:killPlayer(data)
    local skillConfig = data.attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
        self.player.bufMgr:addBufById(self.speedBuff, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M