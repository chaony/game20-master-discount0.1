--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class GuildHighWarScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("GuildHighWarScene_Model",Battle.Scene_Model)

local offset =  Vector3(5,0,12)  --相机偏移
local imgname = "atk_img" -- image组件name
local city_state_img = {"a_dfbhz_icon_dun","a_dfbhz_icon_jian","a_dfbhz_icon_qi"} --表示状态的images
local city_bottom_img = {"a_dfbhz_baidi","a_dfbhz_huangdi","a_dfbhz_huidi","a_dfbhz_lvdi"} --底框的images
--初始化场景
function M:init()
    M.super.init(self)
    --屏蔽传送场景
    self.canTransPoint = false
    self.guild_high_war_buildline = ConfigManager:getCfgByName("guild_high_war_buildline") or {}
    self.guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build") or {}
    self.stage_table = ConfigManager:getCfgByName("stage")
    self.teams_data = {}
    self.m_lines_status = {}
end

function M:getCurSceneName()
    self:createSceneConfig(137)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    return "";
end

function M:loadFinish()
    
    --英雄
    M.super.loadFinish(self)
    self.m_parent_model = self.m_data.parent_model or nil
    if not self.m_parent_model then return end
        
    SceneManager:scenestart();

    if SceneManager.eventMgr == nil then
        SceneManager.eventMgr = require("Battle.Sce.Tools.SceneEventManager").new()
        SceneManager.eventMgr:init()
    end
    EventDispatcher:registerEvent("DestroyObject",handler(self, self.destroyObject))
    self:initLinesCfg()
    self.gameover = false
    self.sceneState = 3
    self.Camera = U3DUtil:GameObject_Find("Camera")
    self.worldCamera = self.Camera:GetComponent("WorldCamera")
    self.HeroRoot = U3DUtil:GameObject_Find("Hero")
    self.camera_3d = self.Camera.transform:Find("3DCamera")
    self.ui_camera = U3DUtil:GameObject_Find("shijie_UICamera"):GetComponent("Camera")
    self.Canvas = U3DUtil:GameObject_Find("SceneCanvas")
    self.Logic = U3DUtil:GameObject_Find("Logic")
    --self.Fx_GuildhighWar = U3DUtil:GameObject_Find("Fx_GuildhighWar")
    local line_green = self.Logic.transform:Find("line_green")
    local line_red = self.Logic.transform:Find("line_red")
    self.m_green_m = self:getMaterials(line_green)
    self.m_red_m = self:getMaterials(line_red)
    self.areaBarsImg = {}
    self.areaBarsArrow = {}
    self.areaBarsText = {}
    self.areaBarsEffect = {}
    self.buildings = {}
    self.allMapData = {}
    
    --self:getTeams()
    self:refreshBrand()
    self:refreshLines()
    self:initCameraPos()
    
    --事件数据
    self.eventData = require("Battle.Data.SceneInfo.WorldSceneEvent_info");

    local avatar,custom_prefab  = GameUtil:getUserOwnAvatar()
    local playerData = { id = tonumber(avatar), evo = 0, custom_prefab = custom_prefab }
    self.m_world_npc_icon = U3DUtil:GameObject_Find("world_npc_icon")
    
    --self:refreshLineofAttack()
    
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent("CameraPos", {self, self.setCameraPosByCityId})
end

function M:resetSceneData(params)
    --Logger.log("刷新界面")
    self.m_parent_model = params.parent_model or self.m_parent_model
    --self:getTeams()
    self:refreshBrand()
    self:refreshLines()
    self:initCameraPos()
end 

function M:initCameraPos()
    if not IsNull(self.Camera) then
        local my_citys = self.m_parent_model.m_my_city_id or {}
        local city_id = my_citys[1] or 209
        local big_id = math.floor(tonumber(city_id) / 100) * 100
        local lines_obj = self.Logic.transform:Find("town" .. big_id .. "/" .. city_id)
        Logger.log("town" .. big_id .. "/" .. city_id)
        local pos = lines_obj.transform.position
        self.Camera.transform.position = pos + offset
    end
end

