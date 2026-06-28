--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 13:43:44
]]

---@class Bullet_Model : ModelBase
---@field lifeTime number 生命周期
---@field enemy PlayerModel
---@field player PlayerModel
local M = class("Bullet_Model",Battle.ModelBase)

---@param data Battle_CreateBullet_Data
function M:init( data )
    --子弹的发出者
    self.player = data.player
    --子弹类型
    self.type = data.bulletType
    --子弹数据
    self.data = data.data
    --攻击增怒
    self.attackerAnger = data.attackerAnger
    --子弹的特效数据
    if data.bulletEffectData ~= nil then
        self.effectData = data.bulletEffectData.data;
    else
        self.effectData = self.data;
        Logger.logError(self.player.plyType,"子弹找不到子弹特效")
    end
    --生命周期
    self.lifeTime = GlobalTools:CommonToFix( self.effectData["lifeTime"] )
    --受击特效数据
    self.hitEffectList = {}
    self.bombEffectList = {}
    if self.effectData ~= nil and self.effectData["prefabList"] ~= nil then
        for k,v in pairs(self.effectData["prefabList"]) do
            if v.type == "injureHit" or v.type == "critHit" then
                table.insert(self.hitEffectList, v)
            elseif v.type == "bombHit" then
                table.insert(self.bombEffectList, v)
            end
        end
    else
        if self.sourceSkill ~= nil then
            --Logger.logError("Lack of HitEffect. player:"..self.player.plyType..". skill:"..self.sourceSkill.anim_name)
        else
            --Logger.logError("Lack of HitEffect. player:"..self.player.plyType)
        end
    end
    
    --父级
    self.parentName = self.effectData["parent"]
    --移动速度
    self.speed = GlobalTools:CommonToFix( self.effectData["speed"] )
    --垂直方向速度
    self.vSpeed = self.data["vSpeed"] or 0
    --延迟时长
    self.delayTime = self.data["delayTime"] or 0
    --延迟爆炸时长
    self.delayBoomTime = self.data["delayBoomTime"] or 0
    --目标的偏移量
    if self.effectData.targetOffset ~= nil then
        self.targetOffset_x = GlobalTools:CommonToFix(self.effectData.targetOffset.x);
        self.targetOffset_y = GlobalTools:CommonToFix(self.effectData.targetOffset.y);
        self.targetOffset_z = GlobalTools:CommonToFix(self.effectData.targetOffset.z);
    else
        self.targetOffset_x = GlobalTools.base0;
        self.targetOffset_y = GlobalTools.base0;
        self.targetOffset_z = GlobalTools.base0;
    end
    -- 是否已经攻击过了
    self.isAttack = false;
    
    -- 此次子弹是否可以弹射自己
    self.canHitSelf = false
    
    self.acceleration = self.data["acceleration"] or GlobalTools.base0
   
    self.frontDamage = self.data["frontdamagePercent"]
    self.lastdamagePercent = self.data["lastdamagePercent"]
    --怒气系数
    self.angerRate = self.data["angerAirPercent"] or GlobalTools.base1
    --不产生伤害
    self.noAttack = self.data["noAttack"]
    --是否穿刺
    self.isPuncture = self.data["puncturedmg"]
    --伤害衰减
    self.damageReduce = self.data["damageReduce"] or GlobalTools.base1
    --是否回旋
    self.isCircle = self.data["isCircle"]
    --是否正前方
    self.isForward = self.data["isForward"]
    --是否是特殊效果
    self.isSpecial = self.data["isSpecial"]
    --特殊效果参数
    self.SpecialParam =self.data["SpecialParam"]
    --回旋次数
    self.circleCount = self.data["circleCount"]
    -- 配置的透传参数 
    self.extraParam = self.data.extraParam
    
    self.mustCrit = self.data["mustCrit"]
    self.mustHit = self.data["mustHit"]

    self.injureMove = self.data["injureMove"]
    self.curveMove = self.data["curveMove"]
    -- 是否在边缘爆炸
    self.isSideBomb = self.data["isSideBomb"]
    -- aoe 类型
    self.aoe = self.data["aoeType"]
    -- 是否强制设位置
    self.positionForce = false;
    -- 是否强制设方向
    self.dirForce = false;
    self.shootFixPoint = self.data["count"]["isFixPoint"]

    self.clearListTime = self.data["punctureTime"] or GlobalTools.base0_2
    --self.sourceSkill = player.curSkillConfig

    if self.isPuncture then
        if self.clearListTime <= 0 then
            self.clearListTime = GlobalTools.base0_2
        end
        self.clearListTimer = self.clearListTime
    end
    
    --检测半径
    self.checkRange = self.data["checkRange"]
    --攻击范围内的敌人
    self.hitList = Battle.List.new()
    --已经攻击过的敌人
    self.alreadyHitList = {}
    --当前的延迟时间
    self.curDelayTime = 0;
    --特效播放的参数
    self.syncEffectParam = {}
    --飞行距离
    self.flyDistance = GlobalTools.base0
    --默认为单体伤害
    self.isSingleTarget = true
    --最后一次位置
    self.lastPos = {}
    --几种范围伤害
    if self.data["count"]["aoeType"] == "Sector" or self.data["count"]["aoeType"] == "Rect" then
        self.isSingleTarget = false
    elseif self.aoe["aoeType"] == "Sector" or self.aoe["aoeType"] == "Rect" then
        self.isSingleTarget = false
    elseif self.isPuncture == true then
        self.isSingleTarget = false
    end
    
    --发送子弹的数据创建完成了
    self.player:dispatchEvent_Local(Battle.EventType.MV_BulletModelCreateFinish, self)
    --和视图绑定完成之后
    self:bindViewFinish(data);
