--四海臣服
--lv3 当武则天受到致命伤害时，会免疫本次伤害并选择我方一名生命值最低的侠客，在之后的2秒内，将自身受到的伤害全部转移给该侠客，该效果有1 5秒冷却时间

local W_WuZT_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_WuZT_skill0_1_Model")

---@class W_WuZT_skill0_3_Model : W_WuZT_skill0_1_Model @
---@field super W_WuZT_skill0_1_Model @W_WuD_skill0_1_Model
local M = class("W_WuZT_skill0_3_Model", W_WuZT_skill0_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId3 = self:getParam(3)       --承伤buff
    self.triggerCd = self:getParam(4)     --冷却时间
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    self.cdFlag = true
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.cdFlag and self.player:equal(eventData.victim) then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
            -- 免疫本次伤害
            self.cdFlag = false
            eventData.wantdata.damage = 0
            self.player.bufMgr:addBufById(self.addBuffId, self.player, self.skill)
            local targets = SelectTargetUtil:findPlayerByParam(self.player, {
                camp = "friendExceptSelf",
                ignoreSummon = true,
                pos = "hpRateLeast",
                priority = true,
            })
            if targets.Count > 0 then  
                local ply = targets:get(0)
                if ply.bufMgr then
                    ply.bufMgr:addBufById(self.buffId3, self.player, self.skill)
                end
            end
            TimeTools:delayTime(self.triggerCd,function()
                self.cdFlag = true
            end)
        end
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M
