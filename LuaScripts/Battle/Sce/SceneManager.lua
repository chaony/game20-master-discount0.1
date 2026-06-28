---@class SceneManager 场景管理器
---@field curScene Scene_Model | SceneArrayBase_Model
---@field nextScene Scene_Model
---@field scenePool Scene_Model[]
SceneManager = {}
--当前的场景名字
SceneManager.curSceneName = "";
--重力
SceneManager.gravity = GlobalTools.base60;
SceneManager.init_flag = false

--是否是运行在客户端的还是服务器上的

SceneManager.SceneID = Battle.BattleGlobalConfig.SCENE_ID

--场景状态
-- 0 初始化状态
-- 1 准备阶段
-- 2 准备运行阶段
-- 3 正式运行阶段
-- 4 停止阶段
SceneManager.SceneState = 
{
	SceneInit = 0,
	SceneReady = 1,
	SceneReadyRun = 2,
	SceneRunning = 3,
	SceneStop = 4,
}


function SceneManager:init(scendid)
	if self.init_flag then
		return
	end

	if GameVersionConfig.IS_SERVER == false then
		SceneManager:initEvent()
	end

	TimeManager:init();
	SceneManager:createSceneClient();
	
	--当前游戏的 更新时间
	SceneManager.curGameDelayTime = GlobalTools.base0;
	SceneManager.delayFrame = GlobalTools.base0;

	--人物抖动的曲线数据
	ResourceUtil:LoadConfigObject("BattleSceneConfig", function(sceneConfig)
		--人物曲线异步加载 
		self.battleSceneConfig = sceneConfig;
	end)
	--加载曲线
	GlobalTools:LoadCurveData()
	--切换到挂机场景
	if scendid > 0 then
		self:changeScene(scendid or 1);
	end
	SceneManager.start = true
	SceneManager.scene_pause = false;
	
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.netDataUpdateEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	
	SceneManager.lastScene = SceneManager.SceneID.HangUpScene;
	self.init_flag = true

	SceneManager.gameGlobalConfig = ResourceUtil:LoadGameGloballConfig()
end


function SceneManager:initEvent()
	--视图和数据层的事件管理器
	self.MV_EventMgr = require("Battle.Evt.EventManager");
	self.MV_EventMgr:init();
	self.MV_EventMgr:addEventListener(Battle.EventType.MV_SceneModelCreateFinish,{self, self.MV_SceneModelCreateFinish})
	self.MV_EventMgr:addEventListener(Battle.EventType.MV_TimeManagerSetTime, {self, self.MV_TimeManagerSetTime})
end


--监听SceneArrayBaseModel初始化完成
function SceneManager:MV_SceneModelCreateFinish( eventName, model )
	if SceneManager.scenePoolView == nil then
		SceneManager.scenePoolView = {}
	end
	local scene_view = require("BattleView.Sce."..model.scriptName.."_View").new()
	--注册视图和数据层
	self.MV_EventMgr:register(scene_view, model);
	--场景id
	scene_view.sceneId = model.sceneId;
	--场景脚本名字
	scene_view.scriptName = model.scriptName;
	--场景名字
	scene_view.sceneName = model.sceneName;
	--场景类型
	scene_view.sceneType = model.sceneType;
	scene_view:init( model );
	SceneManager.scenePoolView[model.sceneId] = scene_view;
end

--接到改变时间的时间，通知Unity改变时间
function SceneManager:MV_TimeManagerSetTime(eventName, data)
	if data.baseUpdateDelaTime ~= nil then
		TimeManager_View:set_baseUpdateDelaTime( data.baseUpdateDelaTime );
	end
	if data.timeSpeed ~= nil then
		TimeManager_View:set_timeSpeed( data.timeSpeed );
	end
	if data.timeScale ~= nil then
		TimeManager_View:set_timeScale( data.timeScale );
	end
	if data.timePause ~= nil then
		TimeManager_View:set_timePause( data.timePause );
	end
end



function SceneManager:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.netDataUpdateEvent})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
end


function SceneManager:openViewEvent(event, data)
	local view_count = static_rootControl:getChildCount()
	if view_count == 1 then
		if static_rootControl:hasChild("Guide.GuideDialog") or static_rootControl:hasChild("Pops.BeginPop") then
			return
		end
	elseif view_count == 0 then
		return
	end
	if SceneManager.curScene ~= nil and SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		SceneManager:pause();
	end
end

function SceneManager:closeViewEvent(event, data)
	if static_rootControl:checkHasChild() == false then
		SceneManager:continue();
	end
end

--更新chche数据
function SceneManager:netDataUpdateEvent(evesnt, data)
    SceneManager:responseGameData(data.data)
end

