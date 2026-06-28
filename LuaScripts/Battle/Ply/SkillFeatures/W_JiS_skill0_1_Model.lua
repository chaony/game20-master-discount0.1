--战斗中，当姬霜受到致命伤害时，会召唤一团蔽日烟雾隐藏自身3秒，期间不会受到任何伤害，也无法攻击，当姬霜处于烟雾中时，会每秒恢复10%最大生命值的血量，
--每次战斗只能触发一次

---@class W_JiS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiS_skill0_1_Modela", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addBuffId = self:getParam(1) -- Buff[] 给自己加buff烟雾等
    self.damageBuffId = self:getParam(2) -- Buff[] 伤害buff

    self.triggerCnt = 0

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.triggerCnt < 1 and self.player:equal(eventData.victim) then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
            self.triggerCnt = self.triggerCnt + 1
            -- 免疫本次伤害
            eventData.wantdata.damage = 0
            self.player.bufMgr:addBufById(self.addBuffId, self.player, self.skill)
            -- 检查触发天命化星
            if self.player.skyStar then
                local target = SelectTargetUtil:findOneEnemy(self.player)
                if target then
                    self.player.skyStar:triggerStart(target)
                end
            end
            -- 鬼王状态造成范围伤害
            if self.player.bufMgr:hasBufByTag("JiS_skill3") then
                self.player.bufMgr:addBufById(self.damageBuffId, self.player, self.skill)
            end
        end
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M