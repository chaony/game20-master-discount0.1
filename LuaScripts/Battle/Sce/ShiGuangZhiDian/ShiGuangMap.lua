--时光之巅场景
---@class ShiGuangMap @
local M = class("ShiGuangMap")

M.data = nil
M.datalist = nil
M. x = 0
M. y = 0

M.resData = nil

M.localresData = {"shiguang_room","shiguang_room","shiguang_room"}
M.demo = 1
M.scene = nil

--初始化场景
function M:load( scene )
    self.data = Battle.List.new()
    self.datalist =  Battle.List.new()
    self.resData =  Battle.List.new()
    self.scene = scene
    self.mouseDown = false
    self.sendToServerNow = false;
    self.autoReadTime = 3;
    self.autoReadTimeNow = self.autoReadTime;
    --拖拽按下
    self.dragMouseDown = false;
    self.mouseDownGapTime = 0;
    
    EventDispatcher:registerEvent("eventToView",{self,self.eventToView})
    if GlobalTools.isbattle and GlobalTools.selectGrid ~= nil then
		EventDispatcher:dipatchEvent("battleEnd",GlobalTools.selectGrid)
		GlobalTools.shiguang_data.grids:add(GlobalTools.selectGrid);
		GlobalTools.selectGrid = nil;
	end

    --物体表
    self.object_data = ConfigManager:getCfgByName("roleplaying_object")

    self.aStar = require("Battle.Data.AStarSix").new();
    self.aStar:init("ShiGuangSceneData")

    local block_net_data = SceneManager:getData("shiguang_block_net_data")
    local blocks = block_net_data.blocks;
    for k,v in pairs(blocks) do
        local grid_info = self:idToInfo(k);
        --格子上面放的东西
        local oid = v.oid or 0;
        --是否可以通过
        local pass = v.pass;
        --是否已经走过
        local passed = v.passed;
        --防守队伍
        local def_team = v.def_team;
        --动态值
        local dyns = v.dyns;
        --英雄
        local heros = v.heros;
        --遗物
        local heirloom_pool = v.heirloom_pool;
        --横向和纵向的格子索引
        local w = grid_info.x
        local h = grid_info.y
        --场景中的格子数据
        local grid_scene = self.aStar.sceneData.data[w][h]
        grid_scene:setValue(v.pass or 0);
        --已经走过了
        grid_scene.passed = passed;
        if oid ~= 0 then
            --不可行走
            grid_scene.data = self.object_data[self.scene.map_id][oid]
            if grid_scene.data ~= nil then
                grid_scene.data.chapter_id = self.scene.map_id;
                grid_scene.data.block_id = k;
                grid_scene.data.id = oid;
                --创建物体
                self:createObj(w, h, grid_scene.data )
                if def_team ~= nil then
                    grid_scene.data.def_team = def_team;
                end
                if dyns ~= nil then
                    grid_scene.data.dyns = dyns;
                end
                if heros ~= nil then
                    grid_scene.data.heros = heros;
                end
                if heirloom_pool ~= nil then
                    grid_scene.data.heirloom_pool = heirloom_pool;
                end
            else
                Logger.logError(" rpg 物件表中没有 mapid "..grid_info.mapid.." oid "..oid )
            end
        end
    end

    self.path = Battle.List.new()
    local cur_block_info = self:idToInfo(block_net_data.cur_block)
    local startx = cur_block_info.x;
    local starty = cur_block_info.y;
    self.startGrid = self.aStar.sceneData.data[startx][starty]
    self:createMaChe()
    self.isMove = false;
    SceneManager.eventMgr:start()
    for k,v in ipairs(block_net_data.event_list) do
        SceneManager.eventMgr:addEvent(v, nil);
    end
    block_net_data.event_list = {}
    SceneManager.eventMgr:trigger();
end


--解析服务器传来的id数据
--1001 00 00
function M:idToInfo( id )
    local id = tonumber(id);
    local grid_info = {}
    local mapid = math.floor(id/10000);
    local grid_x = math.floor(id/100) - mapid * 100;
    local grid_y = id - mapid * 10000 - grid_x * 100;
    grid_info.mapid = mapid;
    grid_info.x = grid_x;
    grid_info.y = grid_y;
    return grid_info
end


