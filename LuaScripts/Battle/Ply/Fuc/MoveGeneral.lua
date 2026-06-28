--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:29:15
]]
---@class MoveGeneral 普通位移
---@field move Move
local M = class("MoveGeneral")
--[[
    @desc: 初始化技能 
    author:{author}
    time:2020-01-10 10:22:43
    --@skillData: 
    @return:
]]
function M:init(move,player,data)
    self.move = move
    self.move.data = data
    self.move.player = player
    self.move.finish = false
    self.move.count = data["count"]
    self.move.selectDis = data["selectDis"]
    self.move.curve = data["curveMove"]
    self.move.MoveDis = self.move.curve["curveMoveDistance"]
    if self.move.MoveDis == nil then
        self.move.MoveDis = 0
    end
    --相对于目标位置
    self.move.targetPos = data["targetPos"]
    --是否是场景方向
    self.move.useSceneDir = data["useSceneDir"] == true
    --是否朝向目标点
    self.move.faceToTarget = data["faceToTarget"] == true
    --后跳
    self.move.isBackMove = data["isBackMove"] == true
    --移动方式
    self.move.targetorder = data["moveOrder"]
    --移动完是否重新索敌
    self.move.isAnewEnemy = data["isAnewEnemy"]
    --方向是否归零
    self.move.isDirZero = data["isDirZero"]
    --是否回头
    self.move.needBack = data["needBack"] == true
    --距离
    self.move.distance = data["distance"]
    --是否朝向boss
    self.move.dirToBoss = data["dirToBoss"] == true
    --是否使用选择目标方式
    self.move.isTargetSelect = data["isSelectTarget"]
    --曲线移动的time
    self.move.time = self.move.curve["curveMoveTime"]

    self.move.ignoreArea = data["ignoreArea"] == true
    --是否是目标出生点
    self.move.isTargetPoint = data["isTargetPoint"] == true

    if self.move.time ~= nil and self.move.time <= 0 then
        self.move.time = GlobalTools.base0_0_1;
    end
    self.move.curTime = self.move.time
    self.move.curveX = GlobalTools:GetCurve(self.move.curve["curveMoveType"],false)
    self.move.curveY = GlobalTools:GetCurve(self.move.curve["curveMoveType"],true)
    --定点位置
    self.move.startPosition = FixVector3.New(0, 0, 0)
    self.move.startPosition.x = self.move.player.position.x
    self.move.startPosition.y = self.move.player.position.y
    self.move.startPosition.z = self.move.player.position.z
    self.move.dir = FixVector3.New(0, 0, 0)

    local ply =  self.move.player

    --if self.move.player.master ~= nil  then
    --    ply = self.move.player.master
    --end

    if self.move.selectDis == "number" then
        if self.move.count.isFixPoint then
            local point = SelectTargetTool:findFixPoint(self.move.player, self.move.count.fixpoint)
            if point ~= nil then
                self:moveDir(point,self.move.player.position,nil)
                local distance = GlobalTools:DistanceOne(self.move.player.position, point)
                self.move.MoveDis = distance + self.move.distance
            end
        else
            local enemys = SelectTargetTool:findPlayerByType(self.move.count,ply)
            if enemys ~= nil and enemys:get(0) ~= nil then
                self.move.target = enemys:get(0)
                if self.move.target.camp ~= self.move.player.camp  then
                    self.move.player:lockEnemy(self.move.target);
                end
                self:moveDir(self.move.target.position,self.move.player.position,self.move.target)
                if self.move.isAnewEnemy == true then
                    self.move.player:lockEnemy(nil)
                end
            end
        end
    elseif self.move.selectDis == "percentum" then
        if self.move.player:get_enemy() ~= nil then
            local distance = GlobalTools:Distance(self.move.player.position,self.move.player:get_enemy().position)
            if distance <= GlobalTools:ToFix2(GlobalTools.base2) then
                distance = 0
            end
            self.move.MoveDis = GlobalTools:Mul( self.move.MoveDis, distance );
        end
    elseif self.move.selectDis == "fixPoint" then
        if self.move.isTargetSelect == true then
            if self.move.target ~= nil then
                self:moveDir(self.move.target.position,self.move.player.position,nil)
                self.move.MoveDis = GlobalTools:DistanceOne(self.move.target.position,self.move.player.position) - self.move.distance
                self.move.MoveDis =self.move.MoveDis
                self.move.player:setForward(self.move.dir)
            end
        else
            if self.move.targetPos == "spawnPoint" then
                if self.move.isTargetPoint then
                    local enemys = SelectTargetTool:findPlayerByType(self.move.count,self.move.player)
                    if enemys ~= nil and enemys:get(0) ~= nil then
                        self.move.target = enemys:get(0)
                        local point  = self.move.target.beginPos:Clone() 
                        self:moveDir(point,self.move.target.position,self.move.target)
                    end
                else
                    local point  = self.move.player.beginPos:Clone() --SceneManager.curScene:findSpawnPosition(self.move.player.camp, self.move.player.index)
                    self:moveDir(point,self.move.player.position,nil)
                    local dis = GlobalTools:DistanceOne(point,self.move.player.position)
                    self.move.MoveDis = dis
                end
            elseif self.move.targetPos == "Densearea" then
                --返回玩家的敌人周围的密集区中的最近的玩家
                local point = SelectTargetTool:findFixPoint(self.move.player, "Densearea", GlobalTools.base2)
                if point ~= nil then
                    self:moveDir(point,self.move.player.position,nil)
                    local distance = GlobalTools:DistanceOne(self.move.player.position, point)
                    --if distance <= GlobalTools.base2 then
                    --    distance = 0
                    --end
                    self.move.MoveDis = distance + self.move.distance
                end
            end
        end
    elseif self.move.selectDis == "areaEdge" then
        local edgePoint = SceneManager.curScene:getEdgePosition(self.move.player.position, self.move.player.forward * -GlobalTools.base1)
        self:moveDir(edgePoint,self.move.player.position,self.move.player)
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, edgePoint) - self.move.distance
    elseif self.move.selectDis == "spawnPoint" then
        local spawnPoint = self.move.player.spawnPos
        self:moveDir(spawnPoint,self.move.player.position,self.move.player)
        --不让摄像机移动
        --SceneManager.curScene:setPositionFinish()
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, spawnPoint) - self.move.distance
    end

    if self.move.needBack then
        self.move.player.data.limitByArea = false
    end

    EventDispatcher:dipatchEvent("PlayerAttackMove", {move = self})
