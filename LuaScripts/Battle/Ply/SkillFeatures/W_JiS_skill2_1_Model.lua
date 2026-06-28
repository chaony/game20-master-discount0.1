--战斗开始时，姬霜会召唤风伯攻击敌方后排，对其造成200%攻击力的伤害，
--之后每次释放“鬼王招来”时，还会额外释放一次该技能

---@class W_JiS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiS_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    EventDispatcher:registerEvent("SkillEnd", {self,self.skillEndHandler})
end

---@param eventData Battle_HandleData_SkillEnd
function M:skillEndHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3" then
        TimeTools:delayTime(GlobalTools.base0_1, function()
            self.player:useSkill("skill2", true)
        end)
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.skillEndHandler})
    M.super.destroy(self)
end

return M