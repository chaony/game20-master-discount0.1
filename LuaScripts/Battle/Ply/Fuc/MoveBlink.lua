
--技能帧
---@class MoveBlink : MoveGeneral @
---@field super MoveGeneral @MoveGeneral
local M = class("MoveBlink",MoveGeneral)

--[[
    @desc: 初始化技能 
    author:{author}
    time:2020-01-10 10:22:43
    --@skillData: 
    @return:
]]
function M:init(move,player,data)
    M.super.init(self, move, player, data)
end

function M:update(dt)
   
end


function M:moveSetPos(tarPos,dir,target)
    M.super.moveSetPos(self, tarPos, dir, target)
    local pos = tarPos + dir * self.move.distance
    if self.move.ignoreArea ~= true then
        if SceneManager.curScene.getAreaPosition ~= nil then
            local lastPos = pos:Clone()
            SceneManager.curScene:getAreaPosition(pos)
            if lastPos ~= pos then
                dir = dir * -GlobalTools.base1
                pos = tarPos + dir * self.move.distance
                local forward = dir:Clone()
                if self.move.faceToTarget == false then
                    forward = forward * -GlobalTools.base1
                end
                self.move.player:setForward( forward )
            end
        end
    end
    
    local lastPos = self.move.player.position:Clone()
    if  SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS or SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
        if target.camp == 1 then
            self.move.player:setPos(pos, true);
        end
    else
        self.move.player:setPos(pos, true);
    end
    
    local faceDir = dir
    if self.move.target ~= nil then
        GlobalTools:Dir(self.move.target.position, self.move.player.position)
    end
    if self.move.faceToTarget == true and self.move.target ~= nil then
        self.move.player:setForward( faceDir * -GlobalTools.base1)
    else
        self.move.player:setForward( faceDir )
    end
    
    local effect_dir = pos - lastPos
   
    if self.move.data["effect"] ~= nil and self.move.data["effect"] ~= "" and self.move.data["effect"] ~= "nil" then
        local effectData = {}
        effectData["prefab"] = self.move.data["effect"]
        effectData["autoMirror"] = false

        effectData["isPutUpInParent"] = false
        effectData["autodestoryTime"] = 2
        effectData["directionType"] = "world"
        effectData["scaleType"] = "parent"
        effectData["positionType"] = "worldFix"
        effectData["parent"] = "effectpoint0"

        local prefabTrans = {}
        prefabTrans["useUserSet"] = true

        prefabTrans["position"] =
        {
            [1] = GlobalTools:ToFloat(pos.x),
            [2] = GlobalTools:ToFloat(pos.y),
            [3] = GlobalTools:ToFloat(pos.z),
        }

        prefabTrans["rotation"] = {
            [1] = GlobalTools:ToFloat(effect_dir.x),
            [2] = GlobalTools:ToFloat(effect_dir.y),
            [3] = GlobalTools:ToFloat(effect_dir.z),
        }
        prefabTrans["scale"] = {
            [1] = 1,
            [2] = 1,
            [3] = 1,
        }
        effectData["prefabTrans"] = prefabTrans
        self.move.player:playEffect( effectData ,self.move.player, self.move.player );
    end
    self.move:destroy()
end


function M:destroy()
    self.move.finish = true
    self.move.player.moveMgr:removeMove(self.move)
end

return M