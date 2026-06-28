-- 当灵鹫受到致命伤害时，会立即献祭一条冰犬，
-- 使自己无敌2秒，并恢复20%最大生命值的血量，每场战斗仅能触发一次

local W_LingJ_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_LingJ_skill0_1_Model")

---@class W_LingJ_skill0_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LingJ_skill0_2_Model", W_LingJ_skill0_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 无敌buf 
    self.wudiBuf  = self:getParam(3)
    -- 恢复血量 百分比
    self.restoreHp = self:getParam(4)
    self.triggerTime = 2;
    self.triggerTime = self.triggerTime;
end


function M:spawnFinish()
    M.super.spawnFinish(self)
    -- 没场比较智能触发一次 
    self.triggerTime = 2;
end


function M:dead( data )
    if self.triggerTime > 0 then
        if self.player.summonList.list.Count > 0 then
            -- 加入无敌2秒
            self.player.bufMgr:addBufById(self.wudiBuf, self.player)
            -- 恢复血量 百分比
            self.player:cure("hp", self.player, self.restoreHp)
            -- 献祭一个冰犬
            for i = 1, self.player.summonList.list.Count do
                local key = self.player.summonList.list:get(i-1)
                local plys = self.player.summonList:get(key)
                for i, v in ipairs(plys) do
                    v:destroy()
                    break;
                end
            end
            --触发完成
            self.triggerTime = self.triggerTime - 1;
        end
        return false;
    end
    return true;
end



function M:destroy()
    M.super.destroy(self)
end

return M