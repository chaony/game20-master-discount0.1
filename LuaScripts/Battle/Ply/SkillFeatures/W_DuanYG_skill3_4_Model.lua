--段瑛谷
--锻瑛谷消耗所有内力，立即恢复最大生命值30%的血量并使自身进入“阎魔”状态6秒，阎魔状态持续期间，锻瑛谷每秒会对自身周围的敌人造成100%攻击力的伤害且攻击力会提升50%
--lv 4 若阎魔状态持续时间超过了4秒，则之后造成的伤害会无视敌人50%的防御
---@class W_DuanYG_skill3_4_Model : SkillFeatures_Model @
---@field super W_DuanYG_skill3_1_Model @W_DuanYG_skill3_1_Model
local W_DuanYG_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_DuanYG_skill3_1_Model")
local M = class("W_DuanYG_skill3_4_Model", W_DuanYG_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.delayTime = self:getParam(1) --几秒
    self.buffId2 = self:getParam(2) --无视敌人50%的防御
    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
end

---@param eventData Battle_HandleData_SkillEnter
function M:skillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3" then
        if self.delayTime > 0 then
            TimeTools:delayTime(self.delayTime, handler(self, self.addBreakBuff))
        end
    end
end

function M:addBreakBuff()
    for i = 1, #self.lineTab do
        if self.lineTab[i].target and self.lineTab[i].target.bufMgr then
            self.lineTab[i].target.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M