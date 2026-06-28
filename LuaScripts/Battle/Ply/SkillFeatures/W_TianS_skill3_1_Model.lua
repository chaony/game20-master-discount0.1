--天山召唤数把飞剑，先将敌人禁锢，随后对其造成7段伤害，前6段每次造成60%攻击力的伤害，最后一段会造成160%攻击力的伤害且必定暴击
--若该技能成功击杀了敌人，则天山会提升20%的暴击率，持续5秒
---@class W_TianS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianS_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.critBuff = self:getParam(1) --暴击buff
    self.angerBuff = self:getParam(2) --怒气buff
end

--杀死敌人
function M:killPlayer(data)
    local skillConfig = data.attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
        self.player.bufMgr:addBufById(self.critBuff, self.player, self.skill)
        self.player.bufMgr:addBufById(self.angerBuff, self.player, self.skill)
    end
end

function M:destroy()
	M.super.destroy(self)
end

return M