
--回旋镖子弹类
---@class BulletCircle_Model : Bullet_Model @
---@field super Bullet_Model @Bullet_Model
local M = class("BulletCircle_Model",Battle.Bullet_Model)

--初始化子弹
function M:init(data)
    M.super.init(self,data)
    self.stayTimer = 0
    --攻击后停留时间
    self.circleStayTime = self.data["circleStayTime"]
    self.backPuncture = self.data["backPuncture"] == "True"
    --子弹返回时的伤害
    self.backdamagePercent = tonumber(self.data["backdamagePercent"] or 0)
    --检测范围
    --self.checkRange = GlobalTools.base1;
end

function M:shoot()
    M.super.shoot(self)
    self.isBack = false
    if self.player ~= nil then
        if self.isForward  then
            self.dir.y = 0
            self.dir.z = 0
        end
    end
end


--判断是否到边界
function M:moveStyle(dt,unsdt)
    if self.stayTimer > 0 then
        self.stayTimer = self.stayTimer - dt
    else
        if SceneManager:getCurSceneModel():isInArea(self.position) == false then
            self:back()
        end
        M.super.moveStyle(self,dt,unsdt)
    end
end

function M:flyDamage(time)
    local players = self:getPlayers(self.data["count"]["camp"])
    if self.isBack == true then
        players:add(self.player)
    end
    self.minHitPlayer = nil;
    if self.data["count"]["isFixPoint"] ~= "True" then
        self:checkHit(players, time)
    end
    self.hitList:clear()
    if self.minHitPlayer ~= nil or self.position.y < 0 then
        if self.minHitPlayer ~= self.player then
            if self.delayBoomTime <= 0 then
                self:injure(players)
            else
                self:playDelayBoomEffect()
                self.delayBoomTask = TimeTools:delayTime(self.delayBoomTime, function()
                    self:clearDelayBoomEffect()
                    self:injure(players)
                    self.delayBoomTask = nil
                end)
            end
        end

        if  self.isBack == true then
            if self.minHitPlayer == self.player  then
                self:destroy()
            end
        else
            if self.position ~= nil then
                if self.minHitPlayer == self.enemy or self.position.y < 0 then
                    self:back()
                end
            end
        end
        self.minHitPlayer = nil
    end
end

function M:checkDead()
    --是否是穿刺攻击
    if self.isBack == true then
        if self.minHitPlayer == self.player then
            self:destroy()
        end
    end
end


function M:back()
    self:cloneDir(GlobalTools:Dir(self.player.position, self.position))
    self:setForward(self.dir, true)
    self.isBack = true
    self.stayTimer = self.circleStayTime
    self.isPuncture = self.backPuncture
    self:playHitEffect()

    self.checkRange = GlobalTools.base1;

    if self.backdamagePercent ~= nil then
        if self.backdamagePercent > 0 then
            self.frontDamage = self.backdamagePercent
        end
    end
end

return M