--
function SceneManager:responseGameData(data)
    local chche = data.client_cache_update
    if chche ~= nil and chche.rpg_map ~= nil then
        SceneManager:listenToNet(chche.rpg_map)
    end 
end

--监听服务器的chche数据更新
function SceneManager:listenToNet( rpg_map_data )
    local block_net_data = SceneManager:getData("shiguang_block_net_data")
    if block_net_data ~= nil then
        local blocks = rpg_map_data.blocks;
        if blocks ~= nil then
            for i,v in pairs(blocks.update) do
				block_net_data.blocks[i] = v;
            end
            for i,v in pairs(blocks.remove) do
                if block_net_data.blocks[i] ~= nil then
                    block_net_data.blocks[i] = nil;
                end
            end
        end
        local curblock = rpg_map_data.cur_block;
        if curblock ~= nil then
            block_net_data.cur_block = curblock;
        end
		SceneManager:setData("shiguang_block_net_data",block_net_data);
    end
end

--注册场景
function SceneManager:registerScene(sceneId, sceneScriptName, sceneName, sceneType)
	if SceneManager.scenePool == nil then
		SceneManager.scenePool = {}
	end
	local scene = require("Battle.Sce."..sceneScriptName.."_Model")
	local scene_inst = scene.new();
	scene_inst:init();
	--场景id
	scene_inst.sceneId = sceneId;
	--场景脚本名字
	scene_inst.scriptName = sceneScriptName;
	--场景名字
	scene_inst.sceneName = sceneName;
	--场景类型
	scene_inst.sceneType = sceneType;
	scene_inst:SceneModelCreateFinish();
	--存储到池中
	SceneManager.scenePool[sceneId] = scene_inst;
end


--获取当前场景 view 类
function SceneManager:getCurSceneView()
	return SceneManager.scenePoolView[self.curScene.sceneId];
end

--获取当前场景 model 类
function SceneManager:getCurSceneModel()
	return self.curScene;
end

function SceneManager:createSceneServer()
	--注册 战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.FightScene,"FightScene","chapter","chapter");
end

--创建场景
function SceneManager:createSceneClient()
	--注册 挂机 场景
	SceneManager:registerScene(SceneManager.SceneID.HangUpScene,"HangUpScene","chapter","chapter");
	--注册 战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.FightScene,"FightScene","chapter","chapter");
	--注册 Boss 场景
	SceneManager:registerScene(SceneManager.SceneID.BossScene,"BossScene","boss","boss");
	--注册 侠客试炼 场景
	SceneManager:registerScene(SceneManager.SceneID.HeroTrainScene,"BossScene","chapter","chapter");
	--注册 天机楼 场景
	SceneManager:registerScene(SceneManager.SceneID.TianJiLouScene,"TianJiLouScene","tianjilou","tianjilou");
	--注册 迷宫 场景
	SceneManager:registerScene(SceneManager.SceneID.MiGongScene,"MiGongScene","migong","migong");
	--注册 先贤祠 场景
	SceneManager:registerScene(SceneManager.SceneID.PantheonScene,"PantheonScene","pantheon","pantheon");
	--注册 天机楼战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.TianjiLouFightScene,"TianjiLouFightScene","tianjiloufight","tianjilou");
	--注册 人物进阶 场景
	SceneManager:registerScene(SceneManager.SceneID.AdvancedScene,"AdvancedScene","chuangongdian","chuangongdian");
	--注册 迷宫战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.MiGongFightScene,"MiGongFightScene","migongfight","migong");
	--注册 工会Boss 场景
	SceneManager:registerScene(SceneManager.SceneID.UnionBossScene,"UnionBossScene","unionboss","boss");
	----注册 时光之巅 场景
	--SceneManager:registerScene(SceneManager.SceneID.ShiGuangScene,"ShiGuangScene","shiguangzhidian","shiguangzhidian");
	----注册 时光之巅战斗 场景
	--SceneManager:registerScene(SceneManager.SceneID.ShiGuangFightScene,"ShiGuangFightScene","shiguangfight","shiguangzhidian");
	--注册 五行阵 场景
	SceneManager:registerScene(SceneManager.SceneID.WuXingZhenScene,"WuXingZhenScene","wuxingzhen","wuxingzhen");
	--注册 五行阵战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.WuXingZhenFightScene,"WuXingZhenFightScene","wuxingzhen","wuxingzhen");
	--注册 大世界地图1 场景
	SceneManager:registerScene(SceneManager.SceneID.WorldScene1,"WorldScene1","shijie1","shijie1");
	--注册 大世界地图2 场景
	SceneManager:registerScene(SceneManager.SceneID.WorldScene2,"WorldScene2","shijie2","shijie2");
	--注册 大世界地图3 场景
	SceneManager:registerScene(SceneManager.SceneID.WorldScene3,"WorldScene3","shijie3","shijie3");
	--注册 大世界地图4 场景
	SceneManager:registerScene(SceneManager.SceneID.WorldScene4,"WorldScene4","shijie4","shijie4");
	--注册 郊外场景
	SceneManager:registerScene(SceneManager.SceneID.JiaoWai,"JiaoWaiScene","jiaowai","jiaowai");
	--注册 工会战场景
	SceneManager:registerScene(SceneManager.SceneID.UnionWarScene,"UnionWarScene","unionwar","unionwar");
	--注册 盗帅迷踪 场景
	SceneManager:registerScene(SceneManager.SceneID.VoyageScene,"VoyageScene","voyage","xiadaomizong");
	--注册 聚宝山 
	SceneManager:registerScene(SceneManager.SceneID.JuBaoShanScene,"JuBaoShanScene","jubaoshan","jubaoshan");
	--注册 江湖传说 场景
	SceneManager:registerScene(SceneManager.SceneID.LegendScene,"LegendFightScene","legend","legend");
	--注册 奇门遁甲 场景
	SceneManager:registerScene(SceneManager.SceneID.QiMenDunJiaScene,"QiMenDunJiaScene","qimendunjia","qimendunjia");
	--注册 古剑奇谭 场景
	SceneManager:registerScene(SceneManager.SceneID.GuJianQiTanScene,"GuJianQiTanScene","gujianqitan","gujianqitan");
	--注册 古剑奇谭战斗 场景
	SceneManager:registerScene(SceneManager.SceneID.GuJianQiTanFightScene,"GuJianQiTanFightScene","gujianqitanfight","gujianqitan");
	--注册 通用活动Boss 场景
	SceneManager:registerScene(SceneManager.SceneID.ActiveBossScene,"ActiveBossScene","boss","boss");
	--注册 宠物大厅 场景
	SceneManager:registerScene(SceneManager.SceneID.PetHallScene,"PetHallScene","pet_hall","chapter");
	--注册 巅峰公会战 场景
	SceneManager:registerScene(SceneManager.SceneID.GuildHighWar,"GuildHighWarScene","guildhighwar","guildhighwar");

	SceneManager:registerScene(SceneManager.SceneID.GhostsShowSkillScene,"GhostsShowSkillScene","ghosts_show_skill","chapter");
