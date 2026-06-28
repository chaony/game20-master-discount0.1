--释放时若自身“薰风”效果叠加了3层以上，则该技能无法被闪避，且眩晕时间会延长至3秒

---@class W_SuX_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill1 W_SuX_skill1_1_Model
local M = class("W_SuX_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.triggerCnt = self:getParam(1)  -- int[]所少层触发效果
    self.addTime = self:getParam(2)  -- 眩晕增加时长
    EventDispatcher:registerEvent("add_SuX_skill1", {self,self.addBuffHandler})

end

function M:spawn()
    M.super.spawn(self)
    self.skill0 = BattleTool:getSkillFeatureByName(self.player, "skill0")
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if self.player:equal(eventData.buff.source) then
        if self.triggerCnt > 0 and self.skill0 and self.skill0.curAddBuffCnt >= self.triggerCnt then
            eventData.buff:addLastTime(self.addTime)
        end
    end
end

--攻击者的攻击开始处理
---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if victim and self.player:equal(attackData.player) and attackData.skillConfig and attackData.skillConfig.anim_name == "skill1" then
        if self.triggerCnt > 0 and self.skill0 and self.skill0.curAddBuffCnt >= self.triggerCnt then
            attackData["mustHit"] = true
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_SuX_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M