--场景向导
--主要用于指引玩家去移动
--尤其是多人组队
---@class SceneGuide_View @
local M = class("SceneGuide_View")

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
--当前速度
M.curSpeed = 0
--移动Index
M.move_index = 0
--是否第一次移动
M.fristMove = false
--模式 mode 1 无线循环 2 反复跑
M.mode = 1
--初始化导航
function M:init( obj, scene, model )
    --导航模式
    self.mode = model:get_mode();
    --场景视图
    self.scene = scene;
    self.gapPos = FixVector3(40, 0, 0)
    self.modeController = require("BattleView.Sce.Guide.SceneGuideMode"..self.mode.."_View")
    self.modeController:init( obj, scene, self.mode )
end

--开始运行
function M:play()
    if self.modeController ~= nil then
        self.modeController:play();
    end
end

--销毁
function M:destroy()
    if self.modeController ~= nil then
        self.modeController:destroy();
        self.modeController = nil;
    end
end

--停止移动
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
                                    
--下一个目标
--寻找下一个目标
function M:next()
    if self.modeController ~= nil then
        self.modeController:next();
    end
end

-- 获取指引中的点
function M:getPoint( index )
    if self.modeController ~= nil then
        return self.modeController:getPoint( index )
    end
    return nil;
end

--重新设置引导
function M:resetCurGuide()
    if self.modeController ~= nil then
        self.modeController:resetCurGuide()
    end
end

--更新导航
function M:update(dt,unsdt)
    if self.modeController ~= nil then
        self.modeController:update(dt,unsdt)
    end
end

return M