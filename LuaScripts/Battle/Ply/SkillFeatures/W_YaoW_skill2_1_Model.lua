--战斗中，每隔10秒，药王会为自己生成一个护盾,护盾状态下若受到攻击，会免疫该次伤害并使攻击者禁锢2秒
---@class W_YaoW_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YaoW_skill2_1_Model", SkillFeatures_Model)

M.cureRate = nil

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.cd = self:getParam(1)
    --护盾buff
    self.buff1 = self:getParam(2)
    --禁锢buff
    self.buff2 = self:getParam(3)
    
    self.timer = 0
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.timer = self.cd
end

function M:update(dt)
    M.super.update(self, dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.timer = self.cd
            self.player.bufMgr:addBufById(self.buff1, self.player)
        end
    end
end

--攻击结束处理
function M:afterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if victim ~= nil and victim:equal(self.player) then
        local buff = self.player.bufMgr:findBufById(self.buff1)
        if #buff > 0 then
            killer.bufMgr:addBufById(self.buff2, self.player)
            self.player.bufMgr:removeBufById(self.buff1, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M