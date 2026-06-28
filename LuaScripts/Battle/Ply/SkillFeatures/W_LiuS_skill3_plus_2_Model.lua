--等级1 六扇门朝天射出10寒冰箭矢，随机攻击敌人，每支造成130%的外功伤害。受到箭矢伤害的敌人降低30%的内力恢复速度，持续5秒。
--等级2 对受到悬赏标记的敌人，每支箭矢额外造成1%的最大生命值伤害
--等级3 箭矢数量提升至14支，伤害提高至150%
--等级4 若受到伤害的敌人被施加了“悬赏”标记，则会被冰冻4秒，无法行动，无法攻击，无法恢复内力，该效果每名敌人10秒仅能触发一次。
---@class W_LiuS_skill3_plus_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiuS_skill3_plus_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.enemyBuf = self:getParam(1)
    self.enemyBuf2 = self:getParam(2)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if self.enemyBuf >= 0
            and data["attackData"].injureType == "skill"
            and skillConfig ~= nil
            and skillConfig.anim_name == "skill3_plus"
            and killer ~= nil
            and killer:equal(self.player)
            and victim ~= nil
            and victim.bufMgr:hasBufByTag("W_LiuS_skill1") then
        victim.bufMgr:addBufById(self.enemyBuf, self.player)
        if self.enemyBuf2 > 0 and not victim.bufMgr:hasBufByTag("W_LiuS_skill3_plus") then
            victim.bufMgr:addBufById(self.enemyBuf2, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
end

return M