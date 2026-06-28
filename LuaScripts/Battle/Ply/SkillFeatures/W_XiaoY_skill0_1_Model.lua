--”逍遥游“状态持续期间，所有被逍遥攻击命中的敌人，都会被施加一层“玄冥”效果，被施加了“玄冥”效果的敌人，受到的治疗效果降低50%，玄冥效果持续8秒，无法叠加
---@class W_XiaoY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil then
        self.skill3 = skill3.cur_skill_config.feature
    end
end

function M:killerAfterAttack(data)
    if self.skill3 and self.skill3.state == 2 then
        local killer = data["killer"]
        local victim = data["victim"]
        if victim ~= nil and killer ~= nil and killer:equal(self.player) then
            victim.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M