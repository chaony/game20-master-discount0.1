
--威仪之戒 战斗中附近没有敌方单位时，增加7%攻击力 每隔十五秒击退附近敌人

local Artifact6_2 = require("Battle.Artifact.Artifact6_2")


---@class Artifact6_5 : Artifact6_2 @
---@field super Artifact6_2 @Artifact6_2
local M = class("Artifact6_5", Artifact6_2)

M.buffCurveMoveDistance = nil
M.buffCurveMoveTime = nil
M.attackMoveDir = nil
M.useSceneDir = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.atk =  self:getValue(2)
    self.buffCurveMoveDistance =  self:getValue(4)
    self.buffCurveMoveTime =  self:getValue(5)
    self.useSceneDir =  self:getValue(6) > 0
    self.time = self:getValue(3)
end

function M:operationEnemy()
    M.super.operationEnemy(self)
    local  bufData = 
    {
    	["count"] = "one",
        ["camp"] = "all",
        ["campRace"] = "enemy",
        ["pos"] = "not",
        ["profession"] = "all",
        ["area"] = "sector",
        ["areaWidth"] = "",
        ["areaHeight"] = "",
        ["areaAngle"] = 360,
        ["areaRadius"] = self.distance,
        ["forceSelect"] = true,
        ["buffType"] = "FouceMove",
        ["buffDes"] = "",
        ["workRound"] = 1,
        ["lastTime"] = self.buffCurveMoveTime,
        ["workTime"] = 0,
        ["delayTime"] = 0,
        ["buffParam"] =
        {
        	["buffCurveMoveType"] = "injureBack",
            ["buffCurveMoveDistance"] = self.buffCurveMoveDistance,
            ["buffCurveMoveTime"] = self.buffCurveMoveTime,
            ["attackMoveDir"] = "back",
            ["useSceneDir"] = self.useSceneDir,
        },
        ["buffEffect"] =
        {
        },
        ["buffTags"] =
        {
            [1] = "debuff",
        },
    }

    local list = self.player.plyMgr:getPlayers(-self.player:get_camp()):clone()

    for i=list.Count,1,-1 do
        local ply = list:get(i-1)
        --计算我的和敌人之间的方向
        local vec = ply.position - self.player.position
        local nor_vec = FixVector3.Normalize(vec)
        if vec:SqrMagnitude() > GlobalTools:ToFix2( self.distance ) then
            list:remove(ply)
        else
                --得到角度
            local tmpAngle = Mathf.Acos( FixVector3.Dot( nor_vec, self.player.position:forward() )) * Mathf.Rad2Deg;
            if tmpAngle > 360 * 0.5 then
                list:remove(ply)
            end
        end
    end
    
    for i=list.Count,1,-1 do
    	local enemy_ply = list:get(i-1)
        local dir =self.player.position - enemy_ply.position

        if self.useSceneDir then
            enemy_ply:setForward(FixVector3.Normalize(dir))
        else
            dir.z = 0
            enemy_ply:setForward(FixVector3.Normalize(dir)) 
        end
    	enemy_ply.bufMgr:addBuf(bufData, self.player)
    end
    
end

return M