function M:getBlockDataByID( block_id )
    local grid_info = self:idToInfo(block_id);
    local grid_scene = self.aStar.sceneData.data[grid_info.x][grid_info.y];
    return grid_scene.data;
end


--信息装换成id
function M:infoToID( w, h, mapid )
    return mapid * 10000 + w * 100 + h
end


--事件层来的事件
function M:eventToView( eventName, data )
    local w = tonumber(data.w);
    local h = tonumber(data.h);
    if data.param == "over" then
        --副本结束
        static_rootControl:updateMsg("game_over", data, "Shiguang")
    elseif data.param == "storyEnd" then
        --对话结束
    end
end

--创建物件
function M:createObj( w, h, data )
    local grid = self.aStar.sceneData.data[w][h];
    if grid ~= nil then
        --npc 
        local obj = SceneManager.curScene:instanceGameObject(data.model_name, self.scene.obj)
        if obj ~= nil then
            obj.transform.position = grid.worldPosition;
            obj.transform.localScale = Vector3(1,1,1)
            grid.obj_model = obj;
            if data.start_switch == 0 then
                grid.obj_model:SetActive(false)
            end
        end
    end
end


--创建马车主人公
function M:createMaChe()
    local playerData = { id = self.scene.chapterData.hero_avater, evo = 0 }
    self.player = self.scene.plyMgr:createPlayer(playerData,1,0,function()
        local pos = GlobalTools:ToFixVector3(self.startGrid.position);
        self.player:setBaseScale(GlobalTools.base0_5)
        self.player:setPos(pos);
        self.scene.cameraController.Target = self.player.tran;
    end)
end


function M:battleEnd(data)
    Logger.log(data," ------------------------------ >>>>>> ")
end


--屏幕坐标到摄像机3D的坐标
function M:ScreenToCamera3D()
    local screenPos = Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, -11.8);
    local world_pos = self.scene.cameraController.Camera_3D:ScreenToWorldPoint(screenPos);
    return world_pos;
end


function M:MouseEvent(dt)

    if U3DUtil:Input_GetMouseButtonDown(0) then
        --解决透点问题
        self.mouseDownGapTime = U3DUtil:Time();
        if self.mouseDown == false then
            self:selectTargetGrid();
            self.mouseDown = true;
        end

        if self.dragMouseDown == false then
            --鼠标按下时的屏幕坐标
            self.mouseDownScreenPos = self:ScreenToCamera3D();
            self.dragMouseDown = true
        end
    end

    if U3DUtil:Input_GetMouseButtonUp(0) then
        self.mouseDown = false
        self.dragMouseDown = false;
        self:mouseUpEffect();
        if U3DUtil:Time() - self.mouseDownGapTime < 0.2 then
            if self.sendToServerNow == false then
                self:sendToServer();
            end
        end
    end

    if self.dragMouseDown then
        if static_rootControl:can3DTouchByViewName("Shiguang") then
            local world_pos_input = self:ScreenToCamera3D();
            local pos_cha = world_pos_input - self.mouseDownScreenPos;
            local camera_pos = self.scene.cameraController.Camera_3D.transform.position;
            camera_pos.x = camera_pos.x + pos_cha.x;
            camera_pos.z = camera_pos.z + pos_cha.z;
            if camera_pos.x < 0.49 then
                camera_pos.x = 0.49
            end
            if camera_pos.x > 18.69 then
                camera_pos.x = 18.69
            end
            if camera_pos.z > -10.34 then
                camera_pos.z = -10.34
            end
            if camera_pos.z < -26.15 then
                camera_pos.z = -26.15
            end
            self.scene.cameraController.Camera_3D.transform.position = camera_pos;
            self.mouseDownScreenPos = self:ScreenToCamera3D();
        end
    end
end


function M:selectTargetGrid()
    if self.isMove == false then
        local obj = CS.GameObjectClickMgr.Inst:GetMouseDownGameObject();
        if obj ~= nil then
            local strTab = string.split( obj.name,'_' )
            if string.find( strTab[1], "map" ) then
                local w = tonumber(strTab[4]);
                local h = tonumber(strTab[3]);
                --目标格子
                self.targetGrid = self.aStar.sceneData.data[w][h]
                self:mouseDownEffect(obj);
            end
        end
    end
