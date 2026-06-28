
--聚宝山场景
---@class JuBaoShanScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("JuBaoShanScene_Model",Battle.Scene_Model)


--初始化场景
function M:init()
    M.super.init(self)
end

--进入场景
function M:enter( data )
    M.super.enter( self, data )
    self.event_task_list = Battle.List.new()
    self.ui_task_list = Battle.List.new()
    self.curTalkDelayTime = 2;
    self.curTalkTime = 12;
    self.moveTime = GlobalTools.base0_5;
    self.curMoveTime = 0;
    self.startPlayerMove = false
    --当前位置
    self.curPostion = FixVector3.New(0,0,0)
    --目标位置
    self.targetPostion = FixVector3.New(0,0,0)
    --开始位置
    self.startPostion = FixVector3.New(0,0,0)
    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
end

--迷宫场景
function M:getCurSceneName()
    --self:createSceneConfig(103)
    --return self.scene_info.resource;
    return "jubaoshan"
end

--子类重写
function M:getCurSceneObjName()
    return "jubaoshan_data";
end

--加载完成
function M:loadFinish()
    GameMain.addUpdate("Maze_Update", handler(self,self.UnityUpdate))
    self.scene_obj_meishu = U3DUtil:GameObject_Find("Scene");
    self.isMove = false;
    self.local_cell_data = ConfigManager:getCfgByName("jubaoshan_map~"..self.m_data.map_id)
    if self.local_cell_data ~= nil then
        self:parseCellDatas( self.local_cell_data )
    else
        static_rootControl:updateMsg("close_sync_load_big_loading");
    end
    static_rootControl:updateMsg("load_scene_finish", nil, "JuBaoShan")
    --注册一个点击事件
    CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.selectTargetGrid))
    CS.GameObjectClickMgr.Inst:GetListeners();
end


--点击到某个物体
function M:selectTargetGrid( obj, data, id )
    --点击到物体的名字
    local strTab = string.split( obj.name,'_' )
    local obj_from_x = strTab[2];
    local obj_from_y = strTab[3];
    local obj_key = self:infoToID(tonumber(obj_from_x), tonumber(obj_from_y))
    local clickCellInfo = self.allCellPools[obj_key];
    if clickCellInfo ~= nil then
        self:clickCellUIPanel(clickCellInfo)
    end
end


function M:FocusBuilding( clickCellInfo )
    if not IsNull(clickCellInfo.building) then
        SceneManager:getCurSceneView().cameraController.Target = clickCellInfo.building.transform
        TimeTools:delayTimeUnity(0.5,function()
            SceneManager:getCurSceneModel():showCellUIPanel(clickCellInfo, 1)
        end)
    end
end


function M:clickCellUIPanel( clickCellInfo )
    --建筑和钱庄都会弹出界面
    --建筑弹出界面是1级以上就可以随时点开，随时可以派遣侠客
    if clickCellInfo.cell_config ~= nil and clickCellInfo.cell_config.interface_id > 0 then
        if clickCellInfo.cell_type == 4 then
            if clickCellInfo.lv ~= nil and clickCellInfo.lv > 0 then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("cell_click",click_cell_info,"JuBaoShan")
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(clickCellInfo.cell_config.point_out), delay_close = 2})
            end
        elseif clickCellInfo.cell_type == 2 then
            --钱庄是需要走到位置才能点开，并且派遣侠客
            if self.cur_cell.cell_index == clickCellInfo.cell_index then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("cell_click",click_cell_info,"JuBaoShan")
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(clickCellInfo.cell_config.point_out), delay_close = 2})
            end
        elseif clickCellInfo.cell_type == 3 then
            if self.cur_cell.cell_index == clickCellInfo.cell_index then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("cell_click",click_cell_info,"JuBaoShan")
            end
        end
    else
        if clickCellInfo.cell_type == 1 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(clickCellInfo.cell_config.point_out), delay_close = 2})
        end
    end
end

-- 被动弹出
function M:showCellUIPanel( clickCellInfo, mode )
    --建筑和钱庄都会弹出界面
    --建筑弹出界面是1级以上就可以随时点开，随时可以派遣侠客
    if clickCellInfo.cell_config ~= nil and clickCellInfo.cell_config.interface_id > 0 then
        if clickCellInfo.cell_type == 4 then
            local hasEmpty = self:hasEmptySlot(clickCellInfo)
            local levelUp = clickCellInfo.levelUp;
            if mode == 1 then
                levelUp = true;
            end
            if clickCellInfo.lv ~= nil and clickCellInfo.lv > 0 and levelUp == true and hasEmpty == true then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("passiveCell_click",click_cell_info,"JuBaoShan")
            end
        elseif clickCellInfo.cell_type == 2 then
            --钱庄是需要走到位置才能点开，并且派遣侠客
            if self.cur_cell.cell_index == clickCellInfo.cell_index then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("passiveCell_click",click_cell_info,"JuBaoShan")
            end
        elseif clickCellInfo.cell_type == 3 then
            if self.cur_cell.cell_index == clickCellInfo.cell_index then
                local click_cell_info = self:getCellInfo(clickCellInfo)
                static_rootControl:updateMsg("passiveCell_click",click_cell_info,"JuBaoShan")
            end
        end
    end
