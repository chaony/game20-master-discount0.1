---@class W_YaoW_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YaoW_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.hp = self:getParam(1)
    self.cureRate = self:getParam(2)
    self.cureList = Battle.List.new()
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    self.cureList:clear()

    local friendList = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, friendList.Count do
        local friend = friendList:get(i - 1)
        if friend.data:get_hpRate() <= self.hp then
            self.cureList:add(friend)
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    if skill ~= nil and skill.anim_name == "skill3" then
        if victim ~= nil and self.cureList:contains(victim) then
            self.player.data.cureRate:addToMulListTemp(self.cureRate)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M