end

function M:mouseUpEffect()
    if self.selectObj ~= nil then
        local pos = self.selectObj.transform.position;
        pos.y = self.selectObj_y_pos;
        self.selectObj.transform.position = pos;
        self.selectObj = nil;
    end
end

function M:mouseDownEffect(obj)
    self.path = self.aStar:findPath(self.startGrid,self.targetGrid)
    if self.path.Count > 0 then
        --点击效果
        if self.selectObj == nil then
            self.selectObj = obj;
            if self.selectObj ~= nil then
                local pos = self.selectObj.transform.position;
                self.selectObj_y_pos = pos.y;
                pos.y = self.selectObj_y_pos - 0.2;
                self.selectObj.transform.position = pos;
            end
        end
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0443"), delay_close = 2})
    end
end


function M:sendToServer()
    if self.targetGrid ~= nil then
        self.path = self.aStar:findPath(self.startGrid,self.targetGrid)
        if self.path.Count > 0 then
            self:resetCameraPosition();
            local path_list = {}
            for i=1,self.path.Count do
                local grid = self.path:get(i-1);
                local grid_id = self:infoToID(grid.index_pos.x,grid.index_pos.y,self.scene.map_id)
                path_list[i] = grid_id;
            end
            local cur_select_id = self:infoToID(self.targetGrid.index_pos.x,self.targetGrid.index_pos.y,self.scene.map_id)
            UserDataManager:setTempData("shiguang_grid_data",{chapter_id = self.scene.map_id,block_id = cur_select_id});
            self.sendToServerNow = true;
            self.scene:sendEvent("rpg_goto",{chapter_id = self.scene.map_id,block_id = cur_select_id,path = path_list },"Shiguang")
        end
    end
end

function M:onlyMyGrid( list )
    if list.Count == 1 then
        for i=1,list.Count do
            local grid = list:get(i-1);
            if self.startGrid:equip(grid) then
                return true
            end
        end
    end
    return false;
end


--更新场景
--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    if self.isMove == true then
        if self.nextGrid ~= nil then
            local grid_fix_pos = GlobalTools:ToFixVector3(self.nextGrid.worldPosition);
            local dir = GlobalTools:Dir(grid_fix_pos,self.player.position);
            local distance = GlobalTools:Distance(self.player.position, grid_fix_pos);
            self.player:setForward(dir)
            if distance > GlobalTools:ToFix2(0.1) then
                self.player:move_no_coillder(dir, dt);
            else
                self.nextGrid = nil;
            end
        end
    
        ---移动
        if self.path.Count > 0 then
            if self.nextGrid == nil then
                self.nextGrid = self.path:get(0);
                self.path:removeAt(0);
            end
        else
            if self.nextGrid == nil then
                self.targetGrid = nil;
                self.isMove = false;
                self.player.animator:changeState("idle")
                self.sendToServerNow = false;
                SceneManager.eventMgr:trigger();
            end
        end
    end

    if self.sendToServerNow == true then
        if self.autoReadTimeNow > 0 then
            self.autoReadTimeNow  = self.autoReadTimeNow - dt;
            if self.autoReadTimeNow <= 0 then
                self.sendToServerNow = false;
                self.autoReadTimeNow = self.autoReadTime;
            end
        end
    end
end

function M:resetCameraPosition()
    self.scene.cameraController.Camera_3D.transform.localPosition = Vector3(0,8.83,-10.727) 
end

--地图重置
function M:rpgMapReset()

end

--战斗开始
function M:rpgBattleStart()

end

function M:rpgClickObj(net_data)
    local grid_info = self:idToInfo(net_data.click_block);
    local curGrid = self.aStar.sceneData.data[grid_info.x][grid_info.y];
    curGrid:setValue(0);
    if curGrid.obj_model ~= nil then
        curGrid.obj_model:SetActive(false);
        curGrid.obj_model = nil;
        curGrid.data = nil;
    end
    for k,v in ipairs(net_data.event_list) do
        SceneManager.eventMgr:addEvent(v, nil);
    end
    SceneManager.eventMgr:trigger();
end

--战斗结束
function M:rpgBattleEnd(net_data)
    Logger.log(net_data, " rpgBattleEnd Data ---- >")
    for k,v in ipairs(net_data.event_list) do
        SceneManager.eventMgr:addEvent(v, nil);
    end
    SceneManager.eventMgr:trigger();
