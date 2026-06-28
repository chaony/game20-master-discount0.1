--绝情 skill1 对前面的敌人进行三段连击 每段90%攻击力的伤害 最后一击为敌人施加1层绝杀印记 印记最多叠加5层 每层都会使该技能的伤害提高10%
--普通攻击暴击时，立即释放一次该技能
local W_JueQ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_JueQ_skill1_1_Model")
---@class W_JueQ_skill1_3_Model : W_JueQ_skill1_1_Model @
---@field super W_JueQ_skill1_1_Model @W_JueQ_skill1_1_Model
local M = class("W_JueQ_skill1_3_Model", W_JueQ_skill1_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isCrit = false
    self.start = true
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end


-- --技能释放
-- function M:SkillEndHandler( eventName, data )
--     local ply = data["player"]
--     local config = data["skillConfig"]
--     if ply ~= nil and ply:equal(self.player) and config ~= nil then
--         if "attack1" == config.anim_name  then
--             if self.isCrit and self.player.aiEngine ~= nil  then
--                 self.player.aiEngine.skillConfig = self.skill
--                 return "attack"
--             end
--         end
--     end
-- end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end

return M