end

--设定子弹状态
--    0 初始化0
--    1 射击出去了
--    2 死亡状态
--    3 等待状态
function M:setState( state )
    self.bulletState = state;
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelSyncState)
end

function M:getState()
    return self.bulletState;
end

--子弹是否死亡
function M:isDead()
    return self.bulletState == 2;
end

function M:bindViewFinish( data )
    --这里需要存一个世界位置
    --子弹发出的位置
    local firePoint = self.effectData["firePoint"]
    local fix_firePoint = FixVector3.New(0, 0, 0)
    fix_firePoint.x = GlobalTools:CommonToFix(firePoint.x);
    fix_firePoint.y = GlobalTools:CommonToFix(firePoint.y);
    fix_firePoint.z = GlobalTools:CommonToFix(firePoint.z);
    --目标
    self:set_enemy( data.target )
    --设定状态
    self:setState(0);
    --世界的位置
    local worldPos = {}
    worldPos.x = self.player.position.x + fix_firePoint.x;
    worldPos.y = self.player.position.y + fix_firePoint.y;
    worldPos.z = self.player.position.z + fix_firePoint.z;
    --子弹的初始位置
    self:setPos( worldPos,true)
    --子弹的初始方向
    self:setForward( FixVector3.right() );
    --self:setNextPos( worldPos )
    --self:setInjurePosition( self.position );
    
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelBandFinish)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 外部获取属性 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--获取子弹类型
function M:get_type()
    return self.type;
end

--获取特效数据
function M:get_effectData()
    return self.effectData;
end

--获取位置
function M:get_position()
    return self.position;  
end

--获取强制设位置
function M:get_positionForce()
    return self.positionForce;
end

--获取方向
function M:get_dir()
    return self.dir
end

--获取强制设方向
function M:get_dirForce()
    return self.dirForce
end

--获取子弹目标
function M:get_target()
    return self.target
end

--设定受伤位置
function M:setInjurePosition( pos )
    if self.injure_position == nil then
        self.injure_position = FixVector3.New(0,0,0);
    end
    self.injure_position.x = pos.x;
    self.injure_position.y = pos.y;
    self.injure_position.z = pos.z;
end

--设定子弹移动位置
function M:setPos( pos, isForce )
    if self.position == nil then
        self.position = FixVector3.New(0,0,0);
    end
    self.position.x = pos.x;
    self.position.y = pos.y;
    self.position.z = pos.z;
    self.positionForce = isForce;
    -- 同步子弹的位置
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelSyncPosition);
end

--设定子弹的下一个位置
function M:setNextPos( pos )
    if self.nextPosition == nil then
        self.nextPosition = FixVector3.New(0,0,0);
    end
    self.nextPosition.x = pos.x;
    self.nextPosition.y = pos.y;
    self.nextPosition.z = pos.z;
end

--设定子弹方向
function M:setForward( dir, isForce )
    if self.dir == nil then
        self.dir = FixVector3.New(0,0,0);
    end
    self.dir.x = dir.x;
    self.dir.y = dir.y;
    self.dir.z = dir.z;
    self.dirForce = isForce;
    -- 同步子弹的方向
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelSyncDir);
end

