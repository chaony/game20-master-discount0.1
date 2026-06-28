
---@class W_QiX_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiX_skill0_Model", SkillFeatures_Model)

local table_data = require("Battle.Ply.SkillFeaturesData.W_QiX_skill0_Data")
M.bulletData = table_data.bulletData;
M.bulletEffectData = table_data.bulletEffectData;

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
end

function M:skillDispatch(data)
    if data.eventName == "attack1_shoot" then
        self.player.evtMgr:commonEventWork("Shoot", 1)
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "attack1" then
        if victim ~= nil and victim:get_camp() == self.player:get_camp() then
            victim.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M