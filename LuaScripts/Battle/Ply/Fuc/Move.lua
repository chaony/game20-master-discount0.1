
--移动帧基类
---@class Move @
---@field player PlayerModel
---@field target PlayerModel
local M = class("Move")
--目标数量（selectTarget选取目标的data数据）
M.count = nil
--当前玩家（移动的玩家）
M.player = nil
--整体移动数据
M.data = nil
--目标
M.target = nil
--相对于目标的位置
M.targetPos = nil
--是否使用场景方向
M.useSceneDir = nil
--是否朝向目标
M.faceToTarget = nil
--是否重新索敌
M.isAnewEnemy = nil
--是否完成
M.finish = false

--初始化
---@param type EAttackMoveType
---@param player PlayerModel
---@param data Battle_Frame_Data
function M:init(type, player,data)

    local pathName = "Battle.Ply.Fuc."
    if type == nil then
        type = "MoveGeneral"
    end
    local typeName = type
    if Battle.ClassPathUtil:Exists(pathName..type) == false then
        typeName = "MoveGeneral"
    end
    self.move_fuc = require("Battle.Ply.Fuc.".. typeName ).new();
    
    self.move_fuc:init(self, player,data)
end

function M:moveDir(tarPos,plyPos)
    self.move_fuc:moveDir(tarPos,plyPos);
end

function M:moveStart()
    self.move_fuc:moveStart()
end
--清空数据
function M:clear()
    self.move_fuc:clear();
end
--子弹阵亡
function M:dead()
    self.move_fuc:dead();
end 
function M:update(dt)
   self.move_fuc:update(dt);
end
function M:moveBack(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveBack(tarPos,plyPos,target);
    end
end

function M:moveFront(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveFront(tarPos,plyPos,target);
    end
end

function M:moveLeft(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveLeft(tarPos,plyPos,target);
    end
end

function M:moveRight(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveRight(tarPos,plyPos,target);
    end
end

function M:moveUp(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveUp(tarPos,plyPos,target);
    end
end

function M:moveDown(tarPos,plyPos,target) 
    if self.move_fuc ~= nil then
        return self.move_fuc:moveDown(tarPos,plyPos,target);
    end
end


function M:setPos(pos)
   self.move_fuc:setPos(pos);
end


function M:destroy()
    self.finish = true
    self.move_fuc:destroy()
end

return M