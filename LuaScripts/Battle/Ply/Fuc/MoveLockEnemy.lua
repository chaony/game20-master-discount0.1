--技能帧
---@class MoveLockEnemy : MoveGeneral @
---@field super MoveGeneral @MoveGeneral
local M = class("MoveLockEnemy",MoveGeneral)

function M:init(move,player,data)
    M.super.init(self, move, player, data)
    self.move.speed = self.move.data["speed"]
    self.animName = self.move.data["endAnimName"]
    self.move.control = false
    self.move.curTime = 0
    local enemys = SelectTargetTool:findPlayerByType(self.move.count,self.move.player)
    self.move.target = enemys:get(0)
    if self.move.target ~= nil then
        self.move.index = 0 
        self:setPos(self.move.target.position)
        self.move.curTime = tonumber(self.move.time)
    else
        self.move.curTime = 0;
    end
end


function M:moveing( time )
    if self.move.curTime > 0 then
        self.move.curTime = self.move.curTime - time
        if self.move.curTime <= 0 then
            self.move.curTime = 0
        end
        local distance = GlobalTools:Distance(self.move.pos, self.move.player.position )
        if distance < GlobalTools:ToFix2(self.move.distance) then
            self:changeTarget()
            if self.move.target ~= nil then
                self:setPos(self.move.target.position)
            end
        else
            if self.move.target ~= nil and self.move.target:isLive() then
                local dir = GlobalTools:Dir(self.move.pos, self.move.player.position)
                local pos = self.move.player.position + dir * time * self.move.speed
                self.move.player:setPos( pos )
                self.move.player:setForward( dir)
            else
                self:changeTarget()
                if self.move.target ~= nil then
                    self:setPos(self.move.target.position)
                end
            end
        end
    else
        self.move.player.animator:changeState(self.animName)
        self.move.player.moveMgr:removeMove(self.move)
    end
end

function M:changeTarget()
    local enemys = SelectTargetTool:findPlayerByType(self.move.count,self.move.player)
    if enemys.Count > 0 then
        local enemy = enemys:get(0)
        if enemy:isLive() then
            self.move.target = enemy
        end
    end
end

function M:setPos(pos)
    if self.move.pos == nil then
        self.move.pos = FixVector3.New(0,0,0)
    end
    pos = SceneManager.curScene:getAreaPosition(pos)
    self.move.pos.x = pos.x
    self.move.pos.y = pos.y
    self.move.pos.z = pos.z
end

function M:destroy()
    self.move.finish = true
    self.move.player.moveMgr:removeMove(self.move)
end

return M