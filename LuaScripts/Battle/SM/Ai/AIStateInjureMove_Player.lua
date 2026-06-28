--玩家player InjureMove AI基类
---@class AIStateInjureMove_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateInjureMove_Player",Battle.AIState)

--1为小幅受击，2为大幅受击，3为旋转击飞，4为双方暂停
M.injureType = 1

--1为正常结束，2为小幅倒地，3为大幅倒地
M.endType = 1

M.killer = nil

M.extra_anim_name = nil

M.forward = nil

--1为受伤中，0为全新受伤
M.state = 0

--M.injureMoveData = 
--{
--    injureType = 1,
--    endType = 1,
--    type = "line",
--    distance = 1,
--    time = 0.5,
--    dir = FixVector3(0,0,0),
--    killer = nil
--}
M.useCurve = false

M.dir = nil
M.hSpeed = nil
M.vSpeed = nil
M.onGround = nil
M.moveFinish = false

--进入移动状态
function M:enter()
    M.super.enter(self)
    
    --设置受伤类型d
    self.injureType = tonumber(self.player.injureMoveData["injureType"])
    --设置受伤结束类型
    self.endType = tonumber(self.player.injureMoveData["endType"])
    --循环时长
    self.time = self.player.injureMoveData["time"]
    --攻击者
    self.killer = self.player.injureMoveData["killer"]
    --曲线移动
    local curve = {}
    curve.type = self.player.injureMoveData["type"]

    if curve.type ~= nil and curve.type ~= "nil" then
        self.useCurve = true
        local distance = self.player.injureMoveData["distance"]
        curve.time = self.player.injureMoveData["time"] or GlobalTools.base0
        local moveType = self.player.injureMoveData["moveType"]
        if moveType == nil or moveType == "forceDistance" then
            curve.distance = distance
            curve.dir = self.player.injureMoveData["dir"]
        elseif moveType == "targetDistance" then
            local dis = GlobalTools:DistanceOne(self.player.position, self.killer.position)
            if dis < distance then
                curve.distance = GlobalTools.base0
            else
                curve.distance = dis - distance
            end
            curve.dir = GlobalTools:Dir(self.player.position, self.killer.position)
        elseif moveType == "targetPercent" then
            local dis = GlobalTools:DistanceOne(self.player.position, self.killer.position)
            curve.distance = GlobalTools:Mul( dis, distance )
            curve.dir = GlobalTools:Dir( self.player.position, self.killer.position )
        end
        curve.time = self.player.injureMoveData["time"]

        if curve.distance > GlobalTools.base0 then
            if self.killer ~= nil then
                local dir = self.killer:getForward()
                if self.player.isBoss == false then
                    local final_dir = dir * -GlobalTools.base1
                    self.player:setForward(final_dir)
                end
            end
        end

        self.state = 0
        self.player.curveMgr:add(curve)
        self.hSpeed = GlobalTools.base0
        self.vSpeed = GlobalTools.base0
    else
        self.state = 0
        self.useCurve = false
        self.hSpeed = self.player.injureMoveData["hSpeed"] or GlobalTools.base0
        self.moveFinish = self.hSpeed <= GlobalTools.base0
        self.vSpeed = self.player.injureMoveData["vSpeed"] or GlobalTools.base0
        self.onGround = self.vSpeed <= GlobalTools.base0
        self.dir = self.player.injureMoveData["dir"]
    end
    
    --动画处理
    if self.state == 0 then
        local animList = Battle.List.new()

        local endAnim = {}
        if self.injureType == 1 then
            animList:add({name = "hit1_1"})
            if self.useCurve then
                animList:add({name = "hit1_1loop", time = curve.time + TimeManager:time()})
                table.insert(endAnim, "hit1_1end")
            else
                if self.hSpeed > GlobalTools.base0 then
                    animList:add({name = "hit1_1loop", time = -1})
                else
                    animList:add({name = "hit1_1end"})
                end
            end

        elseif self.injureType == 2 then
            if self.endType == 1 then
                animList:add({name = "hit1_2"})
                if self.useCurve then
                    animList:add({name = "hit1_2loop", time = curve.time + TimeManager:time() })
                    table.insert(endAnim, "hit1_2end")
                else
                    if self.hSpeed > GlobalTools.base0 then
                        animList:add({name = "hit1_2loop", time = -1})
                    else
                        animList:add({name = "hit1_2end"})
                    end
                end
            else
                animList:add({name = "hit2_1"})
            end

        elseif self.injureType == 3 then
            if self.killer ~= nil then
                local dir = self.killer:getForward()
                local final_dir = dir * -GlobalTools.base1
                self.player:setForward(final_dir)
            end
            if self.useCurve then
                --animList:add({name = "hit2_flyloop", time = curve.time + TimeManager:time()})
                --table.insert(endAnim, "hit2_flyend")
                --table.insert(endAnim, "hit3")
            else
                animList:add({name = "hit2_spin", time = -1})
            end

        elseif self.injureType == 4 then
            if self.killer ~= nil then
                local dir = self.killer:getForward()
                local final_dir = dir * -GlobalTools.base1
                self.player:setForward(final_dir)
            end
            if self.useCurve then
                animList:add({name = "hit2_spin", time = curve.time + TimeManager:time() })
                table.insert(endAnim, "hit2_flyend")
                table.insert(endAnim, "hit3")
            else
                animList:add({name = "hit2_spin", time = -1})
            end
        end

        --使用曲线时注册结束动作
        if self.useCurve then
            if self.endType == 1 then
                for k, v in ipairs(endAnim) do
                    animList:add({name = v})
                end
            elseif self.endType == 2 then
                animList:add({name = "hit2_flyend"})
                animList:add({name = "hit3"})
            elseif self.endType == 3 then
                animList:add({name = "hit2_1"})
                animList:add({name = "hit3"})
            end
        end
        
        --指定动作时强制设置受伤动作
        local animName = self.player.injureMoveData["injureAnimName"]
        if animName ~= nil and animName ~= "" and animName ~= "nil" then
            animList:clear()
            animList:add({name = animName, time = self.time})
            if animName == "hit2" then
                animList:add({name = "hit3"})
            end
        end

        self.player.animator:startAnimList(animList)
        
        self.state = 1

    elseif self.state == 1 then
        if self.player.animator.curState.name == "hit2_flyloop" then
            self.player.animator:insertAnim({name = "hit2_fly"})
        elseif self.player.animator.curState.name == "hit2_fly" then
            self.player.animator:nextAnim(true)
        elseif string.match(self.player.animator.curState.name, "hit1_1") ~= nil then
            local animList = Battle.List.new()
            --animList:add({name = "hit1_1"})
            animList:add({name = "hit1_1loop", time = curve.time + TimeManager:time() })
            animList:add({name = "hit1_1end"})
            
            self.player.animator:startAnimList(animList)

        elseif string.match(self.player.animator.curState.name, "hit1_2") ~= nil then
            local animList = Battle.List.new()
            --animList:add({name = "hit1_2"})
            animList:add({name = "hit1_2loop", time = curve.time + TimeManager:time() })
            animList:add({name = "hit1_2end"})
            self.player.animator:startAnimList(animList)
        end
        --if self.player.animator.curState.name == "hit" then
        --    self.player.animator:nextAnim(true)
        --end
    end

    self.forward = self.player.forward;

    --大招时间停止
    if self.killer ~= nil and self.killer.isUnScale then
        self.player:setLayer(true)
    end
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    
    if self.useCurve == false and self.moveFinish == false then
        local pos = self.player.position
        if self.hSpeed ~= nil then
            if self.hSpeed > GlobalTools.base0 then
                local dir_pos = self.dir * self.hSpeed * dt;
                pos = pos + dir_pos
                if self.onGround then
                    --local a = SceneManager.curScene.friction * self.player.weight / self.player.weight
                    self.hSpeed = self.hSpeed - GlobalTools:Mul( SceneManager.curScene.friction, dt )
                    if self.hSpeed <= GlobalTools.base0 then
                        self.hSpeed = GlobalTools.base0
                    end
                end
            else
                if self.player.animator.curState.running == false then
                    self:moveStop()
                end
            end
        end

        if self.onGround == false then
            if self.vSpeed ~= nil then
                pos = pos + FixVector3.up() * self.vSpeed * dt
                if pos.y <= self.player.positionY then
                    pos.y = self.player.positionY
                    self.onGround = true

                    local animList = Battle.List.new()
                    --if self.endType == 2 then
                        animList:add({name = "hit2_flyend"})
                    --elseif self.endType == 3 then
                    --    animList:add({name = "hit2_2"})
                    --end
                    self.player.animator:startAnimList(animList)

                end
                self.vSpeed = self.vSpeed - GlobalTools:Mul(SceneManager.gravity, dt)
            end
        end

        --计算范围
        if SceneManager.curScene.getAreaPosition ~= nil then

            local newPos = nil
            local outX,outZ = nil
            newPos, outX, outZ = SceneManager.curScene:getAreaPosition(pos)
            if outX then
                self.dir.x = GlobalTools:Mul(self.dir.x, -GlobalTools.base1 )
                if self.hSpeed > GlobalTools.base2_5 then
                    self.hSpeed = GlobalTools.base2_5
                end
            elseif outZ then
                self.dir.z = GlobalTools:Mul(self.dir.z, -GlobalTools.base1 )
                if self.hSpeed > GlobalTools.base2_5 then
                    self.hSpeed = GlobalTools.base2_5
                end
            end
        end
        self.player:setPos(pos)
    end

    if self.player.animator.curState ~= nil then
        --受伤结束，停止ai状态
        if (self.player.animator.curState.isLooping == true or self.player.animator.curState.running == false) and self.hSpeed <= GlobalTools.base0 then
            self:injureEnd()
        end
    else
        self:injureEnd()
    end
end

function M:moveStop()
    self.moveFinish = true
    local animList = Battle.List.new()
    if self.injureType == 1 then
        animList:add({name = "hit1_1end"})
    elseif self.injureType == 2 then
        if self.endType == 1 then
            animList:add({name = "hit1_2end"})
        else
            animList:add({name = "hit3"})
        end
    else
        animList:add({name = "hit3"})
    end
    self.player.animator:startAnimList(animList)
end


--正式推出受伤状态
function M:injureEnd()
    if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
            SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
        self.state = 0
        if self.player.bufMgr:inDebuffState() then
            self.player.aiEngine:changeState("debuff")
        else
            self.player.aiEngine:changeState("patrol")
        end        
    else
        self.player.aiEngine:changeState("patrol")
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
    if self.forward ~= nil then
        self.player:setForward( self.forward )
        self.forward = nil;
    end

    if self.player.position.y > self.player.positionY then
        local pos = self.player.position:Clone()
        pos.y = self.player.positionY
        self.player:setPos(pos)
    end
    if self.player:get_enemy() ~= nil then
        self.player:lockEnemy(nil);
    end
end

return M