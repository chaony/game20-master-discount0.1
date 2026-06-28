--每隔x秒，我方x个护卫侠客获得一个护盾，该护盾可吸收当前护卫侠客自身最大生命值的15%伤害且附带x%伤害减免效果。
--当击败敌方宠物后，效果强化为：可以最多给n个护卫侠客上护盾，且护盾持续时间提升z秒（这个和猫咪的一样，具体效果看buff替换）
---@class P_YangT_xiezhanskill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_xiezhanskill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.killFlag = false -- 是否击杀地方宠物
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
end

function M:skillStart(data)
    if self.killFlag then
        self.skill.extra_anim_name = "xiezhanskill1_2"
    else
        self.skill.extra_anim_name = "xiezhanskill1"
    end
    M.super.skillStart(self, data)
end

---@param eventData Battle_HandleData_PlayerDead
function M:PlayerDeadHandler(eventName, eventData)
    if self.killFlag == false then
        if eventData.data.playerType == "pet" and BattleTool:killerIsMe(self.player, eventData.data) then
            self.killFlag = true
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M