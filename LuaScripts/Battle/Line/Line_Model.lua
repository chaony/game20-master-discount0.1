---@class Line_Model : ModelBase @
---@field super ModelBase @ModelBase
---@field player PlayerModel
---@field target PlayerModel
---@field lineStartPlayer PlayerModel
local M = class("Line_Model",Battle.ModelBase)

--lineStartPlayer 连线开始的人物
function M:init( data, player, lineStartPlayer, target)
    --连线的发出者
    self.player = player
    --数据
    self.data = data
    --连接时伤害
    self.damageStart = data["damageStart"]
    --持续伤害
    self.damage = data["damage"]
    --持续伤害间隔
    self.damageInterval = data["damageInterval"]
    self.imprison = data["imprison"] == true
    self.forceHookMove = data["forceHookMove"] == true
    --起始点
    local origin = data["origin"]
    self.origin = FixVector3.New(0,0,0);
    self.origin.x = origin["x"]
    self.origin.y = origin["y"]
    self.origin.z = origin["z"]
    
    --结束点
    local destination = data["destination"]
    self.destination = FixVector3.New(0,0,0);
    self.destination.x = destination["x"]
    self.destination.y = destination["y"]
    self.destination.z = destination["z"]
    
    --己方移动基准点
    self.selfBasePos = data["selfBasePos"]
    --己方位移
    self.selfMove = data["selfDistance"]
    --敌方移动基准点
    self.enemyBasePos = data["enemyBasePos"]
    --敌方位移
    self.enemyMove = data["enemyDistance"]
    --开火速度
    self.fireTime = data["fireTime"]
    --自身等待时间
    self.selfWaitTime = data["selfWaitTime"]
    --敌人等待时间
    self.enemyWaitTime = data["enemyWaitTime"]
    --完成等待时间
    self.finishWaitTime = data["finishWaitTime"]
    --自己移动时间
    self.selfMoveTimer = data["selfMoveTimer"]
    --敌人移动时间
    self.enemyMoveTimer = data["enemyMoveTimer"]
    --曲线数据
    if data["selfCurve"] ~= "nil" then
        self.selfCurve = GlobalTools:GetCurve(data["selfCurve"], true)
    end
    if data["enemyCurve"] ~= "nil" then
        self.enemyCurve = GlobalTools:GetCurve(data["enemyCurve"], true)
    end
    
    self.buffId = data["bufid"]
    --时间
    self.selfCurMoveTimer = 0
    self.enemyCurMoveSpeed = 0
    self.curFireTime = 0
    --位置
    self.sourcePosition = FixVector3.New(0,0,0);
    self.endPosition = FixVector3.New(0,0,0);
    
    --临时存储位置
    self.tempPos = FixVector3.New(0,0,0);
    --临时存储位置
    self.tempMovePos = FixVector3.New(0,0,0);
    --同步位置参数
    self.syncPosParam = {}
    --同步update函数参数
    self.syncUpdateParam = {}

    self.enemyCurMoveTimer = 0;

    --我连线的起始者
    self.lineStartPlayer = self.player
    if lineStartPlayer ~= nil then
        self.lineStartPlayer = lineStartPlayer;
    end
    --连接目标
    if target then
        self.target = target
    else
        local enemy= SelectTargetTool:findPlayerByType(self.data["count"], self.lineStartPlayer)
        if enemy ~= nil and enemy:get(0) ~= nil then
            self.target = enemy:get(0)
        end
    end
    
    self.state = 1
    --发送线的数据创建完毕
    self.lineStartPlayer:dispatchEvent_Local(Battle.EventType.MV_LineModelCreateFinish, self);
    EventDispatcher:dipatchEvent("addLine", {line = self})
    --视图和数据绑定完毕
    self:bandinViewModelFinish()
end

--设定目标
function M:set_target(target) 
    self.target = target;
end


function M:bandinViewModelFinish()
    if self.target == nil then
        self:destroy()
    end
end

