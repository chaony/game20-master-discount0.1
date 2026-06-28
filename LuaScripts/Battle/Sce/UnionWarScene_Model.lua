--帮会战
---@class UnionWarScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("UnionWarScene_Model",Battle.Scene_Model)
M.BUILDINGS_COUNT = GlobalConfig.UNION_WAR_BUILDINGS_COUNT

--初始化场景
function M:init()
    M.super.init(self)
end

function M:getCurSceneObjName()
    return "unionwarscene_data"
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)    
end

function M:getCellStartIndex()
    return GameUtil:getUnionWarCellStartIndex(self.m_data)
end

-- 初始化建筑有关的数据
function M:initBuildings()
    local start_index = self:getCellStartIndex()
    local half_index = self.BUILDINGS_COUNT/2
    for i, map_ground in pairs(self.m_map_grounds) do
        local cell_data = nil
        if start_index == 0 then
            cell_data = self.m_data.cells[tostring(i)] or {}
        else
            cell_data = self.m_data.cells[tostring(start_index - i)] or {}
        end
        local map_building = self.m_map_buildings[i]
        if not IsNull(map_building) then
            map_building:SetActive(cell_data.destroy ~= true)
        end
        local fx_name = nil
        -- 有队伍数量大于0,显示队伍数量
        local team_num = cell_data.team_num or 0
        self:createNum(team_num, map_ground, i, cell_data.can_battle)
        -- 占领地块不一样，闪烁特效不一样       
        if cell_data.destroy then
            --fx_name = self.m_firstEnter and "Fx_JiHuo_Red_001" or "Fx_DiMian_Red_001"
            fx_name = "Fx_GongHuiZhan_Smoke_01"
        else
            if i > half_index then
                fx_name = "Fx_GongHuiZhan_Red_01"
            end
            --if cell_data.owner == self.m_data.vs[1] then
            --    fx_name = self.m_firstEnter and "Fx_JiHuo_Blue_001" or "Fx_DiMian_Blue_001"
            --elseif cell_data.owner == self.m_data.vs[2] then
            --    fx_name = self.m_firstEnter and "Fx_JiHuo_Yellow_001" or "Fx_DiMian_Yellow_001"
            --else
            --    fx_name = self.m_firstEnter and "Fx_JiHuo_Red_001" or "Fx_DiMian_Red_001"
            --end
        end

        if fx_name then
            if self.m_fxEffects[i] ~= nil and self.m_fxEffects[i].fix_name ~= fx_name then
                if not IsNull(self.m_fxEffects[i].fx_obj) then
                    ResourceUtil:DestroyInstance(self.m_fxEffects[i].fx_obj)
                    self.m_fxEffects[i].fx_obj = nil
                end
            end
            if self.m_fxEffects[i] == nil or IsNull(self.m_fxEffects[i].fx_obj) then
                local fx_obj = SceneManager:getCurSceneView():instanceGameObject(fx_name,self.scene_obj_meishu)
                if not IsNull(fx_obj) then
                    fx_obj.transform.position = map_ground.transform.position
                    self.m_fxEffects[i] = {fx_obj = fx_obj, fix_name = fx_name}
                end
            end
        else
            if self.m_fxEffects[i] ~= nil then
                if not IsNull(self.m_fxEffects[i].fx_obj) then
                    ResourceUtil:DestroyInstance(self.m_fxEffects[i].fx_obj)
                    self.m_fxEffects[i].fx_obj = nil
                end
            end
        end
    end
    self:createOwnTeamSign()
    self.m_firstEnter = false
end

--加载完成
function M:loadFinish()
    --当前我要站立的item
    self.curItem = nil;
    --玩家
    self.player = nil;
    self.m_fxEffects = {}
    self.m_map_buildings = {}
    self.m_map_grounds = {}
    self:sendEvent("load_finish", nil, "UnionWar.UnionWarMain");
    self.closeloading();
    self:registerClickItem();
    self.scene_obj_meishu = U3DUtil:GameObject_Find("Scene");
    EventDispatcher:registerEvent("UnionWar_TeamChanged", {self,self.teamChangedHandler})

    for i = 1, self.BUILDINGS_COUNT do
        local map_ground = U3DUtil:GameObject_Find("map_ground_".. i)
        if map_ground then
            self.m_map_grounds[i] = map_ground
        end
        local map_building = U3DUtil:GameObject_Find("map_building_".. i)
        if map_building then
            self.m_map_buildings[i] = map_building
        end
    end
    self.m_scene_canvas_obj = U3DUtil:GameObject_Find("scene_canvas")
    self.m_scene_canvas = self.m_scene_canvas_obj:GetComponent("Canvas")
    self.m_scene_canvas.worldCamera = static_ui_camera
    self.m_own_team_node = U3DUtil:GameObject_Find("own_team_node")
    self.m_own_team_node_parent = U3DUtil:GameObject_Find("own_team_node_parent")
    self.m_own_team_node_tab = {}
    
    self.m_fxFight = {}
    self.m_firstEnter = true
    self:initBuildings()  
    
    GameMain.addUpdate("UnionWar_Update", handler(self,self.UnityUpdate))
    self.mouseDown = SceneManager:getCurSceneView().cameraController.mouseDown;
    self.mouseDownTime = 0;
