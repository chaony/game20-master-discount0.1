
--弹射子弹类
---@class BulletTrack_Model : Bullet_Model @
---@field super Bullet_Model @Bullet_Model
local M = class("BulletTrack_Model",Battle.Bullet_Model)

M.targetPlayer = nil

--初始化子弹
function M:init( data )
    M.super.init(self, data)
    --弹射顺序
    self.TrackParam = self.data["TrackParam"]
    self.trackCount = 0
    --弹射次数
    if self.TrackParam == "not" or self.TrackParam == nil then
        --弹射次数
        self.trackCount = self.data["trackCount"] or 0
    elseif self.TrackParam == "random" then
        --弹射次数
        self.trackCount = self.data["trackCount"] or 0
    elseif self.TrackParam == "order" then  -- 顺序 (以第一次命中时检测目标数量为弹射次数）
    end
    
    self.trackLogList = {}
end

--发射
function M:shoot()
    self.targetPlayer = self.enemy
    M.super.shoot(self)
end

--判断是否到边界
function M:moveStyle(dt,unsdt)
    if self.targetPlayer ~= nil and self.targetPlayer:isLive() then
        M.super.moveStyle(self, dt,unsdt)
    else
        self:destroy()
    end
end

--检测命中w
function M:checkHit(players, time)
    --M.super.checkHit(self, players, time)
    self:checkHitCurrentTarget(time)
    
    if self.minHitPlayer ~= nil then
        -- 已经命中了此目标，弹射向下一个目标
        --if self.alreadyHitList[self.minHitPlayer] == nil then
            local plys = self:getPlayers(self.data["count"]["camp"])
            plys:remove(self.minHitPlayer) -- 不会选择当前目标
            self:findNextTrackTarget(plys)
        --else
        --    self.minHitPlayer = nil
        --end
    end
end

---选择下一个弹射目标
function M:findNextTrackTarget(plys)
    if plys.Count > 0 then
        self.targetPlayer = self:selectCurTarget(plys)    --选择下一个目标
        if self.targetPlayer:get_playerInstanceId() then
            self.trackLogList[self.targetPlayer:get_playerInstanceId()] = true
        end
        if self.targetPlayer ~= nil then
            local dir = GlobalTools:Dir(self.targetPlayer.position, self:get_position())
            self:setForward( dir, true )
            --if self.luaViewHelper ~= nil then
            --    self.luaViewHelper:SetStartTransform(self.position:toVector3(),self.dir:toVector3() );
            --end
            self.alreadyHitList[self.targetPlayer] = nil
        end
    else
        self.targetPlayer = nil
    end
end

function M:update(dt)
    if self.bulletState == 1 then
        -- 追踪目标
        if self.targetPlayer then
            if not self.targetPlayer:isLive() then  -- 目标死亡，重新选择目标
                self:checkDead()
                if self.bulletState == 1 then   -- 子弹仍然存在，弹射下一目标
                    local plys = self:getPlayers(self.data["count"]["camp"])
                    plys:remove(self.targetPlayer)
                    self:findNextTrackTarget(plys)
                end
            else
                -- 追踪存活目标
                local dir = GlobalTools:Dir(self.targetPlayer.position, self:get_position())
                self:setForward( dir, true )
            end
        end
    end
    
    M.super.update(self, dt)
end

-- 检查命中当前选定目标（只检测选中目标)
function M:checkHitCurrentTarget(time)
    local ply = self.targetPlayer
    if ply and self.dir ~= nil then
        --Logger.logError(" self.injurePrefabName dir = nil "..self.injurePrefabName )
        --敌人位置
        local  pos = ply.position + self.dir * GlobalTools.base0_2;
        --子弹当前的位置
        local mPos = self.position
        --子弹上一个位置
        local  mNextPos = self.nextPosition
        --向量差值
        local distance = GlobalTools:Distance( mPos,pos );
        local speedTime = GlobalTools:Mul(self.speed, time);
        local radius = speedTime + ply.data.triggerRadius + self.checkRange
        if radius < ply.data.triggerRadius then
            radius = ply.data.triggerRadius
        end

        -- 命中目标
        if distance < GlobalTools:ToFix2(radius) then
            self.minHitPlayer = ply;
            if self.player:equal(self.minHitPlayer) then
                self.canHitSelf = true  -- 可以弹射自己
            end
        end
    end
end

---@param targets Battle_List
---@return PlayerModel
function M:selectCurTarget(targets)
    if targets.Count == 1 then  -- 只有一个目标 不需要选择
        return targets:get(0)
    else
        if self.TrackParam == "random" then -- 未命中目标优先
            if (next(self.trackLogList) ~= nil) then
                local notHitList = Battle.List.new();
                targets:safeWalkInverted(function(target)
                    local playerInstanceId = target:get_playerInstanceId() or ""
                    if not self.trackLogList[playerInstanceId] then
                        notHitList:add(target)
                    end                    
                end)
                if notHitList.Count > 0 then
                    targets = notHitList
                end
            end
        end
    end

    -- 返回一个随机目标
    local index = WRandom:randomNum(1, targets.Count + 1, true)
    return targets:get(index - 1)
end

--- 设置弹射次数
function M:setTrackCount(cnt)
    self.trackCount = cnt
end

function M:checkDead()
    M.super.checkDead(self)
    if self.trackCount == nil then
        self.trackCount = 0
    else
        self.trackCount = self.trackCount - GlobalTools.base1;
    end
    if self.trackCount <= 0 then
        self:destroy()
    end
    if self.targetPlayer == nil then
        self:destroy()
    end
end


return M
