
--复苏之佑 释放必杀技的时候获得持续五秒的护盾，最多抵消120%攻击力的伤害
---@class Artifact1_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact1_0", Artifact)

--承受伤害量
M.counteractAtk = nil
--护盾buf
M.shileBuffid = 0
--buff参数
M.bufData = nil
--初始化
function M:init(player,data)
    M.super.init(self, player, data)
    self.shileBuffid = self:getValue(1)
    -- self.counteractAtk = self:getValue(2)
    -- self.time = self:getValue(1)
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
end

--开始
function M:gameStart()
    M.super.gameStart(self)
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]

    if ply:equal(self.player) and config ~= nil  then
        if config.anim_name == "skill3" then
        	self:addSkillBuf()
        end
    end
end

function M:addSkillBuf()
    local buff = self.player.bufMgr:findBufById(self.shileBuffid)
    if table.nums(buff) <= 0 then
        self.player.bufMgr:addBufById(self.shileBuffid, self.player)
    end
    
end
--结束
function M:gameover()
   M.super.gameover(self)
   EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:destroy()
 	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M