--克隆位置
function M:clonePos( pos )
    if self.position == nil then
        self.position = FixVector3.New(0,0,0);
    end
    self.position.x = pos.x;
    self.position.y = pos.y;
    self.position.z = pos.z;
    return self.position
end

--克隆方向
function M:cloneDir( dir )
    if self.dir == nil then
        self.dir = FixVector3.New(0,0,0);
    end
    self.dir.x = dir.x;
    self.dir.y = dir.y;
    self.dir.z = dir.z;
    return self.dir
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 外部获取属性 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 设定我要射击的目标点
function M:set_bullet_target( target )
    self.target = target
end


--发射
function M:shoot()
    -- 子弹发射消息
    EventDispatcher:dipatchEvent("shootBullet",{ bullet = self })   
    if self.player ~= nil then
        -- 设计目标
        local target_dir = GlobalTools:Dir(self.target, self.position);
        --目标方向的偏移量
        local target_pos_offset = target_dir * self.targetOffset_z
        --垂直方向偏移量
        local up_dir_offset = FixVector3.up() * self.targetOffset_y
        --目标位置
        local target_pos = self.target + target_pos_offset + up_dir_offset;
        
        if self.data["count"]["isFixPoint"] ~= true then
            target_pos.y = target_pos.y + GlobalTools.base1;
            --如果不是穿刺伤害
            if self.isPuncture == false then
                --3秒生命周期
                self.lifeTime = GlobalTools.base3;
            end
        end
        
        --计算目标和子弹位置 计算子弹方向
        local dir = GlobalTools:Dir3D(target_pos, self.position)
        if self.effectData["isY"] then
             dir.y = GlobalTools.base0
        end
        
        --子弹方向
        self:setForward( dir, true );
        
        --子弹垂直的速度
        if self.vSpeed == GlobalTools.base0 then
            self.gravity = GlobalTools.base0
        else
            --计算目标点和当前子弹的距离
            local dis = GlobalTools:DistanceOne(target_pos, self.position)
            local time = GlobalTools:Div( dis, self.speed )
            --垂直速度
            local vSpeedTime = GlobalTools:Mul(self.vSpeed, time)
            --垂直速度数值
            local vSpeed_value = GlobalTools:Mul( (vSpeedTime + GlobalTools.base1), GlobalTools.base2 );
            --计算重力
            self.gravity = GlobalTools:Div( vSpeed_value, GlobalTools:Mul(time, time))
        end
        
        --清除子弹
        self:clear();
        --计算下一个位置
        self:calNextPosition()
        --检测生命周期
        self.checkLiveTime = self.lifeTime
        
        --Logger.log(self.injurePrefabName.." 创建子弹 声明周期 ~~~~~~~~~~~~~~~~~ "..self.checkLiveTime )

        self.curDelayTime = self.delayTime;
        self:setState(1);
        
        --如果子弹的敌人和发出者，是同一个人，直接攻击
        if self.enemy ~= nil and self.enemy:equal(self.player) then
            self:hitPlayer(self.player)
            --是否是穿刺攻击
            if self.isPuncture == false then
                self:destroy()
            end
        else
            -- 检测伤害(敌人太近,子弹速度太快)
            self:flyDamage(TimeManager:deltaTime());
        end
    end

    if self:getState() ~= 2 then
        self:dispatchEvent_Local(Battle.EventType.MV_BulletModelShoot)
    end
end


--设定敌人
function M:set_enemy( enemy )
    self.enemy = enemy;
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelSetEnemy)
end

function M:get_enemy()
    return self.enemy;
end

--清空数据
function M:clear()
    self.hitList:clear()
    self.minHitPlayer = nil
    self.alreadyHitList = {}
end

