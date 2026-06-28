
---@class G_JinQ_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("G_JinQ_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end


--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    local buff = self.player.bufMgr:findBufByTag("W_JinQ_skill3")
    if #buff > 0 then
        self.skill.extra_anim_name = "attack1_2"
    else
        self.skill.extra_anim_name = "attack1_1"
    end
end

--销毁
function M:destroy()
    M.super.destroy(self)
end

return M