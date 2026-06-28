--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--五行阵场景
---@class WuXingZhenScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("WuXingZhenScene_Model",Battle.Scene_Model)

--初始化场景
function M:init()
    M.super.init(self)
    self.isNeedResetCamera = false;
end

--进入场景
function M:enter( data )
    M.super.enter(self, data )
    --上一次的层数
    if self.floor == nil then
        self.floor = -1;
    end
    --服务器的层级
    self.isMove = false;
    self.noLoadFinishAutoMove = true;
end

--更新场景
function M:update_dt(dt)
    M.super.update_dt(self)
end

function M:getCurSceneName()
    self:createSceneConfig(107)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    return "wuxingzhen_data";
end

function M:updateAlways(dt)
	M.super.updateAlways(self,dt)
end

function M:registerHeroAndEnemyPos()
    
end

function M:loadFinish()
    M.super.loadFinish(self);
    --五行阵塔数据
    --self.four_tower_stage = ConfigManager:getCfgByName("four_tower_stage")
    self.four_tower_stage = ConfigManager:getCfgByName("mood_shadow_stage")
    --遗物数据
    self.heirloom = ConfigManager:getCfgByName("heirloom")
    --
    self.four_tower = ConfigManager:getCfgByName("four_tower")
    --战斗数据
    --self.battle_data = ConfigManager:getCfgByName("stage_battle")
    --英雄配置数据
    self.hero_detail = ConfigManager:getCfgByName("hero_detail")
    --皮肤数据
    self.hero_skin = ConfigManager:getCfgByName("hero_skin")
    --站立特效
    self.stand_effect = Battle.List.new()
    --头顶UI
    self.headUI_list = Battle.List.new()
    --获取场景点击
    self.sceneObj = U3DUtil:GameObject_Find("Scene")
    self.clickHelper = self.sceneObj:GetComponent("Scene3DObjectClickHelper")
    --获取相机
    self.cameraObj = U3DUtil:GameObject_Find("WuXingCamera") 
    self.wxCameraController = self.cameraObj:GetComponent("WuXingZhenCamera")
    --获取
    self.HeroRoot = U3DUtil:GameObject_Find("WuXingHero")
    self.startPos = Vector3(6.24, 0, -6.73);

    --注册事件
    self.clickHelper:Register("Click3DObjec",handler(self,self.Click3DObjec));
    self.clickHelper:Register("StopMove",handler(self,self.StopMove));
    self.clickHelper:Register("AnimOver",handler(self,self.AnimOver));
    self.clickHelper:Register("ScreenBlack",handler(self,self.ScreenBlack));
    
    --Logger.logError(self.m_data,"五行阵服务器数据")
    --如果数据的 配置id 大于 0 表示有人物
    if self.m_data.status > 0 then
        --
        self.wxCameraController:PlayOpenSceneAnim("WXZ_ZhuanChang_03", 0);
        --创建人物
        self:checkRoleData();
    else
        self.wxCameraController:PlayOpenSceneAnim("WXZ_ZhuanChang_01", 0);
        static_rootControl:updateMsg("guide_check",nil ,"Fivelines");
        --激活
        self:activeScene();
    end
end

--设定背包位置
function M:setPackagePosition( package )
    self.package = package;
end


function M:resetShitou()
    self.wxCameraController:PlayOpenSceneAnim("WXZ_ZhuanChang_01", 0);
end


--点击激活之后
function M:activeScene()
    if self.m_data.status == 0 then
        --清除本地数据
        UserDataManager.local_data:setLocalDataByKey("fiveline_dead", nil)
        self.wxCameraController:PlayOpenSceneAnim("WXZ_ZhuanChang_02");
        audio:SendEvtUI("UI_SiXiangZhen_StoneOpen")
        TimeTools:delayTimeUnity(5.5,function()
            --创建人物
            self:checkRoleData();
        end)
    end
end

