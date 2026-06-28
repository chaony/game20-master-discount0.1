--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-15 09:55:38
]]

---@class MiGongSceneData @
local M = class("MiGongSceneData")

function M:init()
    self.data = {}
    self.gridList = Battle.List.new();
    self.config = SceneManager.curScene.config;
    self.localConfig = SceneManager.curScene.localConfig;
    self.map_id = SceneManager.curScene.map_id;
    --配置文件
   -- self.config = require("Battle.Data.FuBen.".."1001")
    --宽度
    self.max_w = #self.localConfig[0] +1;
    self.max_h = #self.localConfig + 1;

    --初始化格子
    for h=1,self.max_h do
        for w=1,self.max_w do
            local w_index = w-1;
            local h_index = h-1;
            local cell_id = self:infoToID(w_index,h_index);
            local grid_data = self.config[cell_id]
            if grid_data ~= nil then
                local grid = require("Battle.Data.SceneGridSix").new();
                grid:init(w_index,h_index);
                if grid_data ~= nil then
                    --0 表示空地
                    if grid_data.group == 0 then
                        grid:setValue(0);
                    end
                    --99 表示不显示
                    if grid_data.group == 99 then
                        grid:setValue(1);
                    end
                end
                if self.data[w_index] == nil then
                    self.data[w_index] = {}
                end
                self.data[w_index][h_index] = grid;
                self.gridList:add( grid );
            end
        end
    end
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
    local mapid = math.floor(id/10000);
    local grid_x = math.floor(id/100) - mapid * 100;
    local grid_y = id - mapid * 10000 - grid_x * 100;
    grid_info.mapid = mapid;
    grid_info.x = grid_x;
    grid_info.y = grid_y;
    return grid_info
end

--信息装换成id
function M:infoToID( w, h )
    return tonumber(self.map_id) * 10000 + w * 100 + h
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