--修改结束点
function M:get_destination()
   return self.destination;  
end

--修改起始点
function M:get_origin()
    return self.origin;
end

--获取目标
function M:get_target()
    return self.target;
end

--获取人物
function M:get_player()
    return self.player
end

--lineModel数据
function M:get_data()
    return self.data;
end

function M:setCurEndPos(pos)
    if self.curEndPos == nil then
        self.curEndPos = FixVector3.New(0,0,0);
    end
    self.curEndPos.x = pos.x;
    self.curEndPos.y = pos.y;
    self.curEndPos.z = pos.z;

    self.syncPosParam.type = 1;
    self.syncPosParam.pos = self.curEndPos;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end


function M:setStartMovePos(pos)
    if self.selfStartMovePos == nil then
        self.selfStartMovePos = FixVector3.New(0,0,0);
    end
    self.selfStartMovePos.x = pos.x;
    self.selfStartMovePos.y = pos.y;
    self.selfStartMovePos.z = pos.z;

    self.syncPosParam.type = 2;
    self.syncPosParam.pos = self.selfStartMovePos;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end


function M:setMovePos(pos)
    if self.selfMovePos == nil then
        self.selfMovePos = FixVector3.New(0,0,0);
    end
    self.selfMovePos.x = pos.x;
    self.selfMovePos.y = pos.y;
    self.selfMovePos.z = pos.z;

    self.syncPosParam.type = 3;
    self.syncPosParam.pos = self.selfMovePos;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end

function M:setEnemyStartMovePos(pos)
    if self.enemyStartMovePos == nil then
        self.enemyStartMovePos = FixVector3.New(0,0,0);
    end
    self.enemyStartMovePos.x = pos.x;
    self.enemyStartMovePos.y = pos.y;
    self.enemyStartMovePos.z = pos.z;
    
    self.syncPosParam.type = 4;
    self.syncPosParam.pos = self.enemyStartMovePos;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end


function M:setEnemyMovePos(pos)
    if self.enemyMovePos == nil then
        self.enemyMovePos = FixVector3.New(0,0,0);
    end
    self.enemyMovePos.x = pos.x;
    self.enemyMovePos.y = pos.y;
    self.enemyMovePos.z = pos.z;

    self.syncPosParam.type = 5;
    self.syncPosParam.pos = self.enemyMovePos;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end


function M:setSourcePosition(pos)
    if self.sourcePosition == nil then
        self.sourcePosition = FixVector3.New(0,0,0);
    end
    self.sourcePosition.x = pos.x;
    self.sourcePosition.y = pos.y;
    self.sourcePosition.z = pos.z;

    self.syncPosParam.type = 6;
    self.syncPosParam.pos = self.sourcePosition;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end


function M:setEndPosition(pos)
    if self.endPosition == nil then
        self.endPosition = FixVector3.New(0,0,0);
    end
    self.endPosition.x = pos.x;
    self.endPosition.y = pos.y;
    self.endPosition.z = pos.z;

    self.syncPosParam.type = 7;
    self.syncPosParam.pos = self.endPosition;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncPosition, self.syncPosParam)
end



function M:updateSourceTran()
    --更新线的Fix位置，将 Transform 位置装换到Fix位置
    local source_pos = self:getSourcePos();
    self:setSourcePosition(source_pos);
    
    local end_pos = self:getEndPos()
    self:setEndPosition(end_pos)
end


--获取根位置
function M:getSourcePos()
    return self.lineStartPlayer.position + self.origin;
end

--获取结束位置
function M:getEndPos()
    return self.target.position + self.destination;
end