end


function M:hasEmptySlot(cell_data)
    local evo_condition = {}
    --需要的条件
    local slotNum = 0;
    for i, v in pairs(cell_data.cell_config.slot) do
        slotNum = slotNum + 1;
        evo_condition[i] = v;
    end

    local max_solt_num = 0;
    for i = 1, slotNum do
        local need_lv = evo_condition[i][1]
        if cell_data.lv >= need_lv then
            max_solt_num = i;
        end
    end

    local team_number = 0;
    if cell_data.team ~= nil and _G.next(cell_data.team) ~= nil then
        for i, v in pairs(cell_data.team) do
            team_number = team_number + 1;
        end
        if team_number < max_solt_num then
            return true
        end
    else
        return true
    end
    return false;
end


function M:getCellInfo( clickCellInfo )
    local cellInfo = {}
    --所有已经在建筑中的玩家
    cellInfo.buildingPlayers = {}
    cellInfo.clickCellInfo = clickCellInfo;
    for i, v in ipairs(self.indexToCellPools) do
        if v.team ~= nil then
            for j, jv in ipairs(v.team) do
                table.insert(cellInfo.buildingPlayers,jv);
            end
        end
    end
    return cellInfo;
end


--信息装换成id
function M:infoToID( w, h )
    return tonumber(self.m_data.map_id) * 10000 + w * 100 + h
end


--解析服务器传来的id数据
--1001 00 00
function M:idToInfo( id )
    local id = tonumber(id);
    local cellInfo = {}
    local mapid = math.floor(id/10000);
    local grid_x = math.floor(id/100) - mapid * 100;
    local grid_y = id - mapid * 10000 - grid_x * 100;
    cellInfo.mapid = mapid;
    cellInfo.x = grid_x;
    cellInfo.y = grid_y;
    return cellInfo
end

