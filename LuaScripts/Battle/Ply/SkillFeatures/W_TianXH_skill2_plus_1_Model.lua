--当天下会一次性受到超过自身最大生命值30%的血量时，会立即将本次伤害降低至自身最大生命值的30%，并使自身无敌2秒，该效果有15秒的冷却时间
---@class W_TianXH_skill2_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill2_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.triggerRate = self:getParam(1)
    self.wudiBuff = self:getParam(2)
    self.cdTime = self:getParam(3)
    self.cureBuff = self:getParam(4)
    self.cdFlag = true
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local victim = data["victim"]
    if victim ~= nil and victim:equal(self.player) and self.cdFlag and self.cdTime > 0 then
        local maxHp = self.player.data:get_hp();
        local wantData = data["wantdata"]
        local triggerHp = GlobalTools:Mul(maxHp, self.triggerRate)
        if wantData.damage > triggerHp then
            self.cdFlag = false
            data["wantdata"]["damage"] = triggerHp
            self.player.bufMgr:addBufById(self.wudiBuff, self.player, self.skill)
            if self.cureBuff > 0 then
                self.player.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
            end
            TimeTools:delayTime(self.cdTime, function()
                self.cdFlag = true
            end)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M