--战斗开始时，飞龙堡身边会环绕一个水环，当水环存在时，飞龙堡会获得20点急速，
--当受到致命伤害时，水环会消失并抵消本次伤害，之后飞龙堡会恢复30%最大生命值的伤害和200点内力

local W_FeiLB_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_FeiLB_skill2_1_Model")

---@class W_FeiLB_skill2_2_Model : W_FeiLB_skill2_1_Model @
---@field super W_FeiLB_skill2_1_Model @W_FeiLB_skill2_1_Model
local M = class("W_FeiLB_skill2_2_Model", W_FeiLB_skill2_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    EventDispatcher:registerEvent("add_W_FeiLB_ZhiLiao_skill2", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and  self.player:equal(eventData.buff.player) then
        local friendCnt = SelectTargetUtil:findXieKeFriendWithRace(self.player, Battle.EnumData.BATTLE_RACE.Mu).Count
        local addBlood = 0
        for i = 1, friendCnt do
            addBlood = addBlood + self.addCure
        end
        local bufWork = eventData.buff.bufWork 
        if bufWork and bufWork.curblood then
            bufWork.curblood = bufWork.curblood + addBlood
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_FeiLB_ZhiLiao_skill2", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M
