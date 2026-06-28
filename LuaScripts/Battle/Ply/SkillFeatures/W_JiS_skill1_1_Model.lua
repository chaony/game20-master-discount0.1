--在随机两个敌人背后召唤邪兵，对其造成200%攻击力的伤害，
--释放时若自身存在“鬼王”状态，则该技能会攻击敌方全体

---@class W_JiS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiS_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addBuff1 = self:getParam(1) --Buff[] 技能冷却减少buff

    -- 鬼王状态有额外效果
    self.isUpgrade = false
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.player.bufMgr:hasBufByTag("JiS_skill3") then
        -- 鬼王状态技能升级
        self.isUpgrade = true
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    else
        self.isUpgrade = false
    end
end

function M:skillEnd(data)
    if self.isUpgrade then
        self.isUpgrade = false
        self.player.bufMgr:removeBufById(self.addBuff1)
    end
    M.super.skillEnd(self, data)
end

function M:findPlayer(data)
    if self.skill == self.player.curSkillConfig then
        if self.isUpgrade then  -- 释放时若自身存在“鬼王”状态，则该技能会攻击敌方全体
            return SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy"})
        end
    end
    return data
end

return M