--创建站立人物
--创建人物数据
function M:checkRoleData()
    self.m_is_boss_show = false
    self:destroyUI();
    --先将所有人销毁
    self.plyMgr:destroy()
    --五行阵的战斗数据 配置id
    self.floor = self.m_data.floor;
    if self.floor == 0 then
        Logger.logError(" 服务器活动未开启 ~~~~~~~~~~~~ ")
        self.floor = 1
    end
    --死亡人物suoyin
    self.battle_dead = self.m_data.battle_logs or {};
    --当前的战斗数据
    self.floorData = self.four_tower_stage[self.floor];
    --五行阵的玩家列表
    self.five_element_role = {}
    --怪物数量
    self.monster = #self.floorData.battle_id_list;
    --组织普通怪的数据
    for i, v in ipairs(self.floorData.battle_id_list) do
        local role_data = {};
        --索引
        role_data.index = i;
        --战斗id
        role_data.battle_id = v;
        --类型 金 木 水 火 土
        role_data.type = self.floorData.element_list[i];
        --显示
        role_data.show = self.floorData.enemy_show[i];
        --遗物
        role_data.heirloom_id = self.floorData.heirloom_id[i][1];
        --战斗数据
        if self.m_data.enemys[tostring(i)] ~= nil then
            role_data.fightData = self.m_data.enemys[tostring(i)];
            role_data.fightData.type = 1;
        end
        --是否死了
        role_data.isDead = self:deadlistContain(i);
        self.five_element_role[i] = role_data;
    end
    --组织boss数据 boss的 id 是0
    local boss_data = {};
    --boss索引
    boss_data.index = 0;
    --boss战斗id
    boss_data.battle_id = self.floorData.boss_id;
    --boss类型 金 木 水 火 土
    boss_data.type = self.floorData.boss_type;
    --boss显示
    boss_data.show = self.floorData.boss_show;
    --boss遗物
    boss_data.heirloom_id = self.floorData.heirloom_boss;
    --boss 战斗数据
    if self.m_data.enemys[tostring(0)] ~= nil then
        boss_data.fightData = self.m_data.enemys[tostring(0)];
        boss_data.fightData.type = 2;
    end
    --boss的死亡状态
    boss_data.isDead = self:deadlistContain(0);
    self.five_element_role[0] = boss_data;
    --创建站立人物
    local createNum = 0;
    local finishNum = 0;
    local deadNum = 0;
    for i = 1, 4 do
        local role_data = self.five_element_role[i]
        if role_data ~= nil then
            --如果人物死亡了就不在创建了
            if role_data.isDead == true then
                deadNum = deadNum + 1;
                finishNum = finishNum + 1;
                local root = self.wxCameraController:GetGameObject( i )
                if IsNull(root) == false then
                    --场景里面的预先设置好的物体
                    root:SetActive(false);
                end
            end
            --检测死亡状态
            --如果玩家没有死亡
            --或者是新死亡的
            if role_data.isDead == false or self:isNewDead(role_data.index) then
                local playerData = { id = role_data.show, evo = 0 }
                if role_data.show > 10000 then
                    local role_id = math.ceil(role_data.show/100);
                    playerData = { id = role_id, evo = 0, skin = role_data.show }
                end
                local ply = self.plyMgr:createPlayer(playerData,1,-1,nil,nil)
                ply:setIndex(role_data.index);
                ply.loadPlayerViewFinish = function(m_player)
                    --玩家不用luaViewHelper设置位置
                    finishNum = finishNum + 1;
                    --站立玩家的视图形象
                    role_data.view = m_player;
                    --创建站立玩家完成
                    self:createStandPlayerFinish(role_data, createNum, finishNum, 1);
                end
                role_data.model = ply;
            end
            createNum = createNum + 1;
        end
    end

    --boss也死了
    local boss_role_data = self.five_element_role[0]
    if boss_role_data.isDead then
        local root = self.wxCameraController:GetGameObject( 0 )
        if IsNull(root) == false then
            --场景里面的预先设置好的物体
            root:SetActive(false);
        end
        
        local params =
        {
            open_times = self.m_data.open_times,
            remain_times = self.m_data.remain_times,
            reward = self.m_data.finish_gift,
        }
        --打开3个宝箱的界面
        static_rootControl:updateMsg("openRewardView", params ,"Fivelines");
    else
        --人物都死了 创建boss
        if deadNum == self.monster then
            local role_data = self.five_element_role[0]
            local playerData = { id = role_data.show, evo = 0 }
            if role_data.show > 10000 then
                local role_id = math.floor(role_data.show/100);
                playerData = { id = role_id, evo = 0, skin = role_data.show }
            end
            local ply = self.plyMgr:createPlayer(playerData,1,-1,nil,nil)
            ply:setIndex(role_data.index);
            ply.loadPlayerViewFinish = function(m_player)
                --站立玩家的视图形象
                role_data.view = m_player;
                --创建站立玩家完成
                self:createStandPlayerFinish(role_data, -1, 1, 1.3);
            end
            role_data.model = ply;
            self.m_is_boss_show = true
        end
    end