function M:initLinesCfg()
    for k, cfg in pairs(self.guild_high_war_buildline ) do
        self.m_lines_status[cfg.linename] = {is_green = false, city_lv = cfg.buildlevel}
    end
end

--刷新建筑物头顶UI数据
function M:refreshLines()
    if not IsNull(self.Logic) then
        local my_citys = self.m_parent_model.m_my_city_id
        local cur_green_lines = {}
        for index, city_id in pairs(my_citys) do
            local line_nums = 0
            for line_name, cfg in pairs( self.m_lines_status ) do
                local cur_is_green = cfg.is_green
                if string.find(line_name, tostring(city_id)) then
                    cur_is_green = true
                    line_nums = line_nums + 1
                    cur_green_lines[line_name] = true
                elseif not(cur_green_lines[line_name]) then
                    cur_is_green = false
                end
                if cur_is_green ~= cfg.is_green then
                    cfg.is_green = cur_is_green
                    local city_lv = cfg.city_lv or 1
                    local lines_obj_name = "town" .. city_lv * 100 .. "/" .. line_name
                    local lines_obj = self.Logic.transform:Find(lines_obj_name)
                    if lines_obj then
                        self:modiftLineMaterial(lines_obj, cur_is_green)
                    end
                end
                if line_nums >= 5 then
                    line_nums = 0
                    break
                end
            end
        end
    end
end

function M:getMaterials(obj)
    if IsNull(obj) then
        return
    end
    local LineRender = obj.transform:Find("LineRender")
    if IsNull(LineRender) then
        return
    end
    local renderers = LineRender:GetComponentsInChildren(typeof(CS.UnityEngine.MeshRenderer), true)
    for i = 1, renderers.Length do
        local itemMat = renderers[i -1]
        local mats = itemMat.materials
        if mats.Length > 0 then
           return mats
        end
    end
end

function M:modiftLineMaterial(lines_obj, is_green)
    local LineRender = lines_obj
    if IsNull(LineRender) then
        return
    end
    local renderers = LineRender:GetComponentsInChildren(typeof(CS.UnityEngine.MeshRenderer), true)
    for i = 1, renderers.Length do
        local itemMat = renderers[i -1]
        local mats = itemMat.materials
        if mats.Length > 0 then
            if is_green then
                itemMat.materials = self.m_green_m
            else
                itemMat.materials = self.m_red_m
            end
        end
    end
end

