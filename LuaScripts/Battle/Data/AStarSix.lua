--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-15 17:47:43
]]

---@class AStarSix @
local M = class("AStarSix")

function M:init(dataName, type)
    if dataName == nil then
        --dataName = "FightSceneDataSix";
        dataName = "FightSceneData";
    end
    if type == nil then
        type = 0;
    end
    --0 表示 四边形
    --1 表示 六边形
    self.type = type;
    self.dataName = dataName;
    self.openList = Battle.List.new();
    self.closeList = Battle.List.new();
    --场景数据
    self.sceneData = require("Battle.Data."..dataName).new();
    self.sceneData:init();

    self.max_w = self.sceneData.max_w 
    self.max_h = self.sceneData.max_h 
    
end


function M:destroy()
    if self.sceneData ~= nil then
        self.sceneData:destroy();
        self.sceneData = nil;
    end
end

function M:findPath( start, target )
    self.sceneData:reset();
    local now = start;
    self.openList:add(now);
    local finded = false;
    while finded == false do
        --将当前节点从openList中移除 
        self.openList:remove(now); 
        --将当前节点添加到关闭列表中
        self.closeList:add(now);  
        --获取当前六边形的相邻六边形  
        local neighbors = self:getGroundGrid(now);
        for i=1,neighbors.Count do
            local neighbor = neighbors:get(i-1)
            if neighbor ~= nil then
                if neighbor:equip( target ) then
                    --找到目标节点  
                    finded = true;
                    neighbor.parent = now;
                end
                if self.closeList:contains(neighbor) then
                    --在关闭列表里  
                    --Logger.log("已在关闭列表");
                elseif neighbor.IsVisi == false then
                    --Logger.log("无法通过");  
                else
                    --该节点已经在开启列表里  
                    if self.openList:contains(neighbor) then
                        --print("已在开启列表，判断是否更改父节点");  
                        --计算假设从当前节点进入，该节点的g估值  
                        local assueGValue = 1 + now.G;
                        if assueGValue < neighbor.G then
                            --假设的g估值小于于原来的g估值  
                            self.openList:remove(neighbor);
                            --重新排序该节点在openList的位置  
                            neighbor.G = assueGValue;
                            --从新设置g估值  
                            --从新排序openList。
                            self.openList:add(neighbor);  
                        end
                    else
                        --没有在开启列表里  
                        --print("不在开启列表，添加");  
                        --计算好他的h估值 
                        local h = math.min( math.abs(neighbor.index_pos.x - target.index_pos.x), math.abs(neighbor.index_pos.y - math.abs(target.index_pos.y)) )

                        neighbor.H = h;
                        --计算该节点的g估值（到当前节点的g估值加上当前节点的g估值） 
                        neighbor.G = 1 + now.G; 
                        --添加到开启列表里  
                        self.openList:add(neighbor);
                        --将当前节点设置为该节点的父节点
                        neighbor.parent = now;  
                    end
                end
            end 
        end

        if self.openList.Count <= 0 then
            break;
        else
            --得到f估值最低的节点设置为当前节点  
            now = self.openList:get(0);
        end
    end

    self.openList:clear();
    self.closeList:clear();

    local route = Battle.List.new();
    if finded then
        --找到后将路线存入路线集合  
        local hex = target;
        if target.IsVisi then
            route:add(hex);
        end
        hex = hex.parent
        while hex ~= start do
            --将节点添加到路径列表里  
            route:add(hex);
            --从目标节点开始搜寻父节点就是所要的路线 
            local fatherHex = hex.parent; 
            hex = fatherHex;
        end
        route:add(hex);
    end
    local path = Battle.List.new();
    for i=route.Count,1,-1 do
        local hex =route:get(i-1)
        path:add(hex)
    end
    return path;
end