function M:update(dt)
    --连线目标
    if self.target == nil or self.target == "" or self.target:isLive() == false then
        self:destroy()
        return
    end
    local time = dt

    self:updateSourceTran();
    
    if self.state == 1 then
        self.curFireTime = self.curFireTime + time;
        if self.curFireTime > self.fireTime then
            self.curFireTime = self.fireTime;
            self:fireEnd()
            self:moveStart()
        end
        local progress = GlobalTools:Div(self.curFireTime, self.fireTime)
        GlobalTools:Lerp( self.tempPos, self.sourcePosition, self.endPosition, progress )
        self:setCurEndPos( self.tempPos );
    elseif self.state == 3 then
        self.curWaitTime = self.curWaitTime + time

        local selfMoveFinish = false
        local enemyMoveFinish = false

        if self.curWaitTime > self.selfWaitTime then
            self.selfCurMoveTimer = self.selfCurMoveTimer + time
            local progress = GlobalTools.base1
            if self.selfMoveTimer > 0 then
                progress = GlobalTools:Div( self.selfCurMoveTimer, self.selfMoveTimer )
            end
            --move(player, startPos, target, speed, dt, curve, progress)
            selfMoveFinish = self:move(self.lineStartPlayer, self.selfStartMovePos, self.selfMovePos, self.selfMoveSpeed, time, self.selfCurve, progress)
        end

        if self.curWaitTime > self.enemyWaitTime then
            self.enemyCurMoveTimer = self.enemyCurMoveTimer + time
            local progress = GlobalTools.base1
            if  self.enemyMoveTimer > 0 then
                progress = GlobalTools:Div( self.enemyCurMoveTimer, self.enemyMoveTimer )
            end
            --move(player, startPos, target, speed, dt, curve, progress)
            enemyMoveFinish = self:move(self.target, self.enemyStartMovePos, self.enemyMovePos, self.enemyMoveSpeed, time, self.enemyCurve, progress)
        end

        if selfMoveFinish and enemyMoveFinish then
            self:moveEnd()
        end
        
        --检测持续伤害
        self:checkLastDamage(time)
        --设定结束位置
        self:setCurEndPos( self.endPosition )

    elseif self.state == 4 then
        self.curFinishWaitTime = self.curFinishWaitTime - time
        --检测持续伤害
        self:checkLastDamage(time)
        self:setCurEndPos( self.endPosition )
        if self.curFinishWaitTime < 0 then
            self:finish()
        end
    end

    self.syncUpdateParam.time = dt;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelSyncUpdate, self.syncUpdateParam)
end


--攻击结束
function M:fireEnd()
    self:setCurEndPos( self.endPosition )
    self.state = 2
    self.curWaitTime = 0
    if self.imprison and self:checkCanMove(self.target) then
        self.target.aiEngine:changeState("debuff")
    end
    if self.damageStart > 0 then
        local attackData = BattleTool:getBaseAttackData()
        attackData["damage"] = GlobalTools:Mul(self.damageStart, self.lineStartPlayer.data.atk:getValue())
        attackData["player"] = self.lineStartPlayer
        attackData["type"] = 0
        attackData["injureBuf"] = 0
        attackData["damageType"] = 0
        self.target:injure(attackData)
    end
    self.curDamageTime = self.damageInterval
end


--开始移动
function M:moveStart()
    self.state = 3
    local dir_normal = GlobalTools:Dir(self.target.position,self.lineStartPlayer.position)
    local dir = self.target.position - self.lineStartPlayer.position
    dir.y = GlobalTools.base0
    
    local selfBase = self.lineStartPlayer.position + dir * self.selfBasePos
    self:setStartMovePos( self.lineStartPlayer.position );
    local dis = dir:Magnitude()
    --计算自己移动距离
    local base_dis = GlobalTools:Mul(dis, self.selfBasePos)
    if base_dis > self.selfMove then
        self:setMovePos( selfBase - dir_normal * self.selfMove )
    else
        self:setMovePos( self.lineStartPlayer.position )
    end
    --根据时间计算速度
    if self.selfMoveTimer ~= 0 then
        local dis = GlobalTools:DistanceOne(self.selfStartMovePos, self.selfMovePos)
        self.selfMoveSpeed = GlobalTools:Div( dis , self.selfMoveTimer )
        self.selfMoveSpeed = self.selfMoveSpeed;
    end
    --计算地方移动距离
    local enemyBase = self.lineStartPlayer.position + dir * self.enemyBasePos
    self:setEnemyStartMovePos( self.target.position )

    local enemy_base_dis = GlobalTools:Mul(dis, (GlobalTools.base1 - self.enemyBasePos))
    if enemy_base_dis > self.enemyMove then
        self:setEnemyMovePos( enemyBase + dir_normal * self.enemyMove )
    else
        self:setEnemyMovePos( self.target.position )
    end
    --根据时间计算速度
    if self.enemyMoveTimer ~= 0 then
        local dis = GlobalTools:DistanceOne(self.enemyStartMovePos, self.enemyMovePos)
        self.enemyMoveSpeed = GlobalTools:Div( dis , self.enemyMoveTimer )
        self.enemyMoveSpeed = self.enemyMoveSpeed;
        if self.target ~= nil then
            self.target.moveMgr:clear()
            self.target.moveMgr.canMove = false
        end
    end