end

--选择了一个事件
function M:rpgChioceOption(net_data)
    Logger.log(net_data, " rpgGoto Data ---- >")
    
end


--刷新本地缓存数据
function M:RefreshGridData()
    local block_net_data = SceneManager:getData("shiguang_block_net_data");
    if block_net_data ~= nil then
        local blocks = block_net_data.blocks;
        for k,v in pairs(blocks) do
            self:updateGridData(k,v);
        end
    end
end


function M:updateGridData(k, v)
    local grid_info = self:idToInfo(k);
    --格子上面放的东西
    local oid = v.oid or 0;
    --是否可以通过
    local pass = v.pass;
    --是否已经走过
    local passed = v.passed;
    --防守队伍
    local def_team = v.def_team;
    --动态值
    local dyns = v.dyns;
    --英雄
    local heros = v.heros;
    --遗物
    local heirloom_pool = v.heirloom_pool;
    --横向和纵向的格子索引
    local w = grid_info.x
    local h = grid_info.y
    --场景中的格子数据
    local grid_scene = self.aStar.sceneData.data[w][h]
    grid_scene:setValue(v.pass or 0);
    --已经走过了
    grid_scene.passed = passed;
    if oid ~= 0 then
        if grid_scene.obj_model ~= nil then
            U3DUtil:Destroy(grid_scene.obj_model);
            grid_scene.obj_model = nil;
            grid_scene:setValue(0)
        end
        --不可行走
        grid_scene.data = self.object_data[self.scene.map_id][oid]
        if grid_scene.data ~= nil then
        
            grid_scene.data.chapter_id = self.scene.map_id;
            grid_scene.data.block_id = k;
            grid_scene.data.id = oid;

            local obj = SceneManager.curScene:instanceGameObject(grid_scene.data.model_name, SceneManager.curScene.obj)
            obj.transform.position = grid_scene.worldPosition;
            obj.transform.localScale = Vector3(1,1,1)
            grid_scene.obj_model = obj;
            grid_scene:setValue(1)

            if def_team ~= nil then
                grid_scene.data.def_team = def_team;
            end
            if dyns ~= nil then
                grid_scene.data.dyns = dyns;
            end
            if heros ~= nil then
                grid_scene.data.heros = heros;
            end
            if heirloom_pool ~= nil then
                grid_scene.data.heirloom_pool = heirloom_pool;
            end
        else
            Logger.logError(" rpg 物件表中没有 mapid "..grid_info.mapid.." oid "..oid )
        end
    else
        if grid_scene.obj_model ~= nil then
            U3DUtil:Destroy(grid_scene.obj_model);
            grid_scene.obj_model = nil;
            grid_scene:setValue(0)
        end
        grid_scene.data = nil;
    end

end



function M:rpgGoto(data)
    Logger.log(data, " rpgGoto Data ---- >")
    --next判断是否是空表
    if next(data) ~= nil then
        local cur_block_info = self:idToInfo(data.cur_block); 
        local cur_click_info = self:idToInfo(data.click_id);
        local click_grid = self.aStar.sceneData.data[cur_click_info.x][cur_click_info.y]

        --如果有事件就加入事件管理器中
        for k,v in ipairs(data.event_list) do
            SceneManager.eventMgr:addEvent(v, click_grid.data);
        end

        self.path:clear();
        for k,v in ipairs(data.path) do
            local grid_info = self:idToInfo(v);
            local grid = self.aStar.sceneData.data[grid_info.x][grid_info.y]
            self.path:add(grid);
        end

        if self.path.Count > 0 then
            self.isMove = true;
            self.player.animator:changeState("run")
            self.startGrid_temp = self.startGrid;
            self.startGrid = self.path:get(self.path.Count - 1)
        end

        if click_grid.data ~= nil then
            local eventId = self:getEventId(click_grid.data);
            SceneManager.eventMgr:addEvent(eventId, click_grid.data);
        end
    end
end


function M:getEventId( data )
    return 9000000 + data.type;
end



function M:destroy()
    self.aStar:destroy();
    EventDispatcher:unRegisterEvent("eventToView",{self,self.eventToView});
end

return M