--范围内增加buf
---@class BufWorkAddBuf : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkAddBuf", BufWork_Model)

--

function M:initFinish()
    --范围半径（0时只本角色流血）
    self.radius = self.playerBuf:checkParam("radius", 0)
    self.buffid = self.playerBuf:checkParam("buffid", 0)
    --1跟随，2不跟随
    self.isFollow = self.playerBuf:checkParam("isFollow", 1)
    --1为技能释放者的己方，2为敌方, 3是自己
    self.side = self.playerBuf:checkParam("side", 2)
    -- 真正生效次数
    self.realWorkCount = self.playerBuf:checkParam("realWorkCount", 0)

    -- 矩形范围检测
    self.areaWidth = GlobalTools:Mul(self.playerBuf:checkParam("areaWidth", 0), GlobalTools.base0_5)
    self.areaHeight = GlobalTools:Mul(self.playerBuf:checkParam("areaHeight", 0), GlobalTools.base0_5)
    
    -- 是否是矩形范围检测
    self.isRectangleArea = (self.areaHeight > 0 and self.areaWidth > 0)
    
    --0为玩家初始位置，
    --1为己方中央
    --2为敌方中央
    --3为场景中央
    --4为密集区
    self.fixPoint = self.playerBuf:checkParam("fixPoint", 0)

    if self.isFollow == 2 then
        self.pos = FixVector3.New(0, 0, 0)
        local position = FixVector3.New(0, 0, 0)
        if self.fixPoint == 0 then
            position = self.playerBuf.player.position
        elseif self.fixPoint == 1 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "selfCenter")
        elseif self.fixPoint == 2 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "enemyCenter")
        elseif self.fixPoint == 3 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "sceneCenter")
        elseif self.fixPoint == 4 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "Densearea", self.radius)
        elseif self.fixPoint == 5 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "selfFrontCenter")
        elseif self.fixPoint == 6 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "selfBackCenter2")
        elseif self.fixPoint == 7 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "enemyFrontCenter")
        elseif self.fixPoint == 8 then
            position = SelectTargetTool:findFixPoint(self.playerBuf.player, "enemyBackCenter2")
        end
        
        self.pos.x = position.x
        self.pos.z = position.z
    end
end

function M:get_position()
    return self.pos;
end

function M:work()
    M.super.work(self)
    if (self.radius > 0 or self.isRectangleArea) and self.playerBuf.source ~= nil then
        local players = nil
        if self.side == 1 then
            players = SceneManager.curScene.plyMgr:getPlayers(self.playerBuf.source:get_camp())
        elseif self.side == 2 then
            players = SceneManager.curScene.plyMgr:getPlayers(-self.playerBuf.source:get_camp())
        elseif self.side == 3 then
            players = Battle.List.new()
            players:add(self.playerBuf.player)
        end
        if players ~= nil then
            local workCount = 0
            for i = 1, players.Count do
                local player = players:get(i - 1)
                if player ~= nil and player:isLive() then
                    if self:isInBuffRange(player) then
                        player.bufMgr:addBufById(self.buffid, self.playerBuf.source, self.playerBuf.sourceSkill)
                        workCount = workCount + 1
                    end
                end
                self:checkDestroyByRealWorkCount(workCount)
            end
        end
    end
end

-- 检查是否达到真正生效次数并销毁
function M:checkDestroyByRealWorkCount(workCount)
    if self.realWorkCount > 0 and self.realWorkCount >= workCount then
        self.playerBuf.mgr:removeBuf(self.playerBuf)
    end
end

---@param player PlayerModel
function M:isInBuffRange(player)
    if self.isRectangleArea then
        -- 矩形范围检测
        local vec = player.position - self.pos 
        if Mathf.Abs(vec.x) > self.areaHeight then
            return false
        elseif Mathf.Abs(vec.z) > self.areaWidth then
            return false
        end
        return true
    else
        -- 圆形范围检测
        if GlobalTools:Distance(player.position, self.pos or self.playerBuf.player.position) <= GlobalTools:ToFix2(self.radius) then
            return true
        end 
    end
    return false
end

return M