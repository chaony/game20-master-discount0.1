---@class W_XingY_attack1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_XingY_attack1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    self:addEventListener_Local(Battle.SkillEventType.MV_W_XingY_attack1_Model_ClearEffect,{self,self.MV_W_XingY_attack1_Model_ClearEffect})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_XingY_attack1_Model_ClearStateEffect,{self,self.MV_W_XingY_attack1_Model_ClearStateEffect})
end

--清理特效
function M:MV_W_XingY_attack1_Model_ClearStateEffect(eventName, data)
    local stateName = data.name;
    local objName = "W_XingY_"..stateName:gsub("^%l", string.upper).."_Buff_001"
    self:findObject(objName, false)
end

--清理特效
function M:MV_W_XingY_attack1_Model_ClearEffect(eventName, data)
    self:clearEffect();
end


function M:findObject(name, show)
    if IsNull(self.player.tranformHelper) == false then
        local obj = self.player.tranformHelper:FindObj(self.player.tran, name)
        if obj ~= nil then
            obj.gameObject:SetActive(show)
        end
    end
end

function M:clearEffect()
    if self.player.tran ~= nil then
        for i = 0, 3 do
            local objName = "W_XingY_Skill"..i.."_Buff_001"
            self:findObject(objName, false)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    self:clearEffect();
end

return M