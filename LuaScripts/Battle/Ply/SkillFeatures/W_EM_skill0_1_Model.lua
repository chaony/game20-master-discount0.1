--"战斗中，自身受到的内功伤害减少15%，对内功型敌人的伤害增加15%	"
---@class W_EM_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_EM_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.res = self:getParam(1)
    self.magicdamage = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    --内伤减伤
    self.player.data.res:addToMulList(self.res)
end

--伤害计算完
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local victim = data["victim"]
    if killer ~= nil and killer:equal(self.player) then
        if victim.plyData.type == 3  then
            data["damage"] = dmg + GlobalTools:Mul(dmg, self.magicdamage)
        end
    end
end


function M:destroy()
    self.count = 0
    M.super.destroy(self)
end

return M