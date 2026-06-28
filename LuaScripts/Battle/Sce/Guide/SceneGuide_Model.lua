--场景向导
--主要用于指引玩家去移动
--尤其是多人组队
---@class SceneGuide_Model @
local M = class("SceneGuide_Model")

--SceneGuide
M.sceneGuide = nil

--是否开启运动模式
M.moving = false
--导航模式
M.mode = 1
--路径点
M.pathIndex = 0
--是否在回去的状态
M.inBack = false
--最大速度
M.maxSpeed = 4
--移动Index
M.move_index = 0
--是否第一次移动
M.fristMove = false
--模式 mode 1 无线循环 2 反复跑
M.mode = 1
--初始化导航
function M:init( scene, mode )
	self.mode = mode;
	self.scene = scene;
	--场景向导 数据层 创建完成
	self.scene:dispatchEvent_Local(Battle.EventType.MV_SceneGuideModelCreateFinish, self);
	
	self.modeController = require("Battle.Sce.Guide.SceneGuideMode"..mode.."_Model")
	self.modeController:init( scene, mode )
end

--获取导航 模式
function M:get_mode()
	return self.mode;
end

--继续
function M:play()
	if self.modeController ~= nil then
		self.modeController:play();
	end
end

--停止
function M:stop()
	if self.modeController ~= nil then
		self.modeController:stop();
	end
end

--是否正在移动
function M:moving()
	if self.modeController ~= nil then
		return self.modeController.moving;
	end
	return false;
end

-- 获取指引中的点
function M:getPoint( index )
	if self.modeController ~= nil then
		return self.modeController:getPoint( index )
	end
	return nil;
end

function M:getFixPosition()
	if self.modeController ~= nil then
		return self.modeController:getFixPosition()
	end
	return nil;
end

function M:startGoto(chase_count)
	if self.modeController ~= nil then
		self.modeController:startGoto(chase_count)
	end
end

function M:getCanStartFlag()
	if self.modeController ~= nil then
		return self.modeController:getCanStartFlag()
	end
	return nil;
end

--更新
function M:update(dt,unsdt)
	if self.modeController ~= nil then
		self.modeController:update(dt,unsdt)
	end
end

--销毁
function M:destroy()
	if self.modeController ~= nil then
		self.modeController:destroy();
		self.modeController = nil;
	end
end

return M