end

--预加载配置
function SceneManager:preLoad()
	TimeManager:init();
	SceneManager:createSceneServer();
	GlobalTools:LoadCurveData()
	local classPathConfig = require("Battle.Tool.ClassPathConfig")
	for k,v in pairs(classPathConfig) do
		if string.find(k,"SocketTools") == false then
			require(k);
		end
	end
end

--服务器战斗开始
function SceneManager:serverStart( data )
	Logger.log(">>>>>> 服务器战斗开始 ")
	SceneManager.curGameDelayTime = GlobalTools.base0;
	SceneManager.FixVector3_New_Num = 0;
	SceneManager.delayFrame = GlobalTools.base0;
	SceneManager:changeScene(SceneManager.SceneID.FightScene, data.battle, true);
	SceneManager.start = true
	SceneManager.gameover = false;
	SceneManager.scene_pause = false;
	--这些需要传入数据
	SceneManager.curScene:battleStart(data, 0, false);
	SceneManager:update(0, 110*20, 0);	-- 最多打20场战斗
	local data = SceneManager.curScene.tongjiData:getServerData();
	SceneManager.curScene:destroy();
	Logger.log(">>>>>> 服务器战斗结束 " .. data.result)
	return data;
end

--切换场景
function SceneManager:changeScene( sceneId, data, force, isShowBg )
	--根据场景id 切换场景
	if SceneManager.scenePool == nil or SceneManager.scenePool[sceneId] == nil then
		Logger.logError(" 场景 "..sceneId.." 没有被注册 ")
		return;
	end
	SceneManager:continue();
	SceneManager.nextScene = SceneManager.scenePool[sceneId];
	if SceneManager.curScene == nil or SceneManager.curScene.sceneId ~= SceneManager.nextScene.sceneId or force == true then
		--把上一个场景销毁掉
		if SceneManager.curScene ~= nil then
			SceneManager.curScene:destroy(SceneManager.nextScene)
		end
		SceneManager.curScene = SceneManager.nextScene;
		if data == nil then
			data = {}
		end
		if isShowBg == nil then
			data.isShowBg = true;
		else
			data.isShowBg = isShowBg
		end
		--当前场景开始
		if SceneManager.curScene ~= nil then
			SceneManager.curScene:enter(data)
		else
			Logger.logError(" 没有当前的场景id = "..sceneId)
		end
	else
		local scene_view = SceneManager:getCurSceneView()
		if scene_view and (data == nil or (data and data.playBGM ~= false)) then
			scene_view:setBGMusic()
		end
	end
