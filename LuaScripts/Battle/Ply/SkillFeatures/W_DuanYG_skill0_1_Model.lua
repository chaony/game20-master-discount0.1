--段瑛谷
--锻瑛谷每受到一次恢复效果，便会获得一层“锻铁”效果，每层锻铁效果会使自身防御力提升2%，最多提升50%
--lv 4 当锻瑛谷受到致命伤害时，会消耗当前锻铁层数的一半，免疫本次伤害并无敌2秒，每消耗一层锻铁层数，便恢复最大生命值1%的血量
---@class W_DuanYG_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanYG_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId1 = self:getParam(1) --锻铁buff
    EventDispatcher:registerEvent("cure", {self,self.cureHandler})
end

function M:cureHandler(eventName, eventData)
    if self.player:equal(eventData.player) then
        self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("cure", {self,self.cureHandler})
    M.super.destroy(self)
end

return M