--4边型
function M:getGroundGridFour( grid )
    local tempList = Battle.List.new()
    local up;           --上
    local down;         --下
    local left;         --左
    local right;        --右
    local left_up;      --左上
    local left_down;    --左下
    local right_up;     --右上
    local right_down;   --右下
    
    --上
    if grid.h_pos > 0 then
        up = self.sceneData.data[grid.w_pos][grid.h_pos - 1];
        tempList:add(up);
    end

    --下
    if grid.h_pos < self.max_h - 1 then
        down = self.sceneData.data[grid.w_pos][grid.h_pos + 1];
        tempList:add(down);
    end

    --左
    if grid.w_pos > 0 then
        left = self.sceneData.data[grid.w_pos -1][grid.h_pos];
        tempList:add(left);
    end

    --右
    if grid.w_pos < self.max_w - 1 then
        right = self.sceneData.data[grid.w_pos + 1][grid.h_pos];
        tempList:add(right);
    end

    --左下
    if grid.w_pos > 0 and grid.h_pos < self.max_h - 1 then
        left_down = self.sceneData.data[grid.w_pos - 1][grid.h_pos + 1];
        tempList:add(left_down);
    end

    --左上
    if grid.w_pos > 0 and grid.h_pos > 0 then
        left_up = self.sceneData.data[grid.w_pos - 1][grid.h_pos - 1];
        tempList:add(left_up);
    end

    --右下
    if grid.w_pos < self.max_w - 1 and grid.h_pos < self.max_h - 1 then
        left_down = self.sceneData.data[grid.w_pos + 1][grid.h_pos + 1];
        tempList:add(left_down);
    end

    --右上
    if grid.w_pos < self.max_w - 1 and grid.h_pos > 0 then
        left_up = self.sceneData.data[grid.w_pos + 1][grid.h_pos - 1];
        tempList:add(left_up);
    end
   
    return tempList;
end



function M:getGroundGridSixH( grid )
    local tempList = Battle.List.new()
    --Logger.log(" 中心点位置 grid "..grid.w_pos.." , "..grid.h_pos )
    --3-4
    local isDouble = grid.h_pos % 2;
    if isDouble == 0 then
        --3-3
        if grid.h_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --3-5
        if grid.h_pos < self.max_h - 1 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --2-4
        if grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos -1][grid.h_pos];
            tempList:add(check_grid);
        end
        --4-3
        if grid.h_pos > 0 and grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --4-4
        if grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos];
            tempList:add(check_grid);
        end
        --4-5
        if grid.h_pos < self.max_h - 1 and grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos + 1];
            tempList:add(check_grid);
        end
    else
        --center --3-3
        --3-2
        if grid.h_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --3-4
        if grid.h_pos < self.max_h-1 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --2-3
        if grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos];
            tempList:add(check_grid);
        end
        --2-2
        if grid.w_pos > 0 and grid.h_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --2-4
        if grid.h_pos < self.max_h-1 and grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --4-3
        if grid.w_pos < self.max_w-1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos];
            tempList:add(check_grid);
        end
    end

    return tempList;
end



function M:getGroundGridSix( grid )
    local tempList = Battle.List.new()
    --Logger.log(" 中心点位置 grid "..grid.w_pos.." , "..grid.h_pos )
    --3-4
    local isDouble = grid.w_pos % 2;
    if isDouble == 1 then
        --3-3
        if grid.h_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --3-5
        if grid.h_pos < self.max_h - 1 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --2-4
        if grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos -1][grid.h_pos];
            tempList:add(check_grid);
        end
        --2-5
        if grid.h_pos < self.max_h - 1 and grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --4-4
        if grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos];
            tempList:add(check_grid);
        end
        --4-5
        if grid.h_pos < self.max_h - 1 and grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos + 1];
            tempList:add(check_grid);
        end
    else
        --center --2-4
        --2-3
        if grid.h_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --2-5
        if grid.h_pos < self.max_h-1 then
            local check_grid = self.sceneData.data[grid.w_pos][grid.h_pos + 1];
            tempList:add(check_grid);
        end
        --3-3
        if grid.h_pos > 0 and grid.w_pos < self.max_w -1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --3-4
        if grid.w_pos < self.max_w - 1 then
            local check_grid = self.sceneData.data[grid.w_pos + 1][grid.h_pos];
            tempList:add(check_grid);
        end
        --1-3
        if grid.h_pos > 0 and grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos - 1];
            tempList:add(check_grid);
        end
        --1-4
        if grid.w_pos > 0 then
            local check_grid = self.sceneData.data[grid.w_pos - 1][grid.h_pos];
            tempList:add(check_grid);
        end
    end

    return tempList;