end

SceneManager.dataCenter = {}
function SceneManager:getData(key)
	return SceneManager.dataCenter[key]
end

function SceneManager:setData(key, data)
	SceneManager.dataCenter[key] = data
end

function SceneManager:clear(key)
	if key == nil then
		SceneManager.dataCenter = {};
	else
		SceneManager.dataCenter[key] = nil;
	end
end

function SceneManager:pause()
	SceneManager.scene_pause = true;
	if SceneManager:getCurSceneModel() ~= nil then
		SceneManager:getCurSceneModel():pause();
	end
end


function SceneManager:continue()
	SceneManager.scene_pause = false;
	if SceneManager:getCurSceneModel() ~= nil then
		SceneManager:getCurSceneModel():continue();
	end
end


--更新游戏
function SceneManager:update_game()
	
	--受时间影响的时间 -----------------------------------------------
	local delayTime = TimeManager:deltaTime();
	if delayTime > 0 then
		--受时间影响的更新
		if SceneManager.curScene ~= nil then
			SceneManager.curScene:update_dt(delayTime)
		end
		if TimeTools ~= nil then
			TimeTools:update_dt(delayTime)
		end
	end

	--不受时间影响的更新 ---------------------------------------------
	local delayUnScaleTime = TimeManager:unscaleDeltaTime();
	if SceneManager.curScene ~= nil then
		SceneManager.curScene:update_unsdt(delayUnScaleTime)
	end
	if TimeTools ~= nil then
		TimeTools:update_unsdt(delayUnScaleTime)
	end

    --推入到表中
	TablePoolUtil:push_all();
end


--更新当前场景
function SceneManager:update( dt, unsdt, isServer )
	--dt unsdt 都是Unity时间
	if SceneManager.start == true then
		if SceneManager.delayFrame > 0 then
			SceneManager.delayFrame = SceneManager.delayFrame - 1;
		else
			if SceneManager.scene_pause == false then
				--客户端
				if unsdt > 0.5 and isServer == nil then
					unsdt = 0.5
				end
				
				--float 转换成 定点数
				local unsdt_fix = GlobalTools:CommonToFix(unsdt);
				local timeSpeed = TimeManager:get_timeSpeed();
				local time = GlobalTools:Mul( unsdt_fix, timeSpeed )
				
				SceneManager.curGameDelayTime = SceneManager.curGameDelayTime + time
				while SceneManager.curGameDelayTime >= TimeManager:get_baseUpdateDelaTime() do
					SceneManager.curGameDelayTime = SceneManager.curGameDelayTime - TimeManager:get_baseUpdateDelaTime()
					SceneManager:update_game()
					if isServer ~= nil then
						if SceneManager.curScene ~= nil and SceneManager.curScene.gameover == true then
							break;
						end
					end
				end
			end
		end
	end
end


function SceneManager:lateUpdate(dt, unsdt)
	if SceneManager.scene_pause == false then
		if SceneManager.curScene ~= nil then
			SceneManager.curScene:lateUpdate(dt,unsdt)
		end
	end
end


function SceneManager:fixedUpdate(fdt)
	if SceneManager.scene_pause == false then

	end
end

--场景停止view
function SceneManager:scenestop_view()
	if SceneManager.curScene ~= nil and SceneManager.curScene.obj ~= nil then
		SceneManager.curScene.obj:SetActive(false);
	end
end


--场景停止model
function SceneManager:scenestop_model()
	if SceneManager.start == true then
		SceneManager.start = false
	end
end

--场景开始view
function SceneManager:scenestart_view()
	if SceneManager.curScene ~= nil and not IsNull(SceneManager.curScene.obj) then
		SceneManager.curScene.obj:SetActive(true);
	end
end

--场景开始model
function SceneManager:scenestart_model()
	if SceneManager.start == false and SceneManager.curScene ~= nil then
		SceneManager.curScene.plyMgr:restart()
		SceneManager.start = true
	end
end

function SceneManager:scenestart()
	
end

function SceneManager:scenestop()

end

function SceneManager:getCameraInfo(sceneName, isBattle)
	if self.battleSceneConfig ~= nil then
		local infos = nil
		if isBattle == true then
			infos = self.battleSceneConfig.CameraInfos_battle
		else
			infos = self.battleSceneConfig.CameraInfos_formation
		end
		for k,v in pairs(infos) do
			if v.sceneName == sceneName then
				return v
			end
		end
	end
	return nil
end

return SceneManager
