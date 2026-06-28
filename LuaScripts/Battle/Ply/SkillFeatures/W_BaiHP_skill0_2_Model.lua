--当百花派处于生息场地中时，每攻击3次后，下一次攻击便会为一名随机敌人施加寄生之种

local W_BaiHP_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_BaiHP_skill0_1_Model")

---@class W_BaiHP_skill0_2_Model : W_BaiHP_skill0_1_Model @
---@field super W_BaiHP_skill0_1_Model @W_BaiHP_skill0_1_Model
local M = class("W_BaiHP_skill0_2_Model", W_BaiHP_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.curHitTime = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.attackData.player) and self:isInSXBuff(self.player) then
        self.curHitTime = self.curHitTime + 1
        if self.curHitTime >= self.triggerHitCnt then
            self.curHitTime = 0
            local targets = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", posIndex = "backrow", ignoreSummon = true, priority = true})

            local backList = Battle.List.new()
            local frontList = Battle.List.new()
            targets:safeWalkInverted(function(ply)
                if not (ply.bufMgr:hasBufByTag("W_BaiH_skill1") or ply.bufMgr:hasBufByTag("W_BaiH_skill11")) then
                    if SceneManager.curScene.ZhenFaManager:isFront(ply:get_camp(), ply.index) then
                        frontList:add(ply)
                    else
                        backList:add(ply)
                    end
                end
            end)

            ---@type PlayerModel
            local target
            if backList.Count > 0 then
                target = GlobalTools:RandomOneFromList(backList)
            elseif frontList.Count > 0 then
                target = GlobalTools:RandomOneFromList(frontList)
            end
            if target then
                target.bufMgr:addBufById(self.addExtraBuff1, self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M