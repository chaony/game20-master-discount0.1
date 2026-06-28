--狼王在攻击被施加了狩猎印记的敌人时，会额外附加敌方最大生命值5%的伤害（对首领单位无效）
local W_WanS_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_WanS_skill2_1_Model")
---@class W_WanS_skill2_2_Model : W_WanS_skill2_1_Model @
---@field super W_WanS_skill2_1_Model @W_WanS_skill2_1_Model
local M = class("W_WanS_skill2_2_Model", W_WanS_skill2_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.dmg = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
end

--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    M.super.killerAfterAttack(self, data)
    local ply = data["killer"]
    local victim = data["victim"]
    if ply ~= nil and self.player:equal(ply.master) then
        if victim ~= nil and victim:isLive() and victim.isBoss ~= true then
            local marks = victim.bufMgr:findBufByTag("W_WanS_skill1")
            if #marks > 0 then
                data.damage = data.damage + GlobalTools:Mul(data.damage, self.dmg)
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M