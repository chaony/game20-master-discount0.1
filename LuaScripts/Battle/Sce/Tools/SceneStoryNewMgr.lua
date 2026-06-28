--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:16
]]

---@class SceneStoryNewMgr @
local M = class("SceneStoryNewMgr")

function M:init()
	self.battleStoryPlayerList = Battle.List.new();
end

--初始化场景
function M:arrayingStoryPlayers( callBack )
	--场景数据
	self.scene_model = SceneManager:getCurSceneModel();
	--场景视图
	self.scene_view = SceneManager:getCurSceneView();
	
	local level = UserDataManager:getBattleStage();
	self.scenario_config = ConfigManager:getCfgByName("scenario_config")
	self.scenario_info = ConfigManager:getCfgByName("scenario_info")
	self.levelData = self.scenario_config[tostring(level)];
	if self.levelData ~= nil then
		--入场直接触发的剧情自动触发
		self.enter_dialog = self.levelData.enter_dialog;
		if callBack ~= nil then
			callBack()
		end
		--触发开场剧情
		local data = {}
		data.talk_id = self.enter_dialog
		data.callback = function( event_data )
			--对话结束
			--入场方向【1=左，2=右】
			self.enterDir = self.levelData.enter;
			
			self.scene.gameover = false;
			--优先去表中的id
			--取不到
			--去取人物头像人物
			--取不到
			--取挂机战力最大的人物
			self.mainPlayerId = self:getMainPlayer();
			local data = {id = self.mainPlayerId}
			local player = self.scene.plyMgr:createPlayer(data,1,-1,nil,nil)
			player.loadFinish = function( player_view )
				self.main_story_player = player_view;
				self.main_story_player.tran.localScale = Vector3(1,1,1);
				--摄像机跟随
				self.scene_view.cameraController.camera_move = true;
				self.scene_view.cameraController.Target = self.main_story_player.tran;

				if not IsNull(self.main_story_player.tran) then
					--玩家旋转方向
					if self.enterDir == 1 then
						self.main_story_player:setPos( FixVector3(-10,0,0), true );
						self.main_story_player:setForward( FixVector3.right() * 1, true )
					else
						self.main_story_player:setPos( FixVector3( 10,0,0), true );
						self.main_story_player:setForward( FixVector3.right() * -1, true )
					end
					self.main_story_player.data:set_curHp(100);
					self.main_story_player.aiEngine.enableAI = true;
					self.main_story_player.plyState = 1;
					self.main_story_player.aiEngine:changeState("storySpawnNew");
				end
			end

			--剧情配置信息
			self.config_scenario_info = self.levelData.scenario_info;
			local index = #self.config_scenario_info;
			--循环
			for k,v in ipairs(self.config_scenario_info) do
				local info_data = self.scenario_info[tostring(v)];
				local story_player = require("Battle.Ply.PlayerStory").new();
				local isFinish = false;
				story_player:init(v, info_data, self.scene.prefabs, self, isFinish, function()
					index = index - 1;
					if index == 0 then
						CS.GameObjectClickMgr.Inst:Register("ClickObj", handler(self,self.clickObject))
						CS.GameObjectClickMgr.Inst:GetListeners();
						self:UpdateAppearCondition();
					end
				end)
				self.battleStoryPlayerList:add(story_player);
			end
		end
		static_rootControl:updateMsg("talk", data, "Formation")
	else
		Logger.logWarning(" levelData 数据为空 ~~~~")
	end
end


function M:getMainPlayer()
	--人物id  self.levelData.model
	--不是模型 是id 
	if self.levelData.model ~= nil then
		return tonumber(self.levelData.model)
	else
		--配置人物
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(UserDataManager.user_data.user_status.avatar))
		if cfg ~= nil then
			return tonumber(UserDataManager.user_data.user_status.avatar);
		end
	end
	--获取到挂机阵容
	local hangUpData = UserDataManager.hero_data:getStagePassTeam()
	for k,v in pairs(hangUpData) do
		if v ~= "" then
			local data,cfg = UserDataManager.hero_data:getHeroDataById(v);
			return tonumber(data.id);
		end
	end
end



--更新显示条件
function M:UpdateAppearCondition()
	local showOrders = {}
	local index = 1;
	for i = 1, self.battleStoryPlayerList.Count do
		local storyPlayer = self.battleStoryPlayerList:get(i-1);
		if storyPlayer.isFinish then
			showOrders[index] = storyPlayer.order;
			index = index + 1;
		end
	end
	
	Logger.log(" self.battleStoryPlayerList "..self.battleStoryPlayerList.Count )

	for i = 1, self.battleStoryPlayerList.Count do
		local storyPlayer = self.battleStoryPlayerList:get(i-1);
		storyPlayer:UpdateAppearCondition(showOrders);
	end
end

--点击物体
function M:clickObject( obj, name, index )
	local order_str_arr = string.split(obj.name,"_");
	local order = order_str_arr[2];
	Logger.log(" 点击 "..obj.name.." order "..order )
	local storyPlayer = self:getStoryPlayerByOrdler(tonumber(order));
	if storyPlayer ~= nil then
		storyPlayer:running();
	end
end

--通过Order 获取 StoryPlayer
function M:getStoryPlayerByOrdler( order )
	for i = 1, self.battleStoryPlayerList.Count do
		local storyPlayer = self.battleStoryPlayerList:get(i-1);
		if storyPlayer.order == order then
			return storyPlayer;
		end
	end
end

--销毁所有StoryPlayer
function M:destroyStoryPlayers()
	if self.scene ~= nil then
		for i = 1, self.battleStoryPlayerList.Count do
			local storyPlayer = self.battleStoryPlayerList:get(i-1);
			if storyPlayer ~= nil then
				storyPlayer:destroy()
			end
		end

		if self.main_story_player ~= nil then
			self.main_story_player = nil;
		end

		self.scene.plyMgr:destroy();
		
		self.battleStoryPlayerList:clear();
		self.scene = nil;
	end
end


return M