end

--更新
function M:update(dt)
    local time = dt
    if self.move.player.animator.mode == 2 then
        
    end
    self:moveing(time)
end

function M:moveing( time )
    if self.move.curTime ~= nil then
        if  self.move.curTime > 0 then
            self.move.curTime = self.move.curTime - time
            if self.move.curTime <= 0 then
                self.move.curTime = 0
            end
            local progress = GlobalTools.base1 - GlobalTools:Div(self.move.curTime, self.move.time);
            local progress_curve_x = GlobalTools.base0_5;
            if self.move.curveX ~= nil then
                progress_curve_x = self.move.curveX:Evaluate(progress);
            end
            local pos = self.move.startPosition + self.move.dir * progress_curve_x * self.move.MoveDis
            local progress_curve_y = GlobalTools.base0_5;
            if self.move.curveY ~= nil then
                progress_curve_y = self.move.curveY:Evaluate(progress);
            end
            pos.y = self.move.startPosition.y + progress_curve_y
            if progress > GlobalTools.base0_5 and self.move.needBack == true then
                if SceneManager.curScene:isInArea(pos - self.move.dir * GlobalTools.base3) == false then
                    pos = pos - self.move.dir * self.move.MoveDis
                end
            else
                if self.move.ignoreArea ~= true then
                    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
                        SceneManager.curScene:getAreaPosition(pos)
                    end
                end
            end
            self.move.player:setPos(pos)
        else
            self.move.player.moveMgr:removeMove(self.move)
            EventDispatcher:dipatchEvent("moveEnd",{player = self.move.player})

            if self.move.faceToTarget == true and self.move.target ~= nil then
                local dir = GlobalTools:Dir(self.move.target.position, self.move.player.position);  
                self.move.player:setForward( dir )
            end

            if self.move.isTargetSelect == true then
               --[[ if self.target ~= nil then
                    self.player:setForward( self.target:getForward())
                    self.player:setPos(self.target.position + self.target:getForward() * 1)
                end]]
            end
            if self.move.needBack then
                self.move.player.data.limitByArea = true
                self.move.player:lockEnemy(nil);
            end
        end
    end
end

