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
    self.serverFloor = -1;
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
    self.wuxingData = ConfigManager:getCfgByName("five_element_tower")

    --self.battle_data = ConfigManager:getCfgByName("stage_battle")
    self.battleId_list = Battle.List.new()
    self.standRole_id_list = Battle.List.new()
    self.standRole_list = Battle.List.new()
    self.type_list = Battle.List.new()
    self.stand_effect = Battle.List.new()
    self.headUI_list = Battle.List.new()
    
    --获取场景点击
    self.sceneObj = U3DUtil:GameObject_Find("Scene")
    self.clickHelper = self.sceneObj:GetComponent("Scene3DObjectClickHelper")
    --获取相机
    self.cameraObj = U3DUtil:GameObject_Find("WuXingCamera") 
    self.wxCameraController = self.cameraObj:GetComponent("WuXingZhenCamera")

    self.HeroRoot = U3DUtil:GameObject_Find("WuXingHero")
    self.startPos = Vector3(6.24, 0, -6.73);

    self:checkRoleData();
    
    self.clickHelper:Register("Click3DObjec",handler(self,self.Click3DObjec));
    self.clickHelper:Register("StopMove",handler(self,self.StopMove));
    self.clickHelper:Register("AnimOver",handler(self,self.AnimOver));
    self.clickHelper:Register("ScreenBlack",handler(self,self.ScreenBlack));
end


function M:enterNext( data )
    self.sceneData = data;
    self.isMove = true
end

function M:enterNext_ago(i)
      if #self.battle_dead == self.m_element_list_count then
        local ply = self.standRole_list:get(i)
        if ply ~= nil and self.player ~= nil then
            -- local ply = self.battle_dead:get(self.battle_dead.Count - 1)
            ply.animator:changeState("idle")
            local ply_pos = GlobalTools:ToFixVector3(self.player.roleCon.transform.position)
            local enemy_pos = GlobalTools:ToFixVector3(ply.roleCon.transform.position)
            local ply_dir = GlobalTools:Dir(ply_pos,enemy_pos);
            local enemy_dir = GlobalTools:Dir(enemy_pos,ply_pos);
            
            ply.tran.forward = ply_dir:toVector3()
            self.player.tran.forward = enemy_dir:toVector3()
            self.player.animator:changeState("attack1")
            ply.animator:changeState("die")
            self.player.animator:changeState("idle")
            TimeTools:delayTimeUnity(2, function()
                if self.wxCameraController ~= nil then
                    --显示触发器
                    self.wxCameraController:ShowTrigger(true);
                    if self.wxCameraController.m_effect ~= nil then
                        self.wxCameraController.m_effect:ChangeAnim("hide");
                    end
                end
                self:sendEvent("popupAward",nil,"Fivelines")
            end)
        end
     end
end