--解析格子数据
function M:parseCellDatas( cell_datas )
    self.dice_cell_type_config = ConfigManager:getCfgByName("dice_cell_type");
    --全部格子
    local all_cells = cell_datas;
    --道路格子
    local load_cells = self.m_data.cells;
    --全局格子
    local load_global_cells = self.m_data.global_cells;

    self.max_cell_num = 0;
    self.min_cell_num = 9999;

    self.indexToCellPools = {}
    self.allCellPools = {}
    self.noCreateLandCells = {}
    self.cellTypeToCellPools = {}
    
    self.max_x = 0;
    self.max_y = 0;
    for i, v in pairs(all_cells) do
        local cellInfo = self:idToInfo(i);
        if self.max_x < cellInfo.x then
            self.max_x = cellInfo.x;
        end
        if self.max_y < cellInfo.y then
            self.max_y = cellInfo.y;
        end
    end
    
    local map_11 = U3DUtil:GameObject_Find("map_11");
    local map_9 = U3DUtil:GameObject_Find("map_9");
    local left_Top = U3DUtil:GameObject_Find("Left_Top");
    local right_bottom = U3DUtil:GameObject_Find("Right_Bottom");
    if self.max_x == 10 then
        map_11:SetActive(true);
        map_9:SetActive(false);
    else
        map_11:SetActive(false);
        map_9:SetActive(true);
        left_Top.transform.localPosition = Vector3(9.19,0,3.4)
        right_bottom.transform.localPosition = Vector3(27.56,0,23.5)
    end

    self.noCreateLandCells[self:infoToID(0,0)] = 1
    self.noCreateLandCells[self:infoToID(0,1)] = 1
    self.noCreateLandCells[self:infoToID(1,0)] = 1

    self.noCreateLandCells[self:infoToID(self.max_x-1,0)] = 1
    self.noCreateLandCells[self:infoToID(self.max_x,0)] = 1
    self.noCreateLandCells[self:infoToID(self.max_x,1)] = 1

    self.noCreateLandCells[self:infoToID(self.max_x-1,self.max_y)] = 1
    self.noCreateLandCells[self:infoToID(self.max_x,self.max_y)] = 1
    self.noCreateLandCells[self:infoToID(self.max_x,self.max_y-1)] = 1

    self.noCreateLandCells[self:infoToID(0,self.max_y)] = 1
    self.noCreateLandCells[self:infoToID(1,self.max_y)] = 1
    self.noCreateLandCells[self:infoToID(0,self.max_y-1)] = 1
    
    --遍历所有格子
    for i, v in pairs(all_cells) do
        local cellInfo = self:idToInfo(i);
        self:initCellInfo(cellInfo, v);
        --pass如果小于0，表示不可见
        cellInfo.localPosition = Vector3(cellInfo.x * 3, -0.25, cellInfo.y * 3 );
        cellInfo.localBuildPosition = Vector3(cellInfo.x * 3, 0, cellInfo.y * 3 );
        --构建地图
        if cellInfo.pass >= 0 then
            if self.noCreateLandCells[i] == nil and cellInfo.cell_index == 0 then
                --cellInfo.view = SceneManager:getCurSceneView():instanceGameObject("Land",self.scene_obj_meishu);
                --cellInfo.view.transform.localPosition = cellInfo.localPosition
                --cellInfo.view.name = cellInfo.x.."_"..cellInfo.y.."@"..cellInfo.cell_index
            end
        end
        if cellInfo.cell_index == 1 then
            cellInfo.view = SceneManager:getCurSceneView():instanceGameObject("Fx_JuBaoPen_QiDian",self.scene_obj_meishu);
            cellInfo.view.transform.localPosition = cellInfo.localPosition
            cellInfo.view.name = cellInfo.x.."_"..cellInfo.y.."@"..cellInfo.cell_index
        end
        --注册通过 index 获取 cell 的映射
        if cellInfo.cell_index > 0 then
            if self.indexToCellPools[cellInfo.cell_index] == nil then
                self.indexToCellPools[cellInfo.cell_index] = {}
            end
            if self.min_cell_num > cellInfo.cell_index then
                self.min_cell_num = cellInfo.cell_index;
            end
            if self.max_cell_num < cellInfo.cell_index then
                self.max_cell_num = cellInfo.cell_index;
            end
            self.indexToCellPools[cellInfo.cell_index] = cellInfo;
        end
        if cellInfo.id > 0 then
            if self.cellTypeToCellPools[cellInfo.cell_type] == nil then
                self.cellTypeToCellPools[cellInfo.cell_type] = {}
            end
            table.insert(self.cellTypeToCellPools[cellInfo.cell_type], cellInfo)
            if cellInfo.cell_type == 6 then
                self:createRoom(cellInfo)
            end
        end
        self.allCellPools[i] = cellInfo;
    end

    if self.m_data.cur_pos == 0 then
        self.m_data.cur_pos = 1;
    end
    self:setCurCell(self.indexToCellPools[self.m_data.cur_pos])

    --更新服务器的数据
    for i, v in pairs(load_cells) do
        local cellInfo = self.indexToCellPools[tonumber(i)]
        if cellInfo ~= nil then
            cellInfo.id = v.building_id;
            cellInfo.cell_type = v.type;
            if v.trigger_time ~= nil then
                cellInfo.trigger_time = v.trigger_time;
            end
            if v.award ~= nil then
                cellInfo.trigger_time = v.award;
            end
            if v.limit then
                cellInfo.limit = v.limit
            end
            if v.lv ~= nil then
                cellInfo.lv = v.lv;
                cellInfo.last_lv = v.lv;
            end
            if v.team ~= nil then
                cellInfo.team = v.team;
            end
            if v.max_award ~= nil then
                cellInfo.max_award = v.max_award;
            end
            if v.gift ~= nil then
                cellInfo.gift = v.gift;
            end
            if cellInfo.id > 0 then
                self:createRoom(cellInfo)
            end
        end
    end
    
    --只更新队伍
    for i, v in pairs(load_global_cells) do
        --格子id 
        local cell_type = tonumber(i);
        local cell_list = self.cellTypeToCellPools[cell_type]
        for cell_i, cell_info in ipairs(cell_list) do
            cell_info.team = v.team;
        end
    end
    
    static_rootControl:updateMsg("buildData",nil,"JuBaoShan")
    --创建人物
    self:createPlayer();
end


--获取方向
-- 1 上 2 下 3 左 4 右 
function M:getDirection( cellInfo )
    local top_grid = { x = cellInfo.x, y = cellInfo.y + 1 }
    local bottom_grid = { x = cellInfo.x, y = cellInfo.y - 1 }
    local left_grid = { x = cellInfo.x - 1, y = cellInfo.y }
    local right_grid = { x = cellInfo.x + 1, y = cellInfo.y }
    local top_key = self:infoToID(top_grid.x, top_grid.y);
    local top_cell_info = self.allCellPools[top_key];
    local bottom_key = self:infoToID(bottom_grid.x, bottom_grid.y);
    local bottom_cell_info = self.allCellPools[bottom_key];
    local left_key = self:infoToID(left_grid.x, left_grid.y);
    local left_cell_info = self.allCellPools[left_key];
    local right_key = self:infoToID(right_grid.x, right_grid.y);
    local right_cell_info = self.allCellPools[right_key];
    if cellInfo.cell_type == 6 then
        if top_cell_info ~= nil and top_cell_info.cell_index > 0 then
            return 1;
        end
        if bottom_cell_info ~= nil and bottom_cell_info.cell_index > 0 then
            return 2;
        end
        if left_cell_info ~= nil and left_cell_info.cell_index > 0 then
            return 3;
        end
        if right_cell_info ~= nil and right_cell_info.cell_index > 0 then
            return 4;
        end
    else
        if top_cell_info ~= nil and top_cell_info.pass < 0 then
            return 1;
        end
        if bottom_cell_info ~= nil and bottom_cell_info.pass < 0 then
            return 2;
        end
        if left_cell_info ~= nil and left_cell_info.pass < 0 then
            return 3;
        end
        if right_cell_info ~= nil and right_cell_info.pass < 0 then
            return 4;
        end
    end
    return 1;