--进攻路线  203  102
function M:refreshLineofAttack()
    local m_array_data = self.m_parent_model.m_array_data
    local m_fight_data = self.m_parent_model.m_fight_data
    local m_lines_status = self.m_parent_model.m_lines_status
        
    local link_citys = {}
    local pair_citys = {}
    
    if IsNull(self.Canvas) == false then
        local bar_img = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarImg")
                
        for k,v in ipairs(m_fight_data) do  --我宣战的城池
            if next(m_array_data) ~= 1 then -- 没有城池的情况去宣战
                return
            end
            link_citys[v.id]  = {}
            pair_citys[v.id]  = {}
            for k3,v3 in pairs(m_lines_status) do  --城池可攻击关系
                if v3.twoname == v.id then
                    table.insert(link_citys[v.id],v3.onename)
                end
            end
            for m,n in pairs(link_citys[v.id]) do
                for k2,v2 in ipairs(m_array_data) do  --我拥有的城池
                    if n == v2.id then
                        table.insert(pair_citys[v.id],v2.id)
                    end
                end
            end
            
            local areaBarArrow = nil  
            if areaBarArrow == nil then
                local parent_id = "town" .. math.floor(tonumber(v.id) / 100) * 100 --父节点 gameObject
                local town_go = self.Logic.transform:Find(parent_id)
                local target_go = town_go:Find(v.id)   -- 具体城池的gameObject
                local min_distance_id = 0
                local min_distance = 0
                local min_distance_city_go = nil
                --Logger.log("城池" .. v.id)
                for index,ori in ipairs(pair_citys[v.id]) do
                    local ori_go = self.Logic.transform:Find("town" .. math.floor(tonumber(ori) / 100) * 100 .."/" ..ori)
                    local dis = 0 
                    if not IsNull(ori_go) then  --存在起始点
                        --Logger.log("obj是存在的")    
                        dis = Vector3.Distance(target_go.transform.position,ori_go.transform.position)
                        if min_distance_id == 0 and min_distance == 0 then
                            --Logger.log("初始化这个的距离" .. dis)
                            min_distance_id = ori
                            min_distance = dis
                            min_distance_city_go = ori_go
                        else
                            if dis <min_distance then
                                min_distance_id = ori
                                min_distance = dis
                            end
                        end
                    end
                    
                end
                Logger.log("最近的城池ID" .. min_distance_id .. v.id)
                Logger.log("    距离" .. min_distance)
                --instanceObject
                areaBarArrow = ResourceUtil:GetUIItem("GuildHighWar/".."GuildHighWarCityBarArrowsNode", bar_img.gameObject, "ui_prefabs")
                self.areaBarsArrow[v.id] = areaBarArrow
                local WorldPointUI = areaBarArrow:GetComponent("WorldPointUI")
                if not IsNull(min_distance_city_go) then
                    WorldPointUI.target = min_distance_city_go    
                end
                local pos1 = target_go.transform.position
                local pos2 = min_distance_city_go.transform.position
                local ori_pos = Vector3(pos1.x,pos1.y,pos1.z)
                local ori_pos2 = Vector3(pos2.x,pos2.y,pos2.z)
                local angle = Vector3.Angle(ori_pos,ori_pos2)
                angle = math.ceil(angle - 30)
                
                local areaBarArrow_mask_obj = areaBarArrow.transform:Find("Image")
                local areaBarArrow_arrow_obj = areaBarArrow_mask_obj.transform:Find("owner_img")
                local arrow_nums = math.ceil(min_distance)
                for i = 1,arrow_nums do
                    GameUtil:instanceObject(areaBarArrow_arrow_obj,areaBarArrow_mask_obj)
                end
                areaBarArrow.transform.eulerAngles = Vector3(0,0,angle)
            end
        end
    end
    
end

 -- 101-116   201 -209  301 -306
