local SceneManager = SceneManager
local tonumber = tonumber

--蓬莱五鬼
---@class GhostsShowSkillScene_View : SceneArrayBase_View @
---@field super SceneArrayBase_View @SceneArrayBase_View
local M = class("GhostsShowSkillScene_View",Battle.SceneArrayBase_View)

--初始化场景
function M:init(model)
	M.super.init(self, model)
	self.use_hov = true;
end


--进入场景
function M:enter(data)
	M.super.enter(self, data)
	self:setFog();
end


function M:setFog()
	U3DUtil:Set_RenderSettings_Fog_Distance(150)
end

--加载完成
function M:loadFinish( data )
	M.super.loadFinish(self, data)
	if self.isDestoryMe then
		return;
	end
	
    --游戏结束
    self.gameover = true
    --初始化阶段
	self:set_sceneState(0)
end

--子类重写
function M:getCurSceneName()
	return "ghosts_show_skill";
end

--场景文件
function M:getCurSceneObjName()
	return "fightscene_data_w"
end

--加载场景
function M:loadScene( data )
	M.super.loadScene(self)
	self:loadSceneItem()
end

--加载美术场景
function M:loadSceneItem()
    M.super.loadSceneItem( self )
    if self.obj ~= nil then
        --场景的根节点
        self.guide = nil
        self.sceneRoot = self.obj.transform:Find("Scene_Root")
		self.gridRoot = self.obj.transform:Find("gridRoot");
		self:setSceneInstancePosition(false);
	end
end

function M:update_dt(dt)
	M.super.update_dt(self,dt)
end


--总是更新的场景
function M:updateAlways(dt)
	M.super.updateAlways(self,dt)
end


--设定CameraPosition
function M:setCameraPosition( isZhanDou )
	
end


return M