--锁链类子弹（前后两发子弹命中的人会连起来）(子弹必定命中)
---@class BulletLine_Mode : Bullet_Model @
---@field super Bullet_Model @Bullet_Model
local M = class("BulletLine_Mode", Battle.Bullet_Model)

--初始化子弹
function M:init( data )
    M.super.init(self, data)
    self.linePrefab = self.data["linePrefab"]
    --发射
    self.state = 1
end

--攻击玩家
function M:hitPlayer(player)
    M.super.hitPlayer(self, player)
    if player:equal(self.enemy) then
        --命中
        self.state = 2
        if self.player.bulletMgr.lineTemp == nil then
            self.player.bulletMgr.lineTemp = self
        else
            if self.player.bulletMgr.lineTemp.enemy:isLive() then
                self.otherBullet = self.player.bulletMgr.lineTemp
                self.player.bulletMgr.lineTemp.otherBullet = self
                self.player.bulletMgr.lineTemp = nil

                self.state = 3
                self:setParent()
                self.otherBullet.state = 3
                self.otherBullet:setParent()
                
                --攻击时附带的buf
                local injureBuf = string.split(self.data["lineBuffId"], ",")
                --优先加入buf
                --攻击时加入的buf
                if #injureBuf > 0 then
                    for k,v in ipairs(injureBuf) do
                        self.enemy.bufMgr:addBufById(tonumber(v), self.otherBullet.enemy)
                        self.otherBullet.enemy.bufMgr:addBufById(tonumber(v), self.enemy)
                    end
                end
                
                self:createLine()
                self.lineSource = true
                self.otherBullet.lineSource = false
            else
                self:destroy()
                self.player.bulletMgr.lineTemp:destroy()
                self.player.bulletMgr.lineTemp = nil
            end
        end
    end
end


--创建线
function M:createLine()
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelCreateLine)
end


--飞行伤害
function M:flyDamage(time)    
    self.minHitPlayer = nil;
    local players = Battle.List.new()
    players:add(self.enemy)
    self:checkHit(players, time)

    if self.minHitPlayer ~= nil or self.position.y < 0 then
        self.hitList:add(self.minHitPlayer)

        for i = 1,self.hitList.Count, 1 do
            local ply = self.hitList:get(i-1)
            if self.alreadyHitList[ply] == nil then
                self:hitPlayer(ply);
            end
        end
    end
end

function M:setParent()
    self.player.bulletMgr:removeBullet(self)
    self.enemy.bulletMgr:addBullet(self)
end

function M:update(dt,unsdt)
    if self.start then
        --生命周期内仍不能命中则销毁
        if self.state <= 1 and self.checkLiveTime > 0 then
            self.checkLiveTime = self.checkLiveTime - dt;
            if self.checkLiveTime <= 0 then
                self:destroy();
                return;
            end
        end
        
        self.dir = self:cloneDir(GlobalTools:Dir(self.enemy.position, self.position))

        if self.state == 1 then
            --真正的移动算法
            self:moveStyle(dt,unsdt)
            self:flyDamage(dt);
        else
            self.position = self:clonePos(self.enemy.position)
            if self.line ~= nil then
                if self.otherBullet.enemy:isLive() ~= true then
                    self:destroy()
                    self.otherBullet:destroy()
                    EventDispatcher:dipatchEvent("otherBulletDead",{ player = self.enemy })
                end
            end
        end
    end
end

--判断是否到边界
function M:moveStyle(dt,unsdt)
    self.position = self:clonePos(self.position + self.dir * self.speed * dt)
    self.nextPosition = self:clonePos(self.position + self.dir * self.speed * dt)
end

return M