end


function M:getRoleDataByIndex( index )
    if self.five_element_role then
        return self.five_element_role[index]
    end
end


function M:createStandPlayerFinish( data, createNum, finishNum, scale )
    local m_player = data.view;
    local id = data.index;
    local root = self.wxCameraController:GetGameObject( id )
    if IsNull(root) == false then
        --场景里面的预先设置好的物体
        root:SetActive(true);
        
        --玩家不用luaViewHelper设置旋转
        m_player.luaViewHelper.isSetPosition = false;
        m_player.luaViewHelper.isSetRotation = false;
        
        m_player.roleCon = root:GetComponent("GameRoleController");
        m_player.tran:SetParent(root.transform)
        
        m_player.tran.localScale = Vector3(scale,scale,scale);
        m_player.tran.localRotation = Quaternion.Euler(0,-90,0)
        m_player.tran.localPosition = Vector3(0,0,0)
        
        --显示头顶UI
        --遗物配置
        local cfg = self.heirloom[data.heirloom_id]
        local headUI = root.transform:Find("headUI");
        m_player.gameUI = headUI:GetComponent( "Game3DUI" )
        local uiObj = m_player.gameUI:CreateUI("WuXingUI");
        local lua_behaviour = uiObj:GetComponent("LuaBehaviour");
        --local icon = lua_behaviour:FindImage("Icon");
        local lv = lua_behaviour:FindGameObject("lv");
        local bg = lua_behaviour:FindImage("bg")
        local button = lua_behaviour:FindButton("btn")
        local hero_name = lua_behaviour:FindText("hero_name")
        local role_data = self:getRoleDataByIndex(id);
        --种族
        local frist_data = nil;
        for i, v in pairs(role_data.fightData.heros) do
            frist_data = v;
            break;
        end
        local race_data = GlobalConfig.TYPE_HERO_RACE[m_player.plyData.race]
        --local img = ResourceUtil:GetSprite (race_data.race_icon,  "language_zh_cn");
        --icon.sprite = img;
        local hpCon = lv:GetComponent(typeof(CS.HpLabelController));
        if hpCon ~= nil then
            hpCon:SetText(frist_data.lv,-1);
        end
        if cfg ~= nil then
            UIUtil.setImg(uiObj.transform, cfg.icon, "item_icon", "btn")
        else
            button.gameObject:SetActive(false);
            bg.gameObject:SetActive(false);
        end
        --英雄数据
        local hero_id = data.show;
        if hero_id > 10000 then
            hero_id = math.floor(hero_id/100);
        end
  
        local hero_data = self.hero_detail[hero_id]
        local race = GlobalConfig.TYPE_HERO_RACE[hero_data.race].big_race_icon
        LuaBehaviourUtil.setImg(lua_behaviour, "hero_race", race, ResourceUtil:getLanAtlas())
        if data.index == 0 then
            button.gameObject:SetActive(false);
            bg.gameObject:SetActive(false);
            hero_name.text = Language:getTextByKey("tid#FourTowerDes_04");
        else
            hero_name.text = Language:getTextByKey("tid#FourTowerDes_03");
        end
       
        button.onClick:AddListener(function()
            if data.heirloom_id ~= nil then
                
                local show_data = {id = data.heirloom_id, cfg = cfg}
                
                local send_data = {}
                --显示遗物信息
                send_data.data = show_data;
                --类型
                send_data.look_mode = 1
                --助战英雄
                send_data.assist_heros = self.m_data.assist_heros
                --五行阵队伍key
                send_data.team_key = "five_element"
                static_rootControl:openView("MazeStage.MazeStageRelicLook", send_data)
            end
        end);
        bg.sprite = ResourceUtil:GetSprite(self:getSpriteBg( data.type ),"maze_stage_ui")
        --UI对象
        data.uiObj = uiObj;

        local footEffectName = self:getFootEffect( data.type )
        if footEffectName ~= nil then
            --脚底特效
            local footEffect = ResourceUtil:LoadCommonEffect(footEffectName,root)
            if not IsNull(footEffect) then
                footEffect.transform.localPosition = Vector3(0,0.1,0)
                footEffect.transform.localScale = Vector3(0.162, 0.162, 0.162)
                --脚底特效
                data.footEffect = footEffect;
            end
        end
        
        self:checkDeadState(data)
    end

    if createNum ~= -1 and createNum == finishNum then
       self:loadStandPlayerAllFinish(); 
    end
