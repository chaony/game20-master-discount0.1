--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:16
]]

local SceneManager = SceneManager
local tonumber = tonumber

--战斗场景
---@class FightScene_View : SceneArrayBase_View @
---@field super SceneArrayBase_View @SceneArrayBase_View
local M = class("FightScene_View",Battle.SceneArrayBase_View)

--初始化场景
function M:init(model)
	M.super.init(self, model)
	self.use_hov = true;
	self.scene_config = ConfigManager:getCfgByName("scene_config");
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
	Logger.logError(" 场景id "..self.m_data.mode )
	if self.m_data ~= nil and self.m_data.mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
		self:createSceneConfig(108)
	elseif self.m_data ~= nil and self.m_data.mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_data ~= nil and self.m_data.mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
			and self.m_data.mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS and self.m_data.mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		self:createSceneConfig(108)
	elseif self.m_data ~= nil and self.m_data.mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA then
		self:createSceneConfig(122)
	elseif self.m_data ~= nil and self.m_data.mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		local sceneNameId = 101
		if self.model and self.model.m_data and self.model.m_data.common then
			local map_id = self.model.m_data.common.sub_param
			if map_id and map_id ~= 0 then
				sceneNameId = map_id
			end
		end
		self:createSceneConfig(sceneNameId)
	else
		local level = UserDataManager:getBattleStage();
		self.chapter = ConfigManager:getCfgByName("stage")[level];
		self:createSceneConfig(tonumber(self.chapter.battle_scene))
	end
	return self.scene_info.resource;
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