end


--6边型 获取周围的格子
function M:getGroundGrid( grid )
    if self.type == 1 then
        --6边型
        --return self:getGroundGridSixH( grid )
        return self:getGroundGridSix( grid )
    else
        --4边型
        return self:getGroundGridFour( grid )
    end 
end


function M:setGrid(position, curGrid)
    if self.type == 1 then
        --6边型
        return self:setGridSix( position,curGrid )
    else
        --4边型
        return self:setGridFour( position,curGrid )
    end
end


function M:setGridSix(position, curGrid)
    --最左点
    local left;
    --最上点
    local top;
    local grid_width = Battle.SceneGridConfig.grid_width;
    local grid_height = Battle.SceneGridConfig.grid_height;
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        grid_width = Battle.SceneGridConfig.guaji_grid_width;
        grid_height = Battle.SceneGridConfig.guaji_grid_height;
    end
    left = SceneManager.curScene.gridRootPos.x;
    top = SceneManager.curScene.gridRootPos.z;

    local m_pos_x = position.x - left;
    local m_pos_z = position.z - top;

    local w_v = grid_width;
    local h_v = grid_height;

    local m_pos_index_y = math.floor( math.abs( (m_pos_z - h_v/2)/ h_v ) );
    local scale_x = m_pos_index_y % 2;
    local m_pos_index_x = 0;
    if scale_x == 0 then
        m_pos_index_x = math.floor(math.abs( (m_pos_x + w_v/2)/ w_v ) );
    else
        m_pos_index_x = math.floor( math.abs( (m_pos_x)/ w_v ) );
    end
    --我站立的格子
    local max_w = self.sceneData.max_w;
    local max_h = self.sceneData.max_h;
    if m_pos_index_x < max_w and m_pos_index_x >= 0 and m_pos_index_y < max_h and m_pos_index_y >= 0 then
        local stand_grid = self.sceneData.data[m_pos_index_x][m_pos_index_y];
        if stand_grid ~= nil then
            --我脚下的格子
            --和我的格子不相等
            if stand_grid ~= curGrid then
                if stand_grid.IsVisi then
                    return stand_grid
                end
            end
        end
    end
    return nil
end


function M:setGridFour(position, curGrid)
    --最左点
    local left;
    --最上点
    local top;
    local grid_width = Battle.SceneGridConfig.grid_width;
    local grid_height = Battle.SceneGridConfig.grid_height;
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        grid_width = Battle.SceneGridConfig.guaji_grid_width;
        grid_height = Battle.SceneGridConfig.guaji_grid_height;
    end
    left = SceneManager.curScene.gridRootPos.x;
    top = SceneManager.curScene.gridRootPos.z;
    
    local m_pos_x = position.x - left;
    local m_pos_z = position.z - top;
    --格子的宽度，和高度
    local w_v = grid_width;
    local h_v = grid_height;

    local m_pos_index_y = (m_pos_z - h_v/2)/ h_v -- math.floor( math.abs( (m_pos_z - h_v/2)/ h_v ) );
    local m_pos_index_x = (m_pos_x + w_v/2)/ w_v -- math.floor( math.abs( (m_pos_x + w_v/2)/ w_v ) );
    --我站立的格子
    local max_w = self.sceneData.max_w;
    local max_h = self.sceneData.max_h;
    if m_pos_index_x < max_w and m_pos_index_x >= 0 and m_pos_index_y < max_h and m_pos_index_y >= 0 then
        local stand_grid = self.sceneData.data[m_pos_index_x][m_pos_index_y];
        if stand_grid ~= nil then
            --我脚下的格子
            --和我的格子不相等
            if stand_grid ~= curGrid then
                if stand_grid.IsVisi then
                    return stand_grid
                end
            end
        end
    end
    return nil    
end

return M