--选择方向
function  M:moveDir(tarPos,plyPos,target)
    local move_dir = FixVector3.New(0, 0, 0)
    if self.move.targetPos == "Up"  then        
        move_dir=self.move:moveUp(tarPos,plyPos,target)
    elseif self.move.targetPos == "Down" then
        move_dir=self.move:moveDown(tarPos,plyPos,target)
    elseif self.move.targetPos == "front" then
        move_dir=self.move:moveFront(tarPos,plyPos,target)
    elseif self.move.targetPos == "back" then
        move_dir=self.move:moveBack(tarPos,plyPos,target)    
    elseif self.move.targetPos == "Left" then
        move_dir=self.move:moveLeft(tarPos,plyPos,target)     
    elseif self.move.targetPos == "Right" then
        move_dir=self.move:moveRight(tarPos,plyPos,target)
    elseif self.move.targetPos == "spawnPoint" then
        if self.move.isTargetPoint then
            move_dir = target:getForward() * -1

            self:moveSetPos(tarPos,move_dir,target)
        else
            local point = SceneManager.curScene:findSpawnPosition(self.move.player.camp, self.move.player.index)
            move_dir = GlobalTools:Dir( point, self.move.player.position);
            self.move.player:setForward( move_dir )
        end
       
    elseif self.move.targetPos == "Densearea" then
        move_dir = GlobalTools:Dir(tarPos,self.move.player.position);
    elseif self.move.targetPos == "originalPlace" then 
        if self.move.player.beforePos~= nil then
            self:moveSetPos(self.move.player.beforePos, move_dir, target)
            self.move.player:setPos( self.move.player.beforePos )
        end
    end
    self.move.dir.x = move_dir.x
    self.move.dir.y = move_dir.y
    self.move.dir.z = move_dir.z
end

function  M:moveSetPos(tarPos,dir,target)
end

function M:setPlayerForward( pos )
    --移动到的目标位置，和我之间的方向
    local dir = GlobalTools:Dir(pos, self.move.player.position);
    if self.move.isDirZero == true then
        dir.z = 0
        dir = FixVector3.Normalize(dir)
    end
    if self.move.isBackMove == true then
        dir.x = -dir.x
    end
    if self.move.useSceneDir == true then
        dir = FixVector3.forward()
    end

    if self.move.dirToBoss and (SceneManager.curScene.sceneId == SceneManager.SceneID.BossScene or SceneManager.curScene.sceneId == SceneManager.SceneID.ActiveBossScene) then
        local enemy = SceneManager.curScene.plyMgr.enemy_list:get(0)
        if enemy ~= nil then
            dir = GlobalTools:Dir(self.move.player.position, enemy.position);
        end
    end
    
    self.move.player:setForward( dir )
    return dir
end

--移动到目标后面
function M:moveBack(tarPos,plyPos,target)
    local dir = nil
    if target ~= nil  then
        dir = target:getForward() * -GlobalTools.base1
        dir.z = 0
        dir = dir:SetNormalize()
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        if self.move.selectDis == "number" then
            self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        end
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir
    else
        dir = GlobalTools:Dir(tarPos, plyPos);
        return dir
    end
end


--移动到目标前面
function M:moveFront(tarPos,plyPos,target)
    local dir = nil
    if target ~= nil  then
        dir = target:getForward():Clone();
        dir.z = GlobalTools.base0
        dir = dir:SetNormalize()
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        if GlobalTools:Distance(self.move.player.position, target.position) < GlobalTools:ToFix2(self.move.distance) then
            pos = self.move.player.position + self.move.player:getForward() * GlobalTools.base0_1
        end
        if self.move.selectDis == "number" then
            self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        end
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir
    else
        dir = GlobalTools:Dir(tarPos, plyPos);
        --self:moveSetPos(tarPos,dir,target)
        return dir 
    end
    
end

--移动到目标左面
function M:moveLeft(tarPos,plyPos,target)
    local dir = nil
    if target ~= nil  then
        dir = target:getRight() * -GlobalTools.base1
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir

    else
        local dir = tarPos.right()
        return dir
    end
    
end

--移动到目标右面
function M:moveRight(tarPos,plyPos,target) 
    local dir = nil
    if target ~= nil  then
        dir = target:getRight()
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir
    else
        
    end   

    return dir
end

--移动到目标上面
function M:moveUp(tarPos,plyPos,target)
    local dir = nil
    if target ~= nil  then
        dir = target:getUp()
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir
    else

    end
    return dir
end

--移动到目标下面
function M:moveDown(tarPos,plyPos,target) 
    local dir = nil
    if target ~= nil  then
        dir = target:getUp() * -GlobalTools.base1
        local pos = dir * self.move.distance + target.position
        local move_dir = pos - self.move.player.position
        move_dir = move_dir:SetNormalize()
        self.move.MoveDis = GlobalTools:DistanceOne(self.move.player.position, pos)
        self:setPlayerForward(pos)
        self:moveSetPos(tarPos,dir,target)
        return move_dir
    else

    end
    return dir   
    
end


function M:dead()
    
end


function M:destroy()
    self.move.finish = true
    self.move.player.moveMgr:removeMove(self.move)
end

return M