end


--通过索引获取格子信息
function M:getCellInfoByIndex( index )
    return self.indexToCellPools[index];
end


--派遣和撤回服务器数据更新
function M:updateCellInfoBySendServerData( data )
    local cells = data.cells;
    if cells ~= nil then
        for i, v in pairs(cells) do
            self:updateCellInfoByServerData( tonumber(i), v );
        end
    end
    
    local global_cells = data.global_cells;
    if global_cells ~= nil then
        --只更新队伍
        if _G.next(global_cells) ~= nil then
            for i, v in pairs(global_cells) do
                --格子id 
                local cell_type = tonumber(i);
                self:updateGloablCells(cell_type, v);
            end
        else
            local cell_list = self.cellTypeToCellPools[2]
            for cell_i, cell_info in ipairs(cell_list) do
                cell_info.team = nil;
            end
        end
    end
end


function M:updateGloablCells( cell_type, cell_data )
    local cell_list = self.cellTypeToCellPools[cell_type]
    for cell_i, cell_info in ipairs(cell_list) do
        cell_info.team = cell_data.team;
    end
end



function M:updateCellInfoByServerData( index, serverData )
    local createBuilding = false;
    local cellInfo = self.indexToCellPools[index];
    if cellInfo ~= nil then
        if cellInfo.id ~= serverData.building_id then
            cellInfo.id = serverData.building_id;
            createBuilding = true;
        end
        cellInfo.cell_type = serverData.type;
        --建筑触发次数
        if serverData.trigger_time ~= nil then
            cellInfo.trigger_time = serverData.trigger_time;
        else
            cellInfo.trigger_time = nil;
        end
        
        if serverData.limit then
            cellInfo.limit = serverData.limit
        end

        if serverData.award ~= nil then
            cellInfo.trigger_time = serverData.award;
        end
        
        if serverData.max_award ~= nil then
            cellInfo.max_award = serverData.max_award;
        end
        --建筑等级
        if serverData.lv ~= nil then
            cellInfo.lv = serverData.lv;
            --检测是否是升级
            if cellInfo.lv ~= cellInfo.last_lv then
                cellInfo.levelUp = true;
                cellInfo.last_lv = cellInfo.lv
            else
                cellInfo.levelUp = false;
            end
        end

        --gift
        cellInfo.gift = serverData.gift;
        
        --更新队伍
        cellInfo.team = serverData.team;
        --服务器要我销毁这个格子上的东西
        if cellInfo.id <= 0 then
            if not IsNull(cellInfo.building) then
                self:destoryBuilding(cellInfo.building)
                cellInfo.building = nil;
            end
        else
            if createBuilding then
                if not IsNull(cellInfo.building) then
                    self:destoryBuilding(cellInfo.building)
                    cellInfo.building = nil;
                end
                self:createRoom(cellInfo)
            end
        end
        self.ui_task_list:add(cellInfo)
        --更新UI
        self:setUI(cellInfo)
    end
end


function M:destoryBuilding( obj )
    obj.transform:DOLocalMoveY(3.41, 0.5):SetEase(Tweening.Ease.OutSine)
    TimeTools:delayTimeUnity(1, function()
        U3DUtil:GameObjectDestroy( obj )
    end)
end



