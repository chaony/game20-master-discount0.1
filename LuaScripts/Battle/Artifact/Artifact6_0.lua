
--威仪之戒 战斗中附近没有敌方单位时，增加5%攻击力


---@class Artifact6_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact6_0", Artifact)


M.atk = nil
M.distance = nil

M.someOne = nil

M.inside = true

M.time = nil

M.curTime = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.atk =  self:getValue(2)
    self.distance = self:getValue(1)
    self.time = 0
end

function M:gameStart()
    M.super.gameStart(self)
    self.curTime = self.time
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)    
    if  self.player ~= nil  then
        if self.player.data:isLive() then
            local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
            for i = enemys.Count, 1, -1 do
                local enemy_player = enemys:get(i-1)
                local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
                if distance > GlobalTools:ToFix2( self.distance ) then
                    self.someOne = true
                else
                    self.someOne = false
                    break
                end
            end

            self:changeData()
            
            if self.time > 0 and self.curTime > 0 then
            	self.curTime = self.curTime - dt
            	if self.curTime <= 0 then
            		self:operationEnemy()
            		self.curTime = self.time
            	end
            end
        end
    end
end

function M:changeData()
    if self.someOne ~= nil  then
        if self.someOne == true  then
            if self.inside == true  then
                self.player.data.atk:addToMulList(self.atk) 
                self.inside = false
            end
        else
            if self.inside == false  then
                self.player.data.atk:removeFromMulList(self.atk)
                self.inside = true
            end
                
        end
    end
end

function M:operationEnemy()
    
end

return M