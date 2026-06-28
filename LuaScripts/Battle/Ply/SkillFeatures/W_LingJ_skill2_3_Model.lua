-- 3等级 己方所有队友会获得该技能攻速提升效果的一半
-- 4等级 己方所有队友也会获得相同的攻速提升效果

---@class W_LingJ_skill2_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local W_LingJ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_LingJ_skill2_1_Model");
local M = class("W_LingJ_skill2_3_Model", W_LingJ_skill2_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 给己方阴系队友增加攻速效果 百分比 
    self.yingSpeedRate = self:getParam(4)
end


-- 给灵鹫和我方召唤物都加攻击速度
function M:addSpeedToPlayers( value, remove )
    M.super.addSpeedToPlayers(self, value, remove)
    -- 队友中找到阴系队友 
    local friends = self.player.plyMgr:getPlayers(self.player.camp)
    for i = 1, friends.Count do
        local player = friends:get(i-1)
        if player.master == nil and player:equal(self.player) == false then
            if remove == nil then
                player.data.haste:addToAddList( GlobalTools:Mul(value, self.yingSpeedRate) )
            else
                player.data.haste:removeFromAddList( GlobalTools:Mul(value, self.yingSpeedRate) )
            end
        end
    end
end


return M