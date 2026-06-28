--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-15 09:55:38
]]

---@class QiMenDunJiaSceneData @
local M = class("QiMenDunJiaSceneData")

function M:init()                                          
    self.data = {}
    self.gridList = Battle.List.new();
    self.config = SceneManager.curScene.config;
    self.localConfig = SceneManager.curScene.localConfig;
    self.map_id = SceneManager.curScene.map_id;
    --配置文件
    -- self.config = require("Battle.Data.FuBen.".."1001")
    --- 地图编辑器生成的数据是高在前
    self.max_w = #self.localConfig[0] +1;
    self.max_h = #self.localConfig + 1;
    --临时移动目标
    self.temp_target = nil;
    local serverGridsData =  SceneManager.curScene.serverMapData.cells
    local walkGridIds = SceneManager.curScene.gridMgr.walkGridIds
    --初始化格子
    for h=1,self.max_h do
        for w=1,self.max_w do
            local w_index = w-1;
            local h_index = h-1;
            local cell_id = self:infoToID(w_index,h_index);
            local grid_data = self.config[cell_id]
            if grid_data ~= nil then
                local girdUnit = require("Battle.Sce.QiMenDunJia.QiMenDunJiaGridUnit").new();
                local gridConfigData = self.localConfig[h_index][w_index]
                girdUnit:init(cell_id, gridConfigData, w_index,h_index);
                local serverGridData = serverGridsData[tostring(cell_id)] or nil
                girdUnit:refreshGridData(serverGridData, (walkGridIds[cell_id] ~= nil))
                if self.data[w_index] == nil then
                    self.data[w_index] = {}
                end
                self.data[w_index][h_index] = girdUnit;
                self.gridList:add( girdUnit );
            end
        end
    end
    
    -- 初始化的时候gridMgr拿不到aStr，所以初始化在这里单独处理
    local playerGridId = SceneManager.curScene.playerGridId
    local tempGridUnit = SceneManager.curScene.gridMgr:getGridUnitById(playerGridId)
    -- 初始化将所在范围6个格子属性全部修改掉
    local aroundGridUnits = {}
    local tempGridUnits,_ = SceneManager.curScene:getAroundGridUnit(tempGridUnit)
    for _, itemUnit in pairs(tempGridUnits) do
        aroundGridUnits[itemUnit.m_gridId] = self.data[itemUnit.w_pos][itemUnit.h_pos]
    end
    for _, itemUnit in pairs(aroundGridUnits) do
        if self.data[itemUnit.w_pos] and self.data[itemUnit.w_pos][itemUnit.h_pos] then
            local serverGridData = serverGridsData[tostring(itemUnit.m_gridId)] or nil
            self.data[itemUnit.w_pos][itemUnit.h_pos]:refreshGridData(serverGridData, true)
        end
    end
end

function M:refreshGridData(w_index, h_index,serverData, isWalk)
    if self.data[w_index] == nil then
        return
    end
    if self.data[w_index][h_index] == nil then
        return
    end
    local girdUnit = self.data[w_index][h_index]
    girdUnit:refreshGridData(serverData, isWalk)
end

--服务器数据传入
function M:refresh( data )
    for k,v in pairs(data) do
        local grid_info = self:idToInfo(k);
        local gird = self.data[grid_info.x][grid_info.y];
        if v.type > 0 and v.type ~= 9 then
            gird:setValue(1);
        else
            gird:setValue(0);
        end
    end
end


function M:idToInfo( id )
    local id = tonumber(id);
    local grid_info = {}
    local mapid = math.floor(id/100000000);
    local grid_x = math.floor(id/10000) - mapid * 10000;
    local grid_y = id - mapid * 100000000 - grid_x * 10000;
    grid_info.mapid = mapid;
    grid_info.x = grid_x;
    grid_info.y = grid_y;
    return grid_info
end

--信息装换成id
function M:infoToID( w, h )
    return tonumber(self.map_id) * 100000000 + w * 10000 + h
end


function M:destroy()
    for i=1,self.gridList.Count do
        local grid = self.gridList:get(i-1);
        grid:destroy();
    end
end


function M:getStartPosition()

end


function M:resetValue()
    --for w=1,self.max_w do
    --    for h=1,self.max_h do
    --        local w_index = w-1;
    --        local h_index = h-1;
    --        local grid = self.data[w_index][h_index];
    --        grid:setValue(0);
    --    end
    --end
end


function M:reset()
    for w=1,self.max_w do
        for h=1,self.max_h do
            local w_index = w-1;
            local h_index = h-1;
            local grid = self.data[w_index][h_index];
            grid:reset();
        end
    end
end

return M;