function M:createRoom( cellInfo )
    if cellInfo.connection ~= nil and cellInfo.connection ~= "" then
        local pos_index = string.split(cellInfo.connection,"_")
        local key = self:infoToID(tonumber(pos_index[1]), tonumber(pos_index[2]));
        local connection_cell = self.allCellPools[key];
        connection_cell.dir = self:getDirection(cellInfo)
        cellInfo.building = SceneManager:getCurSceneView():instanceGameObject("Room_"..cellInfo.id,self.scene_obj_meishu);
        if cellInfo.building ~= nil then
            cellInfo.building.transform.localPosition = connection_cell.localBuildPosition
            cellInfo.building.name = "from_"..cellInfo.x.."_"..cellInfo.y;
            local gameUI =  cellInfo.building:GetComponent( "JuBaoShan3DUI" )
            cellInfo.uiObj = gameUI:CreateUI("JuBaoUI");
            cellInfo.rewardObj = gameUI:CreateUI("JuBaoRewardUI");
            cellInfo.rewardObj:SetActive(false);
            self:setBuildingDir(connection_cell, cellInfo, gameUI);
            self:setUI(cellInfo)
            self:setUILv(cellInfo)
        end
    else
        cellInfo.building = SceneManager:getCurSceneView():instanceGameObject("Room_"..cellInfo.id,self.scene_obj_meishu);
        if cellInfo.building ~= nil then
            cellInfo.building.transform.localPosition = cellInfo.localBuildPosition
            cellInfo.building.name = "from_"..cellInfo.x.."_"..cellInfo.y
            if cellInfo.cell_type ~= 6 then
                self:setUI(cellInfo)
                self:setUILv(cellInfo)
            else
                cellInfo.dir = self:getDirection(cellInfo)
                self:setBuildingDir(cellInfo, cellInfo, nil);
            end
        end
    end
end


function M:setUILv( cellInfo )
    if cellInfo.uiObj ~= nil then
        local lua_behaviour = cellInfo.uiObj:GetComponent("LuaBehaviour");
        local lock_text = lua_behaviour:FindText("lock_text")
        local complete_img = lua_behaviour:FindGameObject("complete_img")
        if cellInfo.lv >= 0 then
            complete_img:SetActive(true);
            lock_text.gameObject:SetActive(true)
            lock_text.text = cellInfo.lv..Language:getTextByKey("new_str_0428")
        else
            complete_img:SetActive(false);
            lock_text.gameObject:SetActive(false)
        end
    end
end


function M:setUI( cellInfo )
    if cellInfo.uiObj ~= nil then
        local lua_behaviour = cellInfo.uiObj:GetComponent("LuaBehaviour");
        local bg = lua_behaviour:FindImage("bg")
        local brand_text = lua_behaviour:FindText("brand_text")
        local lock_text = lua_behaviour:FindText("lock_text")
        local complete_img = lua_behaviour:FindGameObject("complete_img")
        local add_sign = lua_behaviour:FindGameObject("add_sign")
        if cellInfo.cell_config ~= nil then
            brand_text.text = Language:getTextByKey(cellInfo.cell_config.name);
        else
            brand_text.text = "??";
        end
        --if cellInfo.lv >= 0 then
        --    complete_img:SetActive(true);
        --    lock_text.gameObject:SetActive(true)
        --    lock_text.text = cellInfo.lv..Language:getTextByKey("new_str_0428")
        --else
        --    complete_img:SetActive(false);
        --    lock_text.gameObject:SetActive(false) 
        --end
        
        --槽位
        local evo_condition = {}
        --需要的条件
        local slotNum = 0;
        if cellInfo.cell_config ~= nil then
            local slotData = cellInfo.cell_config.slot or {}
            for i, v in pairs(slotData) do
                slotNum = slotNum + 1;
                evo_condition[i] = v;
            end
        end

        local max_solt_num = 0;
        for i = 1, slotNum do
            local need_lv = evo_condition[i][1]
            if cellInfo.lv >= need_lv then
                max_solt_num = i;
            end
        end
        
        local index = 0
        if cellInfo.team ~= nil and _G.next(cellInfo.team) ~= nil then
            for i, v in pairs(cellInfo.team) do
                index = index + 1;
            end
        end

        if index ~= max_solt_num then
            add_sign:SetActive(true);
        else
            add_sign:SetActive(false);
        end
    end

    if cellInfo.rewardObj ~= nil then
        --显示奖励
        if cellInfo.gift ~= nil and _G.next(cellInfo.gift) ~= nil then
            cellInfo.rewardObj:SetActive(true);
            local lua_behaviour = cellInfo.rewardObj:GetComponent("LuaBehaviour");
            local data = RewardUtil:getProcessRewardData(cellInfo.gift[1])
            local maxbg = lua_behaviour:FindGameObject("maxbg");
            local bg = lua_behaviour:FindGameObject("bg");
            local reward = lua_behaviour:FindGameObject("reward");
            GameUtil:updateItemElementByData(reward, data, true)
            local limit = cellInfo.cell_config.limit or 999;
            if cellInfo.limit ~= nil then
                limit = cellInfo.limit
            end
            if data.data_num >= limit then
                maxbg:SetActive(true);
                bg:SetActive(false);
            else
                maxbg:SetActive(false);
                bg:SetActive(true);
            end
        else
            cellInfo.rewardObj:SetActive(false);
        end
    end
end