function M:refreshBrand()
    if IsNull(self.Canvas) == false then
        local bar_img = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarImg")
        local bar_text = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarText")
        local build_id_tab = {"town100/", "town200/", "town300/"}
        
        local m_array_data = self.m_parent_model.m_array_data
        local m_line_data = self.m_parent_model.m_line_data
        local m_fight_data = self.m_parent_model.m_fight_data
        
        for city_id, v in pairs(self.guild_high_war_build) do
            local build_lv = v.build_level
            local build_name = build_id_tab[build_lv] .. city_id
            local obj_build_lv = self.Logic.transform:Find(build_name)
            if obj_build_lv ~= nil then
                self.buildings[build_name] = obj_build_lv
                local areaBarImg = self.areaBarsImg[build_name]
                local areaBarText = self.areaBarsText[build_name]
                if areaBarImg == nil then
                    areaBarImg = self:createAreaBar(build_name, bar_img, "GuildHighWarCityBarImageNode", obj_build_lv)
                    areaBarText = self:createAreaBar(build_name, bar_text, "GuildHighWarCityBarTextNode", obj_build_lv)
                    UIUtil.setButtonClick(areaBarImg.transform, function(trans, data)
                        self:transPointPoint(data.id)
                        audio:SendEvtUI("UI_SceneSelected")
                    end, {id = city_id}, "click_btn")
                    self.areaBarsImg[build_name] = areaBarImg
                    self.areaBarsText[build_name] = areaBarText
                end
                if areaBarImg and areaBarText  then
                    local textluaBehaviour = areaBarText:GetComponent("LuaBehaviour")
                    --local texiaoluaBehaviour = self.Fx_GuildhighWar:GetComponent("LuaBehaviour")
                    LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "brand_text", tostring(v.build_name))
                    
                    local imgluaBehaviour = areaBarImg:GetComponent("LuaBehaviour")
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "battle_img", true)
                    local owner_name,owner_flag = self.m_parent_model:getOwnerNameByCityId(city_id)    --拥有者的名字
                    LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "owner_text", owner_name ~= "")
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "owner_img", owner_name ~= "")
                    LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "owner_text", owner_name)
                    LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "def_text", owner_name ~= "" and owner_name or "guild_high_war_text_0053")

                    local atk_name = self.m_parent_model:getAtkGuildNameByCityId(city_id)  --攻击者的名字
                    LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "atk_text", atk_name ~= "")
                    LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "def_text", atk_name ~= "")
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "battle_img", atk_name ~= "")
                    
                    --底板颜色
                    local bottom_image =city_bottom_img[3]
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "atk_spine",false)
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "Image (1)",false)
                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "fight_jigu",false)
                    --LuaBehaviourUtil.setObjectVisible(texiaoluaBehaviour, tostring(city_id),false)
                    --LuaBehaviourUtil.setObjectVisible(texiaoluaBehaviour, tostring(city_id.."_1"),false)
                    if self.m_parent_model.m_ghw_stage == 6 then --宣战阶段
                        --设置会徽
                        if owner_flag ~= 0 then
                            local flag_cfg = ConfigManager:getCfgByName("guild_flag")[owner_flag]
                            if flag_cfg then
                                --Logger.log("已经有工会占领的城池" .. city_id)
                                for i = 1, 3 do
                                    local icon_image = imgluaBehaviour:FindImage(imgname .. i)
                                    GameUtil:updateResourcesImg(icon_image, "Texture/union_emblem/" .. flag_cfg.icon)
                                end
                            end
                        end
                        --根据状态设置为其他图片
                        local state_image = ""
                        --自己的帮会
                        if next(m_array_data) then
                            local name = Language:getTextByKey("UnionWar_str_039")
                            for k,v in ipairs(m_array_data) do
                                if city_id == v.id then
                                    bottom_image = city_bottom_img[4]
                                    if name ~= v.guild_name  then --被宣战
                                        state_image = city_state_img[1]
                                        for i = 1, 3 do
                                            LuaBehaviourUtil.setImg(imgluaBehaviour, imgname .. i,state_image,"main_ui2")
                                        end
                                    end
                                end
                            end
                        end
                        local show_flag = false --周围的城池
                        if self.m_parent_model.m_is_watch == 0 then  --布阵阶段 需要判断是否是观战状态
                            if next(m_line_data) then   --周围可以宣战的城池处理
                                for k,v in ipairs(m_line_data) do
                                    if v.id == city_id then
                                        bottom_image = city_bottom_img[1]
                                        if v.status == 1 then
                                            --Logger.log("被我宣战的城池" .. city_id)
                                            state_image = city_state_img[3]
                                            show_flag = true
                                            for i = 1, 3 do
                                                LuaBehaviourUtil.setImg(imgluaBehaviour, imgname .. i,state_image,"main_ui2")
                                            end
                                        else
                                            if self.m_parent_model.m_declare_times > 0then
                                                state_image = city_state_img[2]
                                                show_flag = true
                                                for i = 1, 3 do
                                                    LuaBehaviourUtil.setImg(imgluaBehaviour, imgname .. i,state_image,"main_ui2")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        for i = 1, 3 do
                            if i == build_lv then
                                LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, imgname .. i, owner_flag ~= 0 or show_flag)
                            else
                                LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, imgname .. i, false)
                            end
                        end
                    elseif self.m_parent_model.m_ghw_stage == 5 then --战斗阶段
                        bottom_image =city_bottom_img[1]
                        if next(m_fight_data) then
                            for k4,v4 in ipairs(m_fight_data) do
                                if v4.id == city_id then
                                    for i = 1, 3 do
                                        if i == build_lv then
                                            local ori = imgluaBehaviour:FindGameObject(imgname ..i )
                                            local spine = imgluaBehaviour:FindGameObject("atk_spine")
                                            if not IsNull(ori) and not IsNull(spine) then
                                                spine.transform.position = ori.transform.position
                                                --Logger.log("宣战的打开spine")
                                                LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "atk_spine",false)
                                                LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "Image (1)",true)
                                                --LuaBehaviourUtil.setObjectVisible(texiaoluaBehaviour, tostring(city_id),true)
                                                --LuaBehaviourUtil.setObjectVisible(texiaoluaBehaviour, tostring(city_id.."_1"),true)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    elseif self.m_parent_model.m_ghw_stage == 4 then --布阵阶段
                        --针对宣战的城池 是否有未派遣的队伍
                        local state_img_name = ""
                        --local hava_teams = self:getTeamsState()
                        if next(m_fight_data) then
                            for k4,v4 in ipairs(m_fight_data) do
                                if v4.id == city_id then
                                    --Logger.log("被我宣战的城池的状态" .. city_id)
                                    LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "fight_jigu",true)
                                    state_img_name = city_state_img[3]
                                    bottom_image =city_bottom_img[1]
                                    for i = 1, 3 do
                                        LuaBehaviourUtil.setImg(imgluaBehaviour, imgname .. i,state_img_name,"main_ui2")
                                        --LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, imgname .. i,i == build_lv )
                                        LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, imgname .. i,false )
                                    end
                                    --for i = 1, 3 do
                                    --    LuaBehaviourUtil.setImg(imgluaBehaviour, imgname .. i,"a_dfzc_dangqian","pub")
                                    --end
                                end
                            end
                        end
                        if next(m_array_data) then
                            local name = Language:getTextByKey("UnionWar_str_039")
                            for k,v in ipairs(m_array_data) do
                                if city_id == v.id then
                                    if name ~= v.guild_name  then --被宣战
                                        LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "fight_jigu",true)
                                    end
                                end
                            end
                        end
                    end
                    LuaBehaviourUtil.setImg(imgluaBehaviour,"brand_btn",bottom_image,"maze_stage_ui")
                    LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "atk_text", atk_name)
                end
            end
        end
    end