--攻击人
---@param player PlayerModel
function M:hitPlayer(player)
    --攻击敌人 
    --玩家攻击力
    --bufid = 0
    --攻击数据
    local attackData = BattleTool:getBaseAttackData()
    attackData["damage"] = self.player.data:get_atk()
    attackData["injureBuf"] = 0
    attackData["player"] = self.player
    attackData["skillConfig"] = self.sourceSkill
    attackData["type"] = 0
    attackData["damageType"] = 1
    attackData["injureType"] = "skill"
    attackData.extraParam = self.data.extraParam
    attackData.isSingleTarget = self.isSingleTarget
    --受伤的位置
    local ply_pos = player.position:Clone();
    local pos = ply_pos;
    pos.z = pos.z - GlobalTools.base0_2;
    pos.y = self.position.y
    self:setInjurePosition( pos)
    
    if self.sourceSkill ~= nil then
        attackData["damageType"] = self.sourceSkill.atk_type
    end
    attackData["attackerAnger"] = self.attackerAnger
    attackData["angerAir"] = self.angerRate
    attackData["damageFront"] = self.frontDamage
    attackData["damageLast"] = self.lastdamagePercent
    attackData["mustCrit"] = self.mustCrit
    attackData["mustHit"] = self.mustHit

    attackData["hitEffectList"] = self.hitEffectList
    if self.effectData["bulletAudio"] ~= nil and self.effectData["bulletAudio"] ~= "" then
        attackData["hitAudio"] = self.effectData["bulletAudio"]
    end
    
    local power = tonumber(self.data["power"] or GlobalTools.base30)
    power = GlobalTools:Clamp( power, GlobalTools.base30, GlobalTools.base999 )
    attackData["power"] = power
    attackData["noAttack"] = self.noAttack
    attackData["damageExtra"] = 0
    local bloodThirsty = self.player.bufMgr:findBufByType("BloodThirsty")
    for k, v in pairs(bloodThirsty) do
        if  v.bufWork ~= nil then
            attackData["damageExtra"] = attackData["damageExtra"] + v.bufWork:GetValue()
        end
    end
    if self.injureMove["move"] then
        attackData["injureMove"] = {}
        attackData["injureMove"]["injureType"] = self.injureMove["injureType"]
        attackData["injureMove"]["endType"] = self.injureMove["injureEndType"]
        attackData["injureMove"]["type"] = self.curveMove["curveMoveType"]
        attackData["injureMove"]["distance"] = self.curveMove["curveMoveDistance"]
        attackData["injureMove"]["time"] = self.curveMove["curveMoveTime"]
        attackData["injureMove"]["injureAnimName"] = self.injureMove["injureAnimName"]
        attackData["injureMove"]["moveType"] = self.curveMove["curveDistanceType"]
        if self.isPuncture then
            local dir = player.position - self.position
            dir = FixVector3.Normalize(dir)
            attackData["injureMove"]["injureDir"] = dir
        else
            attackData["injureMove"]["injureDir"] = self.dir
        end
    else
        attackData["injureMove"] = nil
    end
    
    attackData["buffId"] = self.data["buffId"]
    attackData["richBuff"] = self.data["richBuff"]
    if self.isSpecial then
        self:special( player,attackData )
    else
        player:injure( attackData )
    end

    if self.data["count"]["targetNoRepeat"] then
        self.player:add_player_enemyList(player)
    end
    self.alreadyHitList[player] = self.clearListTime
end

--特殊效果处理
---@param attackData Battle_AttackData
function M:special(player,attackData)
    if player ~= nil then
        if player.camp == self.player.camp then
            if self.data["SpecialParam"] == "addBlood" then
                player:cure("fix", player, attackData["damage"], self.sourceSkill)
            end
        else
            player:injure( attackData )
        end
    end
end

--子弹移动方法
--判断是否到边界
function M:moveStyle(dt)
    if self.bulletState == 1 then

        if self.position.y > -GlobalTools.base1 then
            local dir = self.dir
            local dis = GlobalTools:Mul(self.speed, dt)
            local dir_speed_dt = self.dir * dis;
            self.flyDistance = self.flyDistance + dis
            local up_vSpeed_dt = FixVector3.up() * self.vSpeed * dt;
            dir = dir_speed_dt + up_vSpeed_dt;
            self.speed = self.speed + GlobalTools:Mul(self.acceleration,dt)
            self.vSpeed = self.vSpeed - GlobalTools:Mul(self.gravity, dt)
            self.lastPos = self.position:Clone()
            self:setPos( self.position + dir )
            if self.position.y <= -GlobalTools.base1 then
                self.position.y = -GlobalTools.base1
            end
        end
    end
end

--计算下一个位置
function M:calNextPosition()
    if self.bulletState == 1 then
        --时间
        local dt = TimeManager:deltaTime()
        --方向
        local dir = self.dir
        local dir_speed_dt = self.dir * self.speed * dt;
        local up_vSpeed_dt = FixVector3.up() * self.vSpeed * dt;
        dir = dir_speed_dt + up_vSpeed_dt;
        if self.position.y <= -GlobalTools.base1 then
            self.position.y = -GlobalTools.base1
        end
        self:setNextPos( self.position + dir )
    end
