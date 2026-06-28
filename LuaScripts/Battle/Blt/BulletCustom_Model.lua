
--自定义轨迹子弹类
---@class BulletCustom_Model : Bullet_Model @
---@field super Bullet_Model @Bullet_Model
local M = class("BulletCustom_Model",Battle.Bullet_Model)

--初始化子弹
function M:init(data)
    M.super.init(self,data)
end

--发射
function M:shoot()
    if self.player ~= nil then
        local curve = self.ata["movePath"]
        self.curveTime = curve.curveMoveTime
        self.curveX = GlobalTools:GetCurve(curve["curveMoveType"],false)
        self.curveY = GlobalTools:GetCurve(curve["curveMoveType"],true)
        
        local pos = self.target:Clone()
        if self.data["shootFixPoint"] ~= true then
            pos.y = pos.y + GlobalTools.base1
        end
        
        local dir = GlobalTools:Dir(pos,self.position);
        local offset = self.data["targetOffset"]
        if offset ~= nil then
            local dir_offset = dir * offset.z
            local up_offset =  FixVector3.up() * offset.y;
            pos = pos + dir_offset + up_offset
        end
        -- 目标和我的距离
        self.moveDis = GlobalTools:DistanceOne(pos, self.position)
        --当前的时间
        self.curveTime = GlobalTools:Mul( self.moveDis, self.speed)
        --子弹方向
        self:setForward( dir );
        self.moveDir = FixVector3.New(0,0,0);

        self.moveDir.x = self.dir.x
        self.moveDir.y = self.dir.y
        self.moveDir.z = self.dir.z
        
        if self.isForward  then
            self.dir.y = 0
            self.dir.z = 0
        end
       
        --清除子弹
        self:clear();
        self.start = true;
        --检测生命周期
        self.curveTimer = self.curveTime
        if self.lifeTime > 0 then
            self.checkLiveTime = self.lifeTime
        else
            self.checkLiveTime = self.curveTime
        end

        self.startPosition = FixVector3.New(0, 0, 0)
        self.startPosition.x = self.position.x
        self.startPosition.y = self.position.y
        self.startPosition.z = self.position.z
    end
end


--判断是否到边界
function M:moveStyle(dt,unsdt)
    if self.curveTimer > 0 then
        
        self.curveTimer = self.curveTimer - dt
        if self.curveTimer <= 0 then
            self.curveTimer = 0
        end
        
        local pos = self:curveMove(self.curveTimer)
        self:setPos( pos )
        
        local nextTime = self.curveTimer - dt
        if nextTime <= 0 then
            nextTime = 0
        end
        local nextPos = self:curveMove( nextTime )
        self:setNextPos(nextPos)
        self:setForward( GlobalTools:Dir(nextPos, pos) )
    end
end

function M:curveMove(time)
    local progress = GlobalTools.base1 - GlobalTools:Div( time, self.curveTime );
    local progress_curve_x = GlobalTools.base10_5;
    if self.curveX ~= nil then
        progress_curve_x = self.curveX:Evaluate(progress);
    end
    local pos = self.startPosition + self.moveDir * progress_curve_x * self.moveDis

    local progress_curve_y = GlobalTools.base10_5;
    if self.curveY ~= nil then
        progress_curve_y = self.curveY:Evaluate(progress);
    end
    pos.y = progress_curve_y
    return pos
end

return M