---@class MoveOrder : MoveGeneral 技能帧
local M = class("MoveOrder",MoveGeneral)

function M:init(move,player,data)
    M.super.init(self, move, player, data)
    self.move.speed = self.move.data["speed"]
    self.move.moveOrder = self.move.data["moveOrder"]
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

--顺序
function M:Order(index)
    index = index + 1
    return index
end

--随机
function M:OrderRandom()
    local index = WRandom:randomNum(1,5, true)
   return index
end

function M:moveing( time )
    if self.move.curTime > 0 then
        self.move.curTime = self.move.curTime - time
        if self.move.curTime <= 0 then
            self.move.curTime = 0
        end
        local distance = GlobalTools:Distance(self.move.pos, self.move.player.position )

        if distance < GlobalTools:ToFix2(GlobalTools.base0_5) then
            local enemys = SelectTargetTool:findPlayerByType(self.move.count,self.move.player)
            if enemys.Count == 1 then
                if self.move.control == false then
                    local random = WRandom:randomNum(0,360, true)
                    local dir = FixVector3( GlobalTools:Cos(random),0,GlobalTools:Sin(random) )
                    dir = FixVector3.Normalize(dir)
                    self:setPos(self.move.pos +  dir * GlobalTools.base3 )
                    self.move.control = true     
                else
                    self.move.target = enemys:get(0)
                    if self.move.target ~= nil then
                        self:setPos(self.move.target.position)
                        self.move.control = false
                    else
                         self.move.curTime = 0;
                    end
                end                  
            else

                if self.move.moveOrder == "order" then
                    self.move.index = self:Order(self.move.index )     
                elseif self.moveOrder == "random" then
                    self.move.index = self:OrderRandom()
                end


                self:changeTarget()
                if self.move.target ~= nil then
                    self:setPos(self.move.target.position)
                end
            end
        else
            if self.move.target ~= nil and self.move.target:isLive() then
                local dir = GlobalTools:Dir(self.move.pos, self.move.player.position)
                local pos = self.move.player.position + dir * time * self.move.speed
                self.move.player:setPos( pos )
                self.move.player:setForward( dir)
            else
                if self.move.moveOrder == "order" then
                    self.move.index = self:Order(self.move.index )
                elseif self.moveOrder == "random" then
                    self.move.index = self:OrderRandom()
                end
                self:changeTarget()
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
        if self.move.index >= enemys.Count then
            self.move.index = 0
        end

        self.move.target = enemys:get(self.move.index )
        if self.move.target == nil then
            self.move.curTime = 0;
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