end

function M:createAreaBar(id, parent, name, data)
    local areaBar = ResourceUtil:GetUIItem("GuildHighWar/"..name, parent.gameObject, "ui_prefabs")
    areaBar.name = data.name
    local WorldPointUI = areaBar:GetComponent("WorldPointUI")
    local titlePoint = self.buildings[id]:Find("titlePoint")
    WorldPointUI.target = titlePoint or self.buildings[id]
    return areaBar 
end

function M:closeLoading()
    M.super.closeLoading(self)
    static_rootControl:updateMsg("load_scene_finish", nil, "WorldMap.WorldMapMain")
    SceneManager:setData("show_loading_black", false)
    static_rootControl:updateMsg("close_battle_loading")
end


--销毁某个物体
function M:destroyObject( object_id )
    local value_type =  type(object_id)
    if value_type == "number" then
        self.eventBehaiour:HidePoint(object_id)
    elseif value_type == "table" then
        for _,v in pairs(object_id) do
            self.eventBehaiour:HidePoint(v)
        end
    end
end

--点击UI上的Item,传入的数据
function M:clickUIItem( eventId, eventType, npc_id)
    self.curEventId = eventId;
    self.curEventType = eventType;
    local npc_number = npc_id or 0
    if npc_number > 0 then
        --自动寻路
        if SceneManager.events == nil then
            SceneManager.events = {}
        end
        CS.WorldCamera.Inst:AutoFindPathById( tonumber(npc_number ) );
        Logger.log(" 点击UI = "..eventId .." Type = "..eventType )
    else
        Logger.log(" 点击UI 未找到配置= "..eventId .." Type = "..eventType )
    end
end

--打开城池
function M:transPointPoint(city_id)
    if city_id then
        static_rootControl:updateMsg("click_city", city_id, "GuildHighWar.GuildHighWarMain")
    end
end