function M:setBuildingDir( connection_cell, cellInfo, gameUI )
    if connection_cell.dir ~= nil then
        local luaTransform = cellInfo.building:GetComponent(typeof(CS.LuaTransformHelper));
        if connection_cell.dir == 1 then
            local obj = luaTransform:FindObj(cellInfo.building.transform,"bottom");
            if obj ~= nil then
                obj:SetActive(true);
                local head_obj = luaTransform:FindObj(obj.transform,"head");
                if head_obj ~= nil and gameUI ~= nil then
                    gameUI.moveTarget = head_obj.transform;
                end
            end
        elseif connection_cell.dir == 2 then
            local obj = luaTransform:FindObj(cellInfo.building.transform,"top");
            if obj ~= nil then
                obj:SetActive(true);
                local head_obj = luaTransform:FindObj(obj.transform,"head");
                if head_obj ~= nil and gameUI ~= nil then
                    gameUI.moveTarget = head_obj.transform;
                end
            end
        elseif connection_cell.dir == 3 then
            local obj = luaTransform:FindObj(cellInfo.building.transform,"right");
            if obj ~= nil then
                obj:SetActive(true);
                local head_obj = luaTransform:FindObj(obj.transform,"head");
                if head_obj ~= nil and gameUI ~= nil then
                    gameUI.moveTarget = head_obj.transform;
                end
            end
        elseif connection_cell.dir == 4 then
            local obj = luaTransform:FindObj(cellInfo.building.transform,"left");
            if obj ~= nil then
                obj:SetActive(true);
                local head_obj = luaTransform:FindObj(obj.transform,"head");
                if head_obj ~= nil and gameUI ~= nil then
                    gameUI.moveTarget = head_obj.transform;
                end
            end
        end
    end
end


--通过index获取格子信息
function M:updateCellInfoByIndex( index, data )
    local cell = self.indexToCellPools[index];
    self:initCellInfo( cell, data );
end

--更新格子信息
function M:initCellInfo( cellInfo, data )
    --格子配置
    if data.cell_type ~= nil and data.cell_type > 0 and data.id ~= nil and data.id > 0 then
        local map_config = self.dice_cell_type_config[self.m_data.map_id]
        if map_config ~= nil then
            local cell_config = map_config[data.cell_type]
            if cell_config ~= nil then
                cellInfo.cell_config = cell_config[data.id]
                if cellInfo.cell_config ~= nil and cellInfo.cell_config.param.reward ~= nil then
                    --最大等级
                    cellInfo.max_lv = #cellInfo.cell_config.param.reward
                else
                    cellInfo.max_lv = 999;
                end
            else
                cellInfo.max_lv = 999;
            end
        else
            cellInfo.max_lv = 999;
        end
        
    end
    cellInfo.max_lv = cellInfo.max_lv or 999
    --连接字符串
    cellInfo.connection = data.connection;
    --建筑id
    cellInfo.id = data.id;
    --皮肤id
    cellInfo.skinid = data.skinid;
    --格子索引
    cellInfo.cell_index = data.cell_index;
    --是否可以通过
    cellInfo.pass = data.pass;
    --格子类型
    cellInfo.cell_type = data.cell_type;
    --组
    cellInfo.group = data.group;
    --初始化等级
    cellInfo.lv = -1;
    --上一次的等级
    cellInfo.last_lv = -1;
    --是否是升级
    cellInfo.levelUp = false;
end

--摇骰子
function M:Roll( data )
    --SceneManager:getCurSceneView().cameraController.transform.position = self.player_view:get_position()
    --SceneManager:getCurSceneView().cameraController:ResetStart();
    self.ui_task_list:clear()
    SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
    --Logger.logError( data,"  Roll Data ")
    self.roll_data = data;
    --任务开始标识
    self.task_start = false;
    self.event_task_list:clear();
    self.cur_task = nil;
    for i, v in ipairs(self.roll_data.events) do
        if v.action ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "play_move";
            task_item_data.m_action = v.action;
            task_item_data.m_target = v.cell_id;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self, task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
        if v.cells ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "update_cells";
            task_item_data.m_cells = v.cells;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self,task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
        if v.global_cells ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "update_global_cells";
            task_item_data.m_cells = v.global_cells;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self,task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
        if v.reward ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "get_reward";
            task_item_data.m_reward = v.reward;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self,task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
        if v.event_id ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "get_event";
            task_item_data.m_event_type = math.floor(v.event_id/100)
            task_item_data.m_event_id = v.event_id;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self,task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
        if v.cycle_reward ~= nil then
            local task_item_data = {}
            --任务类型
            task_item_data.m_type = "cycle_reward";
            task_item_data.m_reward = v.cycle_reward;
            local task_item = require("Battle.Sce.JuBaoShan.JuBaoShanTaskItem").new();
            task_item:init(self,task_item_data, handler(self,self.taskFinish))
            self.event_task_list:add(task_item)
        end
    end
    
    self.task_start = true;
    --7秒之后 强制解锁 解锁
    --TimeTools:delayTimeUnity(7, function()
    --    static_rootControl:updateMsg("unlockTouch",nil,"JuBaoShan")
    --end)
