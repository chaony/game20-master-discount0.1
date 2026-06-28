--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:16
]]

local SceneManager = SceneManager
local tonumber = tonumber

--战斗场景
---@class LegendFightScene_View : SceneArrayBase_View @
---@field super SceneArrayBase_View @SceneArrayBase_View
local M = class("LegendFightScene_View",Battle.SceneArrayBase_View)

--初始化场景
function M:init(model)
	M.super.init(self, model)
	self.use_hov = true;
	self.scene_config = ConfigManager:getCfgByName("scene_config");
	--更新击杀数量
	self:addEventListener_Local(Battle.EventType.MV_LegendFightSceneModelUpdateKillNum,{self,self.MV_LegendFightSceneModelUpdateKillNum})
	self:addEventListener_Local(Battle.EventType.MV_LegendFightSceneModelUpdateBuff,{self,self.MV_LegendFightSceneModelUpdateBuff})
	
end


--进入场景
function M:enter(data)
	M.super.enter(self, data)

end

function M:MV_SceneModelArray( eventName, data )
	M.super.MV_SceneModelArray(self, eventName, data)
	local legend_stage_table = ConfigManager:getCfgByName("legend_stage");
	LikeOO.BattleTalkControl:registerBattleTalk(self.model.mode, legend_stage_table[data.ext_data.battle_id].talk)
	LikeOO.BattleTalkControl:checkBattleTalk(4)
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
	return "legend";
end

--场景文件
function M:getCurSceneObjName()
	return "fightscene_data_w"
end

--加载场景
function M:loadScene( data )
	M.super.loadScene(self, data)
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

--更新
function M:view_update(dt,unsdt)
	M.super.view_update(self, dt, unsdt)
	LikeOO.BattleTalkControl:checkBattleTalk(3, GlobalTools:ToFloat(self.model.curTime))
end


--总是更新的场景
function M:updateAlways(dt)
	M.super.updateAlways(self,dt)
end


--设定CameraPosition
function M:setCameraPosition( isZhanDou )
	
end

--战斗开始
function M:MV_SceneModelBattleStart(eventName, data)
	if static_rootControl then
		for k,v in pairs(static_rootControl.m_chilrenList) do
			if v.m_model and v.m_model:getName() == "GamePanel" then
				self.gamePanel = v
			end
		end
	end
end

--更新击杀数量
function M:MV_LegendFightSceneModelUpdateKillNum(eventName, data)
	if self.gamePanel ~= nil then
		self.gamePanel:refresh_kill_num(data.killNum)
	end
	LikeOO.BattleTalkControl:checkBattleTalk(2, data.killNum)
end

--更新击杀数量
function M:MV_LegendFightSceneModelUpdateBuff(eventName, data)
	--if self.gamePanel ~= nil then
	--	self.gamePanel:refresh_buff_attr(data.attr)
	--end
end

function M:destroy( nextScene )
	LikeOO.BattleTalkControl:closeTalk()
	M.super.destroy(self, nextScene)
end

return M