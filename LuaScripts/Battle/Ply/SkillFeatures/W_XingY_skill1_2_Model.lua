-- 等级2：被施加了流血效果的敌人在攻击形意时，造成的伤害减少30%

local W_XingY_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_XingY_skill1_1_Model")

---@class W_XingY_skill1_2_Model : W_XingY_skill1_1_Model
local M = class("W_XingY_skill1_2_Model", W_XingY_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.reduce_injure_percent = self:getParam(2)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    M.super.injureHandler(self, eventName, data)

    if self.player:equal(data.victim) then -- 自己受到攻击
        if data.attackData.skillConfig ~= nil then
            local damage = data.wantdata.damage
            if damage > 0 then
                if(data.killer.bufMgr:hasBufByTag("liuxue"))then    -- 流血的敌人对自己造成的伤害减少
                    local reduce_value = GlobalTools:Mul(damage, self.reduce_injure_percent);
                    data.wantdata.damage = damage - reduce_value
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M