end


--任务完成
function M:taskFinish()
    self.event_task_list:removeAt(0);
    self.cur_task = nil;
    self:curCellAnim();
end


--更新任务
function M:updateTask( dt )
    if self.task_start then
        if self.event_task_list.Count > 0 then
            if self.cur_task == nil then
                --取出来一个任务
                self.cur_task = self.event_task_list:get(0)
                self.cur_task:start();
            end
            if self.cur_task ~= nil then
                self.cur_task:update( dt );
            end
        else
            self.task_start = false;
            if self.cur_cell.cell_type == 4 and self.cur_cell.lv < 5 then
                if self.cur_cell.building ~= nil then
                    if self.cur_cell.levelUp == true then
                        if self.shengji == nil then
                            audio:SendEvtUI("UI_Building_Fx")
                            self.shengji = SceneManager:getCurSceneView():instanceGameObject("Hero_ShengJi_002");
                            self.shengji.transform:SetParent(self.cur_cell.building.transform);
                            self.shengji.transform.localPosition = Vector3(0,0,0)
                        end
                    end
                end
            end

            static_rootControl:updateMsg("taskFinish",nil,"JuBaoShan")
            TimeTools:delayTimeUnity(0.016, function()
                for i = 1, self.ui_task_list.Count do
                    self:setUILv(self.ui_task_list:get(i-1))
                end
                self.ui_task_list:clear();
                self:showCellUIPanel(self.cur_cell)
                if self.shengji ~= nil then
                    U3DUtil:GameObjectDestroy( self.shengji )
                    self.shengji = nil;
                end
                static_rootControl:updateMsg("unlockTouch",nil,"JuBaoShan")
            end) 
        end
    end
end

--更新任务
function M:UnityUpdate(dt)
    if static_rootControl:can3DTouchByViewName("JuBaoShan") then
        --self:check_talk(dt);
        if SceneManager:getCurSceneView().cameraController.CanDrag == false then
            SceneManager:getCurSceneView().cameraController.CanDrag = true;
            SceneManager:getCurSceneView().cameraController.mouseDown = false;
        end
    else
        if SceneManager:getCurSceneView().cameraController.CanDrag == true then
            SceneManager:getCurSceneView().cameraController.CanDrag = false;
        end
    end
    self:updateTask(dt);
end



--检测聊天
function M:check_talk( dt )
    if self.curTalkDelayTime > 0 then
        self.curTalkDelayTime = self.curTalkDelayTime - dt;
        if self.curTalkDelayTime <= 0 then
            self:playerTalk();
        end
    else
        if self.curTalkTime > 0 then
            self.curTalkTime = self.curTalkTime - dt
            if self.curTalkTime <= 0 then
                self:playerTalk();
                self.curTalkTime = 12;
            end
        end
    end
end


--弹出聊天框
function M:talk( text, time )
    if text ~= nil then
        self.player_view:talk( text,time )
    end
end


function M:playerStartMove()
    self.player.animator:changeState("run")
end

function M:playerEndMove()
    self.player.animator:changeState("idle")
    
    if self.cur_cell.cell_config ~= nil and self.cur_cell.cell_config.prompt ~= nil and self.cur_cell.cell_config.prompt ~= "" then
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey(self.cur_cell.cell_config.prompt), delay_close = 2 })
    end
end


function M:playerTalk()
    local build_cells = self.cellTypeToCellPools[4];
    local minTime = 999
    local minCell = nil;
    for i, v in pairs(build_cells) do
        if v.trigger_time ~= nil then
            if v.trigger_time < minTime then
                minTime = v.trigger_time;
                minCell = v;
            end
        end
    end
    --Language:getTextByKey(self.cur_cell.cell_config.prompt)
    if minCell ~= nil and minCell.cell_config ~= nil then
        --
        --展示奖励
        local reward = minCell.cell_config.param.reward[minCell.lv]
        --奖励
        local reward_data = { }
        if #reward > 0 then
            table.insert(reward_data, reward[2]);
            table.insert(reward_data, reward[3]);
            table.insert(reward_data, reward[4]);
        end
        local data = RewardUtil:getProcessRewardData(reward_data)
        local content = Language:getTextByKey("jubaoShan_str_007",minCell.trigger_time,data.name)
        self:talk( content, 8 )
    else
        self:talk("到达格子")
    end
end