function M:update_dt(dt)
    if U3DUtil:Input_GetKeyDown("w") then
        local point_data = {}
        point_data.x = -51.2;
        point_data.y = -32.2;
        point_data.obj_id = 0;
        point_data.trigger_radius = 0;
        point_data.point_mode = 0;
        point_data.point_value = 0;
        self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    end

    --if self.fogSaveTimer ~= nil then
    --    self.fogSaveTimer = self.fogSaveTimer - dt
    --    if self.fogSaveTimer <= 0 then
    --        self.fogSaveTimer = 5
    --        if not IsNull(self.fogOfWar) then
    --            self.fogOfWar:SaveData(UserDataManager.user_data.user_status.uid.."_OpenMap"..self.sceneId)
    --        end
    --    end
    --end
    if self.playerHelperArr ~= nil and static_rootControl:can3DTouchByViewName("WorldMap.WorldMiniMap") then
        --local x = GlobalTools:ToFloat(self.playerHelperArr[1])
        --local y = GlobalTools:ToFloat(self.playerHelperArr[2])
        --local z = GlobalTools:ToFloat(self.playerHelperArr[3])
        --static_rootControl:updateMsg("refreshHeroPos", {x = x, y = y, z = z}, "WorldMap.WorldMiniMap")

    end
end

function M:update_unsdt(unsdt)

end

function M:registerHeroAndEnemyPos()

end

function M:triggerEvent( eventData )

end

--进入场景
function M:enter(data)
    M.super.enter(self, data)
    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
end

function M:destroy( nextScene)
    if self.player_move_tween ~= nil then
        self.player_move_tween:Kill(true)
        self.player_move_tween = nil
    end
    if self.areaBarsImg ~= nil then
        for k,v in ipairs(self.areaBarsImg) do
            ResourceUtil:ReturnItem(v)
        end
    end
    if self.areaBarsText ~= nil then
        for k,v in ipairs(self.areaBarsText) do
            ResourceUtil:ReturnItem(v)
        end
    end
    if self.areaBarsEffect ~= nil then
        for k,v in ipairs(self.areaBarsEffect) do
            ResourceUtil:ReturnItem(v)
        end
    end
    
    if IsNull(self.luaViewHelper) == false then
        self.luaViewHelper:Destroy()
    end
    if self.player ~= nil then
        self.player:destroy()
    end
    self.buildings = {}
    self.areaBarsImg = {}
    self.areaBarsText = {}
    self.areaBarsEffect = {}
    --self.fogOfWar:SaveData(UserDataManager.user_data.user_status.uid.."_OpenMap"..self.sceneId) 
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent("CameraPos", {self, self.setCameraPosByCityId})
    M.super.destroy(self, nextScene );
    self.Camera = nil;
    self.camera_3d = nil;
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "encounter_update" then
        --self:updateEncounterNpc()
    elseif curEvent == "scene_lines_update" then
        --self:refreshBrand()
    elseif curEvent == "task_done_update" then
        --self:refreshCurMap()
        --self:refreshBrand()
    end
end

--创建关卡名牌展示id
function M:createStageBrand(tran, stage_id)
    local stage_obj = ResourceUtil:GetUIItem("WorldMap/stage_brand", self.Canvas, "ui_prefabs")
    local WorldPointUI = stage_obj:GetComponent("WorldPointUI")
    WorldPointUI.target = tran.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(stage_obj.transform)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "stage_text", self.stage_table[stage_id].map_point_name)
end

function M:setCameraPos(mapId)
    if self.transPoint[mapId] ~= nil and self.worldCamera.canMove == true then
        self.worldCamera:MoveToPos(self.transPoint[mapId].transform.position, 1, function()
            if LikeOO.Map2DControl.curMap2D == nil then
                LikeOO.Map2DControl:openMap2D(mapId)
            end
        end)
    end
end

--请求队伍的数据
function M:getTeams()
    --Logger.log("获取队伍数据")
    local function callback(net_data)
        self.teams_data = net_data.teams
    end
    self.m_parent_model:getNetData("guild_high_war_formation_index", nil, callback)
end

--判断是否有未派遣的队伍
function M:getTeamsState()
    local flag = false
    if self.teams_datams then
        for k,v in ipairs(self.teams_data) do
            if v.city_id == 0 then
                flag = true
                break
            end                
        end
    end
    return flag
end

function M:setCameraPosByCityId(event,data)
    if not IsNull(self.Camera) then
        local my_citys = data.id
        local city_id = my_citys or 209
        local big_id = math.floor(tonumber(city_id) / 100) * 100
        local lines_obj = self.Logic.transform:Find("town" .. big_id .. "/" .. city_id)
        local pos = lines_obj.transform.position
        self.Camera.transform.position = pos + offset
    end
end


return M;
