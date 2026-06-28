local SceneManager = SceneManager
local tonumber = tonumber

--蓬莱五鬼
---@class GhostsShowSkillScene_Model : SceneArrayBase_Model @
---@field super SceneArrayBase_Model @SceneArrayBase_Model
local M = class("GhostsShowSkillScene_Model",Battle.SceneArrayBase_Model)

--初始化场景
function M:init()
	M.super.init(self)
	self.use_hov = true;
	self.scene_config = ConfigManager:getCfgByName("scene_config");
end


--进入场景
function M:enter(data)
	M.super.enter(self, data)
end

--加载完成
function M:loadFinish( data )
	M.super.loadFinish(self, data)
	if self.isDestoryMe then
		return;
	end
	SelectTargetTool:resetFixPoint()
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

function M:playPlayerSkill(skill_name)
    local hero_list = self.plyMgr.hero_list
	for i= hero_list.Count,1,-1 do
		local player = hero_list:get(i-1)
		player:useSkill(skill_name, true)
		if player.animator.curState then
			return player
		end
	end
	return nil
end


function M:canAutoUseBigSkillHero()
	return true;
end

return M