--玩家移动
function M:playerMove( dt, cell_info, move_finish )
    if self.startPlayerMove == false then
        --开始位置
        self.startPostion.x = self.player.position.x
        self.startPostion.y = self.player.position.y
        self.startPostion.z = self.player.position.z
        --目标位置
        local pos = cell_info.localPosition;
        local grid_fix_pos = GlobalTools:ToFixVector3(pos);
        self.targetPostion.x = grid_fix_pos.x;
        self.targetPostion.y = grid_fix_pos.y;
        self.targetPostion.z = grid_fix_pos.z;

        self.curMoveTime = 0;
        self.startPlayerMove = true
    end
    
    if self.startPlayerMove == true then
        local dt_fix = GlobalTools:CommonToFix(dt);
        self.curMoveTime = self.curMoveTime + dt_fix;
        if self.curMoveTime >= self.moveTime then
            self.curMoveTime = self.moveTime;
            if move_finish ~= nil then
                move_finish();
            end
            self.startPlayerMove = false;
        end
        
        local t = GlobalTools:Div(self.curMoveTime, self.moveTime)
        GlobalTools:Lerp(self.curPostion, self.startPostion, self.targetPostion, t)
        local dir = GlobalTools:Dir(self.targetPostion,self.player.position);
        self.player:setForward(dir)
        self.player:setPos( self.curPostion )
    end
end

--通过index设定玩家位置
function M:setPlayerPositionByIndex( index )
    local cell = self.indexToCellPools[index];
    if cell ~= nil then
        self:setPlayerPosition( cell );
    end
end 


--设定当前的格子
function M:setCurCell( cell )
    self.cur_cell = cell;
end

--设定 格子动画 
function M:curCellAnim()
    if self.last_cell ~= nil then
        if not IsNull(self.last_cell.building) then
            local localPos = self.last_cell.building.transform.localPosition;
            localPos.y = localPos.y - 2
            self.last_cell.building.transform.localPosition = localPos
        end
        self.last_cell = nil;
    end

    --如果CD 不是nil
    if self.cur_cell.cell_type == 3 and self.cur_cell.cell_config ~= nil and self.cur_cell.cell_config.param.CD ~= nil then
        if not IsNull(self.cur_cell.building) and self.cur_cell.connection == "" then
            local localPos = self.cur_cell.building.transform.localPosition;
            localPos.y = localPos.y + 2
            self.cur_cell.building.transform.localPosition = localPos;
            self.last_cell = self.cur_cell;
        end
    end
end


--设定玩家位置
function M:setPlayerPosition( cell )
    self:setCurCell(cell);
    local pos = self.cur_cell.localPosition;
    pos.y = 0;
    local fix_pos = FixVector3.New(0,0,0);
    fix_pos.x = GlobalTools:CommonToFix( pos.x );
    fix_pos.y = GlobalTools:CommonToFix( pos.y );
    fix_pos.z = GlobalTools:CommonToFix( pos.z );
    --玩家设定位置
    self.player:setPos( fix_pos )
end


--创建玩家
function M:createPlayer()
    --self.cell_id = 60010101
    if self.player == nil then
        local avatar,custom_prefab = GameUtil:getUserOwnAvatar()
        local playerData = { id = tonumber(avatar), evo = 0, custom_prefab = custom_prefab }
        --起始格子
        self.player = self.plyMgr:createPlayer(playerData,1,0,nil,nil)
        self.player.loadPlayerViewFinish = function(ply)
            self.player_view = ply;
            self:setPlayerPosition( self.cur_cell );
            self.plyMgr:playerSpawnCamp(1);
            if self.player.animator ~= nil then
                self.player.animator:changeState("idle")
            end
            
            SceneManager:getCurSceneView().cameraController.transform.position = self.player_view:get_position()
            SceneManager:getCurSceneView().cameraController:ResetStart();
            SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
            
            --放大3倍
            self.player:setScale(GlobalTools.base1);
            --缩放值
            self.player_view.player_talk:SetScale(0.8);
            --场景状态改成3
            self:set_sceneState(3)
            GlobalTools:CreateSummon(self.player)
            
            if self.mainPlayerloadFinish ~= nil then
                self.mainPlayerloadFinish()
            end
            static_rootControl:updateMsg("close_sync_load_big_loading");
        end
    else
        self:setPlayerPosition( self.cur_cell );
        self.plyMgr:playerSpawnCamp(1);
        
        SceneManager:getCurSceneView().cameraController.transform.position = self.player_view:get_position()
        SceneManager:getCurSceneView().cameraController:ResetStart();
        SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
        
        self.player:setScale(GlobalTools.base1);
        self:set_sceneState(3)
        if self.player.animator ~= nil then
            self.player.animator:changeState("idle")
        end
        static_rootControl:updateMsg("close_sync_load_big_loading");
    end
end

--销毁场景
function M:destroy( nextScene )
    M.super.destroy(self,nextScene);
    self.player = nil;
    self.player_view = nil;
    GameMain.removeUpdate("Maze_Update");
end


return M;