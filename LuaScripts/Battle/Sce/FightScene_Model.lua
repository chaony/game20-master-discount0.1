--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:16
]]

local SceneManager = SceneManager
local tonumber = tonumber

--挂机场景
---@class FightScene_Model : SceneArrayBase_Model @
---@field super SceneArrayBase_Model @SceneArrayBase_Model
local M = class("FightScene_Model",Battle.SceneArrayBase_Model)

--初始化场景
function M:init()
	M.super.init(self)
	self.use_hov = true;
	self.scene_config = ConfigManager:getCfgByName("scene_config");
end


--进入场景
function M:enter(data)
	M.super.enter(self, data)
	if data.mode and data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		self.maxTime =  ConfigManager:getBattleCommonValueById(909,GlobalTools.base90, true);
	else
		self.maxTime = data.max_time or GlobalTools.base90
	end
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
	local data = self.m_data or {}
	--- 处理服务器数据(使用服务器参数param与sub_param付给客户端数据）
	if data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.RACE_TOWER then -- 种族塔
		data.race = data.common.sub_param
	end
	--武道场的场景单独配置 
	if data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.RAID then
		if self.m_raid_sort ~= nil then
			local raid = ConfigManager:getCfgByName("raid_open")
			local raid_item = raid[self.m_raid_sort]
			local scene = raid_item.scene;
			return scene;
		end
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA then
		self:createSceneConfig(122)
		return self.scene_info.resource;
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE or data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
		self:createSceneConfig(119)
		return self.scene_info.resource;
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
		return "legend";
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE then
		local chapter = ConfigManager:getCfgByName("gve_stage")[self.m_stage_id];
		if chapter then
			local sceneNameId = chapter.battle_scene
			self:createSceneConfig(sceneNameId)
			return self.scene_info.resource; 
		end
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_FATE then --侠客情缘，根据配置切换场景
		local sceneNameId = data.common.battle_scene or data.common.param
		--local sceneNameId = data.common.param
		self:createSceneConfig(sceneNameId)
		return self.scene_info.resource
	elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then --侠客情缘，根据配置切换场景
		local sceneNameId = 114 --写死场景
		--local sceneNameId = data.common.param
		self:createSceneConfig(sceneNameId)
		return self.scene_info.resource
	else
		if self.m_data.race ~= nil then
			if self.m_data.race ~= 0 then
				local tower_race = ConfigManager:getCfgByName("tower_race")
				local race_item = tower_race[self.m_data.race];
				self:createSceneConfig(race_item.scene)
			else
				self:createSceneConfig(105)
			end
		else
			local mode_cfg_item = Battle.BattleGlobalConfig.BATTLE_MODE_CFG[data.mode or -1]
			if mode_cfg_item == nil then
				local mode = Battle.BattleGlobalConfig.SCENE_ID_CFG[self.sceneId] or -1
				mode_cfg_item = Battle.BattleGlobalConfig.BATTLE_MODE_CFG[mode]
			end
			if mode_cfg_item and mode_cfg_item.scene_id then
				self:createSceneConfig(mode_cfg_item.scene_id)
			else
				local sceneNameId = 101;
				if self.m_stage_id ~= -999 then
					self.chapter = ConfigManager:getCfgByName("stage")[self.m_stage_id];
					sceneNameId = self.chapter.battle_scene
				end
				if data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.BIG_MAP then
					--服务器战斗时，没有UserDataManager数据 --需要从服务器端数据m_data中获取
					local map_id = self.m_data.common and self.m_data.common.sub_param
					if not map_id and UserDataManager then
						map_id = UserDataManager:getTempData("regional_battle_map_id")
					end
					local regional_map = ConfigManager:getCfgByName("regional_map")
					local scene_id = regional_map[map_id] and regional_map[map_id].battle_scene
					if scene_id and scene_id ~= 0 then
						sceneNameId = scene_id
					end
				elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
					--服务器战斗时，没有UserDataManager数据 --需要从服务器端数据m_data中获取
					local map_id = self.m_data.common and self.m_data.common.sub_param
					if not map_id and UserDataManager then
						map_id = UserDataManager:getTempData("new_regional_battle_map_id")
					end
					local regional_map = ConfigManager:getCfgByName("new_regional_map")
					local scene_id = regional_map[map_id] and regional_map[map_id].battle_scene
					if scene_id and scene_id ~= 0 then
						sceneNameId = scene_id
					end
				elseif data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
					--服务器战斗时，没有UserDataManager数据 --需要从服务器端数据m_data中获取
					local scene_id = self.m_data.common and self.m_data.common.sub_param
					if scene_id and scene_id ~= 0 then
						sceneNameId = scene_id
					end
				end
				self:createSceneConfig(sceneNameId)
			end
		end
		return self.scene_info.resource;
	end
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