end


function M:destroyUI()
    if self.five_element_role ~= nil then
        for i = 0, 4 do
            local role_data = self.five_element_role[i]
            if role_data.uiObj ~= nil then
                U3DUtil:GameObjectDestroy(role_data.uiObj)
                role_data.uiObj = nil;
            end
            if role_data.footEffect ~= nil then
                U3DUtil:GameObjectDestroy(role_data.footEffect)
                role_data.footEffect = nil;
            end
        end
    end
end


--所有战力人物加载完成
function M:loadStandPlayerAllFinish()
    self:loadRoleFinish();
    static_rootControl:updateMsg("guide_check",nil ,"Fivelines");
    --self.wxCameraController.m_effect:ChangeAnim("enter");
end

--检测死亡状态
function M:checkDeadState( role_data )
    local index = role_data.index;
    local ply = role_data.view;
    if role_data.isDead then
        --是否是刚刚死亡的人物
        if self:isNewDead(index) then
            local dead_data = UserDataManager.local_data:getLocalDataByKey("fiveline_dead");
            if dead_data == nil then
                dead_data = {}
            end
            table.insert(dead_data, index)
            UserDataManager.local_data:setLocalDataByKey("fiveline_dead", dead_data)

            ply.roleCon:Dead()
            --死亡动画
            ply.animator:changeState("die")
            audio:SendEvtUI("SFX_BodyFall")
            
            TimeTools:delayTimeUnity(2,function()

                local lua_behaviour = role_data.uiObj:GetComponent("LuaBehaviour");
                local lv = lua_behaviour:FindGameObject("lv");
                lv:SetActive(false);
                local bg = lua_behaviour:FindGameObject("bg")
                bg:SetActive(false);
                local hero_name = lua_behaviour:FindGameObject("hero_name_con")
                hero_name:SetActive(false);
                local button = lua_behaviour:FindGameObject("btn")
                
                local pos = self.package.transform.position;
                pos.z = 0;
                self:dotweenMove(button, pos, 1, function()
                    if role_data.uiObj ~= nil then
                        U3DUtil:GameObjectDestroy(role_data.uiObj);
                        role_data.uiObj = nil;
                    end
                    static_rootControl:updateMsg("fly_yiwu",nil,"Fivelines")
                end)
                
                --3D 世界坐标
                --local pos = role_data.view.obj.transform.position;
                --local camera3d = SceneManager:getCurSceneView().cameraController.CameraRole;
                --local uguiPos = U3DUtil:u3dToUGUIPosition(camera3d,pos)
                --static_rootControl:updateMsg("fly_to_target",{ pos = uguiPos, heirloom_id = role_data.heirloom_id } ,"Fivelines");
                role_data.model:destroy();
                role_data.view = nil;
                role_data.model = nil;

                if role_data.footEffect ~= nil then
                    U3DUtil:GameObjectDestroy(role_data.footEffect);
                    role_data.footEffect = nil;
                end
            end)
            --else
            --    Logger.logError(" 已经死亡人数 index ~~~~~~~~~~~~~~~~~~~~~~ "..index )
            --    ply.roleCon:Dead()
            --    --直接躺下的状态
            --    ply.animator:changeState("die",nil,0.9)
        end
    else
        ply.roleCon:Spawn()
        ply.animator:changeState("idle")
    end
end

--
function M:dotweenMove(obj, pos, time, endCallFunc)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(obj.transform:DOMove(pos, time):SetEase(Tweening.Ease.OutSine))
    sequence:OnComplete(endCallFunc)
    sequence:SetAutoKill(true)
end


--不执行父类的关闭loading
function M:closeLoading()
    
end


--加载所有站立的人物完成
function M:loadRoleFinish()
    static_rootControl:updateMsg("close_sync_load_big_loading");
    static_rootControl:updateMsg("close_battle_loading")
    self:sendEvent("initSence",nil,"Fivelines")
end