end


--销毁子弹
function M:destroy()
    if self.position ~= nil then
        self:setState(2);
        self:clear();
        self.injure_position = nil;
        self.position = nil;
        self.nextPosition = nil;
        self.dir = nil;
        if self.delayBoomTask ~= nil then
            TimeTools:stopTask(self.delayBoomTask)
        end
        --子弹死亡
        self:dispatchEvent_Local(Battle.EventType.MV_BulletModelDead);
    end
    M.super.destroy(self);
end


--更新
function M:update(dt)
    if self.bulletState == 1 then
        if self.curDelayTime > 0 then
            self.curDelayTime = self.curDelayTime - dt
        end
        if self.curDelayTime <= 0 then
            if self.checkLiveTime > 0 then
                --真正的移动算法
                self:moveStyle(dt)
                --if self.noAttack ~= true then
                if self.isAttack == false then
                    self:flyDamage(dt);
                end
                self:calNextPosition()
                --end
                self.checkLiveTime = self.checkLiveTime - dt;
                if self.checkLiveTime <= 0 then
                    self:destroy();
                    return;
                end
            end
        end

        for k,v in pairs(self.alreadyHitList) do
            self.alreadyHitList[k] = v - dt
            if self.alreadyHitList[k] <= 0 then
                self.alreadyHitList[k] = self.clearListTime
            end
        end
    end
end

--飞行伤害
function M:flyDamage(time)
    local players = self:getPlayers(self.data["count"]["camp"])
    self.minHitPlayer = nil;
    if self.data["count"]["isFixPoint"] ~= true then
        self:checkHit(players, time)
    end
    self.hitList:clear()
    local bomb = self.minHitPlayer ~= nil or (self.position ~= nil and self.position.y < 0)
    if self.isSideBomb == true then
        local pos = SceneManager.curScene:getAreaPosition(self.position)
        if pos.x ~= self.position.x or pos.x ~= self.position.x or pos.x ~= self.position.x then
            bomb = true
        end
    end
    if bomb then
        if self.canHitSelf or self.minHitPlayer ~= self.player then
            self.canHitSelf = false
            if self.isPuncture == false then
                self:setState(3)
                -- 同步受击点到目标身上
                self:syncHitPosition()
            end

            if self.delayBoomTime <= 0 then
                self:playHitEffect()
                self:injure(players)
            else
                self:playDelayBoomEffect()
                self.delayBoomTask = TimeTools:delayTime(self.delayBoomTime, function()
                    self:clearDelayBoomEffect()
                    self:playHitEffect()
                    self:injure(players)
                    self.delayBoomTask = nil
                end)
            end
        end
        self.minHitPlayer = nil
    end
end

--播放爆炸特效 
function M:playDelayBoomEffect()
    self.syncEffectParam.type = 2;
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelPlayEffect, self.syncEffectParam)
end


--清除爆炸特效
function M:clearDelayBoomEffect()
    self.syncEffectParam.type = 3;
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelPlayEffect, self.syncEffectParam)
end


function M:injure()
    --形状
    local aoeType = self.aoe["aoeType"]
    --扇形
    if aoeType == "Sector" then
        local players = self:getAllPlayers()
        for i=players.Count,1,-1 do
            local ply = players:get(i-1)
            if ply ~= self.player then
                --if self.data["count"]["isFixPoint"] == false or self.position.y <= 0  then
                --计算我的和敌人之间的方向
                local enemyPos = ply.position:Clone()
                enemyPos.y = 0
                local pos = self.position:Clone()
                pos.y = 0
                local distance = GlobalTools:Distance(enemyPos, pos)
                local forward = nil
                if self.data["useSceneDir"] then
                    forward = FixVector3.right()
                else
                    forward = self.dir;
                end
                if distance < GlobalTools:ToFix2( self.aoe["aoeSectorRadius"] )  then
                    local nor_vec = GlobalTools:Dir(enemyPos, pos)
                    forward = forward:SetNormalize()
                    --得到角度
                    local dot = FixVector3.Dot( nor_vec, forward )
                    dot = GlobalTools:Clamp(dot, -GlobalTools.base1, GlobalTools.base1)
                    local tmpAngle = GlobalTools:ACos( dot );
                    if tmpAngle <= GlobalTools:Mul( self.aoe["aoeSectorAngle"] , GlobalTools.base0_5 ) then
                        self.hitList:add(ply)
                    end
                end
            end
            --end
        end
    elseif aoeType == "Rect" then
        local players = self:getAllPlayers()
        for i= players.Count,1,-1 do
            local ply = players:get(i-1)
            if ply ~= self.player then
                --计算目标点的和敌人之间的方向
                local vec = ply.position - self.position
                if vec.z < self.aoe["aoeRectY"] and GlobalTools:Abs(vec.x) < self.aoe["aoeRectX"] then
                    self.hitList:add(ply)
                end
            end

        end
    elseif aoeType == "None" or aoeType == nil then
        self.hitList:add(self.minHitPlayer)
    end

    self.player.plySkill:bulletHit({bullet = self})

    for i = 1,self.hitList.Count, 1 do
        local ply = self.hitList:get(i-1)
        if ply ~= nil and self.alreadyHitList[ply] == nil then
            self:hitPlayer(ply);
            self.lastdamagePercent = GlobalTools:Mul(self.lastdamagePercent, (GlobalTools.base1 - self.damageReduce))
        end
    end
    self:checkDead()
