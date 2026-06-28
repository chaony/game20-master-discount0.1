---@class BattleState @战斗状态机
---@field name string
---@field curScene SceneArrayBase_Model
local M = class("BattleState")

function  M:init(stateName, battleScene)
	self.name = stateName
	self.curScene = battleScene
end

function M:enter()
    
end

function M:exit()
    
end

function M:finish()
    
end

function M:update(dt)
    
end

--销毁
function M:destroy()
    
end

return M