--自动战斗
function M:autoFight( battle_log_num )
    local is_finish = battle_log_num >= self.m_element_list_count
    if self.standRole_list ~= nil then
        if is_finish == false then
            local index = 0
            for i = 1, self.standRole_list.Count do
                if self:deadlistContain(i) == false then
                    index = i;
                    break;
                end
            end
            if index > 0 then
                --local root = U3DUtil:GameObject_Find((index).."")
                --self:Click3DObjec(root, tonumber(index));

                local root = U3DUtil:GameObject_Find((index).."")
                self.selectObj = root
                self:MoveTo()
                self:sendEvent("battle_start",tonumber(index),"Fivelines")
            end
        else

            for i = 1, self.headUI_list.Count do
                local ui = self.headUI_list:get(i-1)
                if ui ~= nil then
                    ui:SetActive(false);
                end
            end
            
            --重新设置场景物体
            if self.wxCameraController ~= nil then
                self.wxCameraController.rect = Vector2(-5, 5);
            end

            --移动出场景
            self.player.roleCon:StartMove(Vector3(self.player.tran.position.x + 10,0,0),1.5, 1)
            self.player.animator:changeState("run")
         
            --if self.wxCameraController ~= nil then
            --    self.wxCameraController.m_effect.transform.localScale = Vector3(0.001,0.001,0.001)
            --end

            TimeTools:delayTimeUnity(1.5, function()
                if self.wxCameraController ~= nil then
                    self.wxCameraController:ResetAllSceneObj();
                end
                self:sendEvent("enter_next_floor",nil,"Fivelines")
            end)
        end
    end
end


--是否是第一次死
function M:isNewDead( id )
    --本地数据取不到就是刚死的
    local dead_data = UserDataManager.local_data:getLocalDataByKey("fiveline_dead");
    if dead_data == nil then
        return true;
    else
        for i, v in ipairs(dead_data) do
            if v == id then
                return false;
            end
        end
        return true;
    end
end

--死亡列表是否包含 id 
function M:deadlistContain( id )
    for i, v in ipairs(self.battle_dead) do
        if v == id then
            return true;
        end
    end
    return false;
end

--获取脚底Effect
function M:getFootEffect( type )
    if type == 1 then --木
        return "Formation_Mu"
    elseif type == 2 then --火
        return "Formation_Huo"
    elseif type == 3 then --土
        return "Formation_Tu"
    elseif type == 4 then --金
        return "Formation_Jin"
    elseif type == 5 then --水
        return "Formation_Shui"
    end
end


function M:getSprite( type )
    if type == 1 then --木
        return "a_ui_xuanwu"
    elseif type == 2 then --火
        return "a_ui_zhuque"
    elseif type == 3 then --土
        return "a_ui_qinglong"
    elseif type == 4 then --金
        return "a_ui_qinglong"
    elseif type == 5 then --水
        return "a_ui_baihu"
    end
end

function M:getSpriteBg( type )
    if type == 1 then --木
        return "a_wxz_mu_di"
    elseif type == 2 then --火
        return "a_wxz_huo_di"
    elseif type == 3 then --土
        return "a_wxz_tu_di"
    elseif type == 4 then --金
        return "a_wxz_jin_di"
    elseif type == 5 then --水
        return "a_wxz_shui_di"
    end
end

--点击前往
function M:MoveTo()
    if self.selectObj ~= nil then
        if self.wxCameraController ~= nil then
            self.wxCameraController:AutoFindPoint(self.selectObj)
        end
        self.selectObj = nil;
    end
end
    
--重新设定位置
function M:resetPlayerPosition()
    
end

--点击到3D物体
function M:Click3DObjec( objValue, strValue, intValue)
    self.selectObj = objValue;
    local index = tonumber(strValue);
    if index <= 6 then
        local roleData = self:getRoleDataByIndex(index);
        if index == 0 and not(self.m_is_boss_show) then
            --Logger.logError(" boss没显示呢就别点了 ")
        elseif roleData ~= nil then
            self:sendEvent("battle_start_openDetail", roleData, "Fivelines")
        else
            Logger.logError(" 点击的物体数据没有找到 ")
        end
    end
end

--场景销毁
function M:destroy() 
    M.super.destroy(self)
    self:destroyUI();
    self.player = nil
    self.wxCameraController = nil;
    self.selectObj = nil;
    for i = 1, self.headUI_list.Count do
        U3DUtil:GameObjectDestroy(self.headUI_list:get(i-1))
    end
    for i = 1, self.stand_effect.Count do
        U3DUtil:GameObjectDestroy(self.stand_effect:get(i-1))
    end
    self.headUI_list:clear();
    self.stand_effect:clear();
end

return M