end

-- 检测死亡
function M:checkDead()
    --是否是穿刺攻击
    if self.isPuncture == false then
        if self.sourceSkill ~= nil and self.sourceSkill.effect_cross then
            self.isAttack = true
        else
            self:syncHitPosition()
            self:destroy()
        end
    end
end

--- 同步受击点到目标身上
function M:syncHitPosition()
    if self.minHitPlayer ~= nil then
        self.lastPos.x = self.minHitPlayer.position.x
        self.lastPos.y = GlobalTools.base1
        self.lastPos.z = self.minHitPlayer.position.z
        self:setPos(self.lastPos, false)
    end
end

-- 播放被打到的特效
function M:playHitEffect()
    self.syncEffectParam.type = 1;
    self:dispatchEvent_Local(Battle.EventType.MV_BulletModelPlayEffect, self.syncEffectParam);
end

--检测命中
function M:checkHit(players, time)
    local minDis = GlobalTools.base1000
    local pos;
    local mPos;
    local mNextPos;
    for i=1, players.Count,1 do
        local ply = players:get(i - 1)
        if ply:isLive() and self.alreadyHitList[ply] == nil then
            if self.dir ~= nil then
                --Logger.logError(" self.injurePrefabName dir = nil "..self.injurePrefabName )
                --敌人位置
                pos = ply.position + self.dir * GlobalTools.base0_2;
                --子弹当前的位置
                mPos = self.position
                --子弹上一个位置
                mNextPos = self.nextPosition
                --向量差值
                local distance = GlobalTools:Distance( mPos,pos );
                local speedTime = GlobalTools:Mul(self.speed, time);
                local radius = speedTime + ply.data.triggerRadius + self.checkRange
                if radius < ply.data.triggerRadius then
                    radius = ply.data.triggerRadius
                end

                if distance < GlobalTools:ToFix2(minDis) and distance < GlobalTools:ToFix2(radius) then
                    minDis = distance;
                    self.minHitPlayer = ply;
                end
            end
        end
    end
end

function M:getPlayers(camp)
    if  self.isPuncture == true then    
       return self:getAllPlayers()
    else
        local players = Battle.List.new()
        if  self.enemy ~= nil and SceneManager.curScene.plyMgr.hide_table[self.enemy:get_playerInstanceId()] == nil then
            players:add(self.enemy)
            for i = 1, self.enemy.resistBullet.Count do
                players:add(self.enemy.resistBullet:get(i - 1))
            end
        end
        
        return players
    end
    
end

function M:getAllPlayers()
    local data = table.copy(self.data["count"])

    data.count = "all"
    if data.camp == "curFriend" then
        data.camp = "allExceptSelf"
    elseif data.camp == "myenemy"  then
        data.camp = "enemy"
    end
    data.posIndex = "all"
    data.priority = false
    data.ignoreSummon = false
    data.targetNoRepeat = false
    data.campRace = "not"
    data.pos = "not"
    data.profession = "all"
    data.area = "all"
    data.areaWidth = ""
    data.areaHeight = ""
    data.areaAngle = ""
    data.areaRadius = ""
    data.forceSelect = false
    data.selectLast = false

    return SelectTargetTool:findPlayerByType(data,self.player)
end

return M