function M:checkRoleData()
    local local_value = UserDataManager.local_data:getLocalDataByKey("wuxingzhen_in",0)
    self.sceneData = SceneManager:getData("Fivelines") or self.sceneData
    self.serverFloor = tonumber(self.sceneData.floor) + 1;
    --第一次进入
    self.isFristIn = false;
    self.isMove = false;
    if self.serverFloor ~= self.floor then
        if self.floor ~= -1 then
            self.isMove = true
        else
            if self.serverFloor == 1 and local_value == 0 then
                self.isFristIn = true;
                UserDataManager.local_data:setLocalDataByKey("wuxingzhen_in",1)
            end
        end
    end
    self.floor= self.serverFloor;
    
    self.sceneIndex = self.serverFloor % 2;
    self.battle_dead = self.sceneData.battle_logs;
    
    self.plyMgr:destroy()
    self.floorData = self.wuxingData[self.floor];
    self.battleId_list:clear()
    self.standRole_id_list:clear()
    self.standRole_list:clear()
    self.type_list:clear();
    self.standRolePools = {}

    self.m_element_list_count = #self.floorData.element_list
    for i, v in ipairs(self.floorData.battle_id_list) do
        self.battleId_list:add(v);
    end

    for i, v in ipairs(self.floorData.element_list) do
        self.type_list:add(v);
    end

   
    for i = 1, self.battleId_list.Count, 1 do
        local battle_id = self.battleId_list:get(i-1);
        local battleItem = ConfigManager:getCfgStageBattle(battle_id)--self.battle_data[battle_id];
        self.standRole_id_list:add(battleItem.monster[1].iid)
    end
    
    if self.isMove == false and self.isFristIn == false then
        if self.wxCameraController ~= nil and self.wxCameraController.m_effect ~= nil then
            self.wxCameraController.m_effect:ChangeAnim("move");
        end
    end
    
    if #self.battle_dead == self.m_element_list_count then
        -- self:enterNext_ago(#self.battle_dead)
        -- TimeTools:delayTimeUnity(2, function()
        --     self.wxCameraController.m_effect:ChangeAnim("hide");
        --     --显示触发器
        --     self.wxCameraController:ShowTrigger(true);
        -- end)
    end

    local index = 0;
   
    local user = UserDataManager.user_data.user_status
    local avatar = user.avatar or 104
    local playerData = { id = tonumber(avatar), evo = 0 }
    --local data,_ = UserDataManager.hero_data:getHeroDataById(v)
    local player = self.plyMgr:createPlayer(playerData,1,-1,nil,nil)
    player.loadPlayerViewFinish = function(m_player)
        self.player = m_player;
        self.player.luaViewHelper.isSetPosition = false;
        self.player.luaViewHelper.isSetRotation = false;
        local root = U3DUtil:GameObject_Find((7).."")
        if IsNull(root) == false then
            self.player.roleCon = root:GetComponent("GameRoleController");
            self.player.roleCon:Register("GameRoleStopMove", function(obj, name, index)
                if self.player ~= nil then
                    if self.player.animator ~= nil then
                        self.player.animator:changeState("idle")
                    end
                end
            end);
        end
        if SceneManager:getData("posx") == nil then
            self.player.tran.position = self.startPos;
        else
            local pos = self.player.tran.position;
            pos.x = SceneManager:getData("posx");
            pos.y = 0;
            pos.z = SceneManager:getData("posz");
            self.player.tran.position = pos;
        end
        self.player.tran.localScale = Vector3(1,1,1);
        self.player.tran:SetParent(root.transform)
        if self.wxCameraController ~= nil then
            self.wxCameraController:SetFollow( self.player.tran );
        end
        self:resetPlayerPosition(self.player)
        TimeTools:delayTimeUnity(0.05,function()
            if self.player ~= nil and not IsNull(self.player.navAgent) then
                --self.player.navAgent.enabled = true;
                self.player.navAgent.speed = 6;
                if  not IsNull(self.player.tran) then
                    self.player.tran.localRotation = Quaternion.Euler(0,90,0)
                end
            end
        end)

        if self.isFristIn == false then
            if self.wxCameraController ~= nil then
                self.wxCameraController:SmokeAnim(0, function()
                end)
            end
            if self.isMove == true then
                --人物从外面跑进来
                self.player.roleCon:StartMove(Vector3(self.player.tran.position.x - 10,0,0),1.5, 3)
                self.player.animator:changeState("run")
            else
                self.player.animator:changeState("idle")
            end
        else
            --第一次进入
            self.player.tran.position = Vector3(-20,0,-6.78)
            self.player.animator:changeState("idle")
        end
    end
    
    local delayNowTime = 0.05
    if #self.battle_dead == self.m_element_list_count then
        delayNowTime = 1.5
    end
    TimeTools:delayTimeUnity(delayNowTime, function()
        local createNum = 0;
        local finishNum = 0;
        
        for i = 1, 5 do
            if i <= self.standRole_id_list.Count then
                createNum = createNum + 1;
                local playerData = { id = self.standRole_id_list:get(i-1), evo = 0 }
                local ply = self.plyMgr:createPlayer(playerData,1,-1,nil,nil)
                ply:setIndex(createNum);
                ply.loadPlayerViewFinish = function(m_player)
                    --玩家不用luaViewHelper设置位置
                    finishNum = finishNum + 1;
                    self.standRolePools[m_player.index] = m_player;
                    if finishNum == createNum then
                        for i = 1, 5 do
                            local ply = self.standRolePools[i];
                            if ply ~= nil then
                                self.standRole_list:add(ply);
                            end
                        end
                    end
                    self:createStandPlayerFinish(m_player, m_player.model.wxz_id, createNum, finishNum);
                end
                ply.wxz_id = i;
            else
                local root = self.wxCameraController:GetGameObject(i-1)
                if IsNull(root) == false then
                    root:SetActive(false);
                end
            end
        end
     end)
end


function M:createStandPlayerFinish( m_player, id, createNum, finishNum )
    local root = self.wxCameraController:GetGameObject( id -1 )
    if IsNull(root) == false then
        root:SetActive(true);
        m_player.luaViewHelper.isSetPosition = false;
        --玩家不用luaViewHelper设置旋转
        m_player.luaViewHelper.isSetRotation = false;
        m_player.tran.localScale = Vector3(0,0,0);
        m_player.roleCon = root:GetComponent("GameRoleController");
        m_player.roleCon:Register("GameRoleStopMove", function(obj, name, index)
            for i = 1, self.standRole_list.Count do
                self.standRole_list:get(i-1).animator:changeState("idle")
            end
        end);
        --显示头顶UI
        local headUI = root.transform:Find("headUI");
        m_player.gameUI = headUI:GetComponent( "Game3DUI" )
        local uiObj = m_player.gameUI:CreateUI("WuXingUI");
        local m_type = self.type_list:get(id-1);
        local type_img_name = self:getSprite( m_type)
        GameUtil:setLanImgText(uiObj.transform, type_img_name, "img")
        local bg = uiObj.transform:Find("bg"):GetComponent("Image");
        bg.sprite = ResourceUtil:GetSprite(self:getSpriteBg( m_type),"maze_stage_ui")

        if self.isFristIn == true then
            uiObj:SetActive(false)
        else
            if self.isMove == false then
                uiObj:SetActive(true)
                local footEffect = ResourceUtil:LoadCommonEffect(self:getFootEffect(m_type),root)
                if not IsNull(footEffect) then
                    footEffect.transform.localPosition = Vector3(0,0.1,0)
                    footEffect.transform.localScale = Vector3(0.162, 0.162, 0.162)
                    self.stand_effect:add(footEffect)
                end
            else
                uiObj:SetActive(false)
            end
        end

        self.headUI_list:add(uiObj)
        m_player.tran:SetParent(root.transform)
        if self.isFristIn == true then
            m_player.tran.localPosition = Vector3(-100,0,100)
        else
            m_player.tran.localPosition = Vector3(0,0,0)
            if self.player ~= nil and self.player.tran ~= nil then
                m_player.roleCon:FowardTo(self.player.tran.position);
            end
        end
    end

    if createNum == finishNum then
       self:loadStandPlayerAllFinish(); 
    end
end


function M:loadStandPlayerAllFinish()
    self:loadRoleFinish();
    self:loadFinishAll();
    static_rootControl:updateMsg("guide_check",nil ,"Fivelines");
    local runOverIndex = 0;
    for k = 1, self.standRole_list.Count do
        local ply = self.standRole_list:get(k-1)
        if self:deadlistContain(k) then
     
            if self:isNewDead(k) then
                SceneManager:setData("dead"..k, 1)
                ply.roleCon:Dead()
                --死亡动画
                ply.animator:changeState("die")
                self:enterNext_ago(self.standRole_list.Count-1)
            else
                Logger.log(" 五行阵死亡人数 ~~~~~~~~~~~~~~~~~~~~~~ "..k )
                ply.roleCon:Dead()
                --直接躺下的状态
                ply.animator:changeState("die",nil,0.9)
            end
        else
            if self.isFristIn == false then
                if self.isMove == true then
                    runOverIndex = runOverIndex + 1
                    if ply.roleCon ~= nil then
                        ply.roleCon:StartMove(Vector3(6.11,0,-6.78),1, 2, function()
                            runOverIndex = runOverIndex - 1
                            if runOverIndex == 0 then
                                --人物移动完成之后，才显示效果
                            end
                        end)
                    else
                        ply.tran.localPosition = Vector3(0,0,0)
                    end
                    ply.animator:changeState("run")
                else
                    ply.animator:changeState("idle")
                end
            end
        end
        ply.tran.localScale = Vector3(1,1,1);
    end
    TimeTools:delayTimeUnity(4,function()
        self:anim_effect();
    end)
end

--不执行父类的关闭loading
function M:closeLoading()
    
end


function M:loadFinishAll()
    if self.noLoadFinishAutoMove == true then
        local battle_logs = #self.sceneData.battle_logs
        if battle_logs >= self.m_element_list_count then
            self:autoFight(5);
        end
    end
end


--加载所有站立的人物完成
function M:loadRoleFinish()
    static_rootControl:updateMsg("close_sync_load_big_loading");
    static_rootControl:updateMsg("close_battle_loading")
    self:sendEvent("initSence",nil,"Fivelines")
    
    if self.isFristIn then
        if self.player ~= nil then
            --烟雾移动
            --2秒烟雾环绕
            if self.wxCameraController ~= nil then
                self.wxCameraController:SmokeAnim(2, function()
                end)
            end
            self.player.animator:changeState("run")
            --烟雾移动完人物移动
            self.player.roleCon:StartMove(Vector3(6.11,0,-6.78),1.5, 1, function()
                
            end)
            TimeTools:delayTimeUnity(1.2, function()
                --移动完成
                --所有人物移动过来
                self.stand_effect:clear()
                local index = 0;
                for i = 1, self.standRole_list.Count do
                    local ply = self.standRole_list:get(i-1)
                    ply.roleCon:StartMove(Vector3(6.11,0,-6.78),1.5, 2, function()
                        index = index + 1
                        --人物移动完成显示UI
                        if index == self.standRole_id_list.Count then
                            for j = 1, self.headUI_list.Count do
                                local ui = self.headUI_list:get(j-1)
                                if IsNull(ui) == false then
                                    ui:SetActive(true);
                                end

                                --创建站立特效
                                local root = U3DUtil:GameObject_Find((j).."")
                                local m_type = self.type_list:get(j-1);
                                local footEffect = ResourceUtil:LoadCommonEffect(self:getFootEffect(m_type),root)
                                if not IsNull(footEffect) then
                                    footEffect.transform.localPosition = Vector3(0,0.1,0)
                                    footEffect.transform.localScale = Vector3(0.162, 0.162, 0.162)
                                    self.stand_effect:add(footEffect)
                                end
                            end

                            if not IsNull(self.wxCameraController) then
                                if IsNull( self.wxCameraController.m_effect) == false then
                                    self.wxCameraController.m_effect:ChangeAnim("enter");
                                end
                            end
                        end
                    end)
                    ply.animator:changeState("run")
                end
            end)
        end
    end
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

            if self.wxCameraController ~= nil then
                self.wxCameraController.m_effect.transform.localScale = Vector3(0.001,0.001,0.001)
            end

            TimeTools:delayTimeUnity(1.5, function()
                if self.wxCameraController ~= nil then
                    self.wxCameraController:ResetAllSceneObj();
                end
                self:sendEvent("enter_next_floor",nil,"Fivelines")
            end)
        end
    end
end


function M:flyFinish()
    self:sendEvent("playBoxAnim",nil,"Fivelines")
end

--是否是第一次死
function M:isNewDead( id )
    if SceneManager:getData("curdead" ) == id then
        return true;
    end
    return false;
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

--停止
function M:StopMove( objValue, strValue, intValue )
    --# 当前挑战层的奖励领取记录 0.未领奖 1.已经领奖
    self.sceneData = SceneManager:getData("Fivelines") or self.sceneData
    local received = self.sceneData.received 
    
    --SceneManager:setData("posx",objValue.transform.position.x);
    --SceneManager:setData("posz",objValue.transform.position.z);
    SceneManager:setData("curdead", tonumber(strValue) )
    --if tonumber(strValue) == 6 and received == 1 then
    --    --重新设置场景物体
    --    if self.wxCameraController ~= nil then
    --        self.wxCameraController:ResetAllSceneObj();
    --    end
    --    self:sendEvent("enter_next_floor",nil,"Fivelines")
    --else
        --self:sendEvent("battle_start",tonumber(strValue),"Fivelines")
    --end
end


function M:anim_effect()

    TimeTools:delayTimeUnity(3, function()
        for i = 1, self.headUI_list.Count do
            local ui = self.headUI_list:get(i-1)
            if IsNull(ui) == false then
                ui:SetActive(true);
            end
        end
        for i = 1, self.standRole_list.Count do
            local ply = self.standRole_list:get(i-1)
            if ply ~= nil then
                if IsNull(ply.gameUI) == false then
                    ply.gameUI:ShowLerp(2);
                end
            end
        end
    end)

    TimeTools:delayTimeUnity(3, function()
        if self.isMove == true then
            if self.wxCameraController ~= nil and not IsNull(self.wxCameraController) then
                self.wxCameraController.m_effect.transform.localScale = Vector3(1,1,1)
                if IsNull( self.wxCameraController.m_effect) == false then
                    self.wxCameraController.m_effect:ChangeAnim("enter");
                end
            end
        end
    end)

    TimeTools:delayTimeUnity(5, function()
        if self.isMove == true then
            for i = 1, self.type_list.Count,1 do
                local root = U3DUtil:GameObject_Find((i).."")
                if IsNull(root) == false then
                    local m_type = self.type_list:get(i-1);
                    local footEffect = ResourceUtil:LoadCommonEffect(self:getFootEffect(m_type),root)
                    footEffect.transform.localPosition = Vector3(0,0.1,0)
                    footEffect.transform.localScale = Vector3(0.162, 0.162, 0.162)
                    self.stand_effect:add(footEffect)
                end
            end
        end
    end)
    
end

--动画播放完成
function M:AnimOver( objValue, strValue, intValue )
    
    
    self:sendEvent("showView",nil,"Fivelines")
end

--场景黑屏
function M:ScreenBlack( objValue, strValue, intValue )
    for i = 1, self.stand_effect.Count do
        ResourceUtil:ReturnItem(self.stand_effect:get(i-1));
    end
    
    Logger.log(" 销毁所有UI ~~~~~~~~~~~~~~~~~ ")
    for i = 1, self.standRole_list.Count do
        local ply = self.standRole_list:get(i-1);
        if ply ~= nil and IsNull(ply.gameUI) == false then
            ply.gameUI:DestoryUI()
        end
    end

    self.headUI_list:clear();
    self.stand_effect:clear();
    self.standRole_list:clear()
    self:sendEvent("refresh_data",nil,"Fivelines")
    
    if self.wxCameraController ~= nil then
        self.wxCameraController:SetFollow(nil)
        self.wxCameraController.transform.position = Vector3(1.5,0,0)
    end
    
    SceneManager:clear()
    --继续创建人物
    self:checkRoleData();
end

--重新设定位置
function M:resetPlayerPosition()
    
end

--点击到3D物体
function M:Click3DObjec( objValue, strValue, intValue)
    self.selectObj = objValue;
    local obj_num = tonumber(strValue);
    if obj_num <= 6 then
        self:sendEvent("battle_start",tonumber(strValue),"Fivelines")
    end
    --self:sendEvent("click_element",tonumber(strValue),"Fivelines")
end


function M:destroy() 
    M.super.destroy(self)
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