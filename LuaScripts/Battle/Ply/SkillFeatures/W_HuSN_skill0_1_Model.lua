--战斗开始时，扈三娘会标记与自己位置相对的敌人，并立即降低其20%的最大防御力和最大血量，提升自身20%的最大防御和最大血量。
---@class W_HuSN_skill0_1_Model : SkillFeatures_Model
---@field super SkillFeatures_Model
local M = class("W_HuSN_skill0_1_Model", SkillFeatures_Model)
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bufData = self:getParam(1) -- 开场给自己加的buff
    self.bufData2 = self:getParam(2) -- 给敌方加的buff
end

function M:spawn()
    local enemys = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "enemy",
        posIndex = "oppositeTarget",
        ignoreSummon = true,
    })
    local enemys2 = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "enemy",
        posIndex = "oppositeTarget",
        ignoreSummon = true,
        priority = true,
    })
    self.player.bufMgr:addBufById(self.bufData, self.player) -- 加buff
    if enemys.Count > 0 then
        local enemy = enemys:get(0)
        enemy.bufMgr:addBufById(self.bufData2, self.player) -- 加buff
    elseif enemys2.Count > 0 then
        local enemy = enemys2:get(0)
        enemy.bufMgr:addBufById(self.bufData2, self.player) -- 加buff
    end
    M.super.spawn(self)
end


function M:destroy()
    M.super.destroy(self)
end

return M