--当百花派处于生息场地中时，每受到5次恢复效果后，便会随机为己方侠客种下1个“共生”之种

local W_BaiHP_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_BaiHP_skill0_2_Model")

---@class W_BaiHP_skill0_4_Model : W_BaiHP_skill0_2_Model @
---@field super W_BaiHP_skill0_4_Model @W_BaiHP_skill0_1_Model
local M = class("W_BaiHP_skill0_4_Model", W_BaiHP_skill0_2_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.curCureTime = 0
    EventDispatcher:registerEvent("cure", {self,self.cureHandler})
end

---@param eventData Battle_HandleData_Cure
function M:cureHandler(eventName, eventData)
    if self.player:equal(eventData.player) and self:isInSXBuff(self.player) then
        self.curCureTime = self.curCureTime + 1
        if self.curCureTime >= self.triggerCureCnt then
            self.curCureTime = 0
            local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friend", ignoreSummon = true, priority = true})
            
            local noBuffTargets = {}
            targets:safeWalkInverted(function(ply)
                if not (ply.bufMgr:hasBufByTag("W_BaiH_skill2") or  ply.bufMgr:hasBufByTag("W_BaiH_skill21")) then
                    table.insert(noBuffTargets, ply)
                end
            end)
            
            ---@type PlayerModel
            local target = GlobalTools:RandomOneFromArray(noBuffTargets)
            if target then
                target.bufMgr:addBufById(self.addExtraBuff2, self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("cure", {self,self.cureHandler})
    M.super.destroy(self)
end

return M