end

function M:UnityUpdate(dt)

    self.mouseDown = SceneManager:getCurSceneView().cameraController.mouseDown;
    if self.mouseDown == true then
        self.mouseDownTime = self.mouseDownTime + dt;
    else
        self.mouseDownTime = 0;
    end
    
    if static_rootControl:can3DTouchByViewName("UnionWar.UnionWarMain") then
        if SceneManager:getCurSceneView().cameraController.CanDrag == false then
            SceneManager:getCurSceneView().cameraController.CanDrag = true;
            SceneManager:getCurSceneView().cameraController.mouseDown = false;
        end
    else
        if SceneManager:getCurSceneView().cameraController.CanDrag == true then
            SceneManager:getCurSceneView().cameraController.CanDrag = false;
        end
    end
end

function M:registerClickItem()
    --注册一个点击事件
    CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.selectTargetGrid))
    CS.GameObjectClickMgr.Inst:GetListeners();

    SceneManager:setData("show_loading_black", false)
    static_rootControl:updateMsg("close_battle_loading")
end



--场景加载完成
function M:closeloading()
    EventDispatcher:registerTimeEvent("delay_close_loading_time",function()
        static_rootControl:updateMsg("close_sync_load_big_loading");
    end,0.1,0.1)
end


--点击到某个物体
function M:selectTargetGrid( obj, data, id )
    if self.mouseDownTime > 0.2 then
        return;
    end
    --Logger.log(" 点击某个物体 ~~~!!!!!!!~~~~~~~~~~~~~~~~~~ "..obj.name )
    local strTab = string.split( obj.name,'_' )
    self.select_obj_name = obj.name
    local buildingIndex = tonumber(strTab[3])
    if buildingIndex ~= nil then
        local start_index = self:getCellStartIndex()
        local data = {}
        data.pos = UIUtil.ScenePosToUI(obj.transform.position)
        data.index = start_index == 0 and buildingIndex or (start_index - buildingIndex)
        if buildingIndex >= 0 and buildingIndex < self.BUILDINGS_COUNT and self.m_data.cells[tostring(buildingIndex)] then
            data.showDispatch = self.m_data.cells[tostring(buildingIndex)].can_battle or false
        else
            data.showDispatch = false
        end 
        audio:SendEvtUI("UI_Clck_N2")
        static_rootControl:updateMsg("cell_click", data, "UnionWar.UnionWarMain")       
    end
end

--帮会战
function M:getCurSceneName()
    self:createSceneConfig(123)
    if self.scene_info ~= nil then
        return self.scene_info.resource;
    else
        return "unionwar";
    end
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

function M:createOwnTeamSign()
    local teams = self.m_data.m_teams or {}
    local team_cell_map = {}
    for k, v in pairs(teams) do
        local cell_id = v.cell_id or 0
        if cell_id > 0 then
            if team_cell_map[cell_id] == nil then
                team_cell_map[cell_id] = {}
            end
            table.insert(team_cell_map[cell_id], tonumber(k))
        end
    end
    for k, v in pairs(self.m_fxFight) do
        local new_node = self.m_own_team_node_tab[k]
        local team_ids = team_cell_map[k]
        if IsNull(new_node) then
            new_node = GameUtil:instanceObject(self.m_own_team_node, self.m_own_team_node_parent)
            new_node:SetActive(true)
            local worldPointUI = new_node:GetComponent("WorldPointUI")
            worldPointUI.target = v.transform
            self.m_own_team_node_tab[k] = new_node
        end
        local luaBehaviour = UIUtil.findLuaBehaviour(new_node)
        for i = 1, 3 do
            if team_ids then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_img_" .. i, table.keyof(team_ids, i) ~= nil)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_img_" .. i, false)
            end
        end
    end
end

--销毁
function M:destroy( nextScene )
    GameMain.removeUpdate("UnionWar_Update");
    M.super.destroy(self,nextScene);
    EventDispatcher:unRegisterEvent("UnionWar_TeamChanged", {self,self.teamChangedHandler})
end

function M:createNum(num, map_ground, index, can_battle)
    if can_battle then
        if not IsNull(self.m_fxFight[index]) then
            self.m_fxFight[index]:SetActive(true)
        else
            self.m_fxFight[index] = SceneManager:getCurSceneView():instanceGameObject("Fx_UnionWar_001",self.scene_obj_meishu)
            self.m_fxFight[index].transform.position = map_ground.transform.position
        end
    else
        if not IsNull(self.m_fxFight[index]) then
            self.m_fxFight[index]:SetActive(false)
        end
    end
end

function M:teamChangedHandler( eventName, data )
    self:initBuildings()
end


return M