end

--移动结束加buf
function M:moveEnd()
    self.state = 4
    self.curFinishWaitTime = self.finishWaitTime
    
    if self.buffId ~= nil and self.buffId ~= "nil" then
        --攻击时附带的buf
        local injureBuf = string.split(self.buffId, ",")
        --优先加入buf
        --攻击时加入的buf
        if #injureBuf > 0 then
            for k,v in ipairs(injureBuf) do
                self.target.bufMgr:addBufById(tonumber(v), self.lineStartPlayer);
            end
        end
    end
    if self.target ~= nil then
        self.target.moveMgr.canMove = true
    end
end

--彻底完成
function M:finish()
    self.state = 5
    local buffs = self.target.bufMgr:findBufByType("Imprison")
    if self.imprison and self:checkCanMove(self.target) and table.nums(buffs) <= 0 then
        self.target.aiEngine:changeState("move")
    end
    self.target:lockEnemy(nil)
    self:destroy()
end


--移动
function M:move(player, startPos, target, speed, dt, curve, progress)
    if self:checkCanMove(player) then
        local y = 0
        if curve ~= nil then
            progress = GlobalTools:Clamp01(progress)
            local curve_value = curve:Evaluate(progress)
            y = curve_value
        end

        if progress < GlobalTools.base1 then
            GlobalTools:Lerp(self.tempMovePos, startPos, target , progress);
            self.tempMovePos.y = target.y + y;
            player:setPos(self.tempMovePos)
            return false
        else
            player:setPos(target)
            return true
        end
    else
        return true
    end
end

--持续伤害
function M:checkLastDamage(dt)
    if self.damage > 0 then
        self.curDamageTime = self.curDamageTime - dt
        if self.curDamageTime < 0 then
            self.curDamageTime = self.damageInterval
            local attackData = BattleTool:getBaseAttackData()
            attackData["damage"] = GlobalTools:Mul(self.damageInterval, self.lineStartPlayer.data:get_atk())
            attackData["player"] = self.lineStartPlayer
            attackData["type"] = 0
            attackData["injureBuf"] = 0
            self.target:injure(attackData)
        end
    end
end

--检测移动
function M:checkCanMove(player)
    if player:isLive() == false then
        return false
    end
    if self.forceHookMove then
        return true
    end
    local buffs = player.bufMgr:findBufByType("Immunity")
    for k, v in ipairs(buffs) do
        if v.bufWork:checkTag("control", self.player) == true then
            return false
        end
    end
    return true
end


--销毁连线
function M:destroy()
    self.state = 6
    self.lineStartPlayer.lineMgr:removeLine(self)
    self.enemyStartMovePos = nil;
    self.enemyMovePos = nil;
    self.curEndPos = nil;
    self.sourcePosition = nil;
    self.endPosition = nil;
    self.selfStartMovePos = nil;
    self.selfMovePos = nil;
    self:dispatchEvent_Local(Battle.EventType.MV_LineModelDestroy)
end

return M