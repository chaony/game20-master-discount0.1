--骑射状态下，暴击率提升30%，非骑射状态下，攻击力提升30%

---@class W_QiLP_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_QiLP_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.rideBuff = self:getParam(1)   --骑射状态下，暴击率提升30%
    self.unRideBuff = self:getParam(2)   --非骑射状态下，攻击力提升30%
    self.initBuff = false
    self.qiChengState = false
end

function M:gameStart()
    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil and attack1.cur_skill_config then
        self.attack1 = attack1.cur_skill_config.feature
    end
end

function M:update( time )
    if self.attack1 ~=  nil and self.player ~= nil and self.player:isLive() then
        if not self.initBuff or self.qiChengState ~= self.attack1:getPlayerState() then
            self.initBuff = true
            self.qiChengState = self.attack1:getPlayerState()
            if self.qiChengState then
                self.player.bufMgr:removeBufById(self.unRideBuff, true,false)
                self.player.bufMgr:addBufById(self.rideBuff, self.player)
            else
                self.player.bufMgr:removeBufById(self.rideBuff, true,false)
                self.player.bufMgr:addBufById(self.unRideBuff, self.player)
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M;