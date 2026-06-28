--衡山对内功型角色造成的伤害提升20%
---@class W_HShan_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HShan_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(1)
end

function M:spawn()
	 M.super.spawn(self)
    self.player.bufMgr:addBufById(self.magicdamageBuffId, self.player)
    self.player.bufMgr:addBufById(self.resBuffId, self.player)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]

    if killer ~= nil and killer:equal(self.player) then
        if victim ~= nil then
            if victim.plyData.type == 3 then
                local damage_add = GlobalTools:Mul(data.damage, self.dmg)
            	data.damage = data.damage + damage_add
            end
        end
    end
end


function M:destroy()
	M.super.destroy(self)
end

return M