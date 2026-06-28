-- 
--蝴蝶君對當前目標快速攻擊三次，每次造成100%攻擊力的傷害，釋放該技能後，蝴蝶君會獲得30%的攻速提升，持續5秒
--（霹靂效果：每額外上陣一位霹靂俠客，攻速提升效果便額外增加10%）
---@class W_HuDJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuDJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId = self:getParam(1)
    EventDispatcher:registerEvent("SkillEnd", {self,self.skillEndHandler})
end

---@param data Battle_HandleData_SkillEnd
function M:skillEndHandler(eventName, data)
    if self.player:equal(data.player) and data.skillConfig and data.skillConfig.anim_name == "skill2" then
        local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})
        for i = friends.Count, 1, -1 do
            local friend = friends:get(i-1)
            if friend and friend ~= self.player and table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(friend.plyData.id)) then
                self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.skillEndHandler})
    M.super.destroy(self)
end

return M