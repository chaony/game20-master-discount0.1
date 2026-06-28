--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-15 09:55:38
]]

---@class ShiGuangSceneData @
local M = class("ShiGuangSceneData")

function M:init()
    self.data = {}
    self.gridList = Battle.List.new();
    --配置文件
    self.config = require("Battle.Data.FuBen.".."1001")
    --宽度
    self.max_w = #self.config[0] +1;
    self.max_h = #self.config + 1;

    --初始化格子
    for h=1,self.max_h do
        for w=1,self.max_w do
            local w_index = w-1;
            local h_index = h-1;
            local grid_data = self.config[h_index][w_index];
            local grid = require("Battle.Data.SceneGridSix").new();
            grid:init(w_index,h_index);
            if grid_data ~= nil then
                if grid_data.sx_id < 0 or grid_data.sx_id > 0 then
                    grid:setValue(1);
                else
                    grid:setValue(0);
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


function M:destroy()
    for i=1,self.gridList.Count do
        local grid = self.gridList:get(i-1);
        grid:destroy();
    end
end


function M:getStartPosition()
    
end


function M:resetValue()
    for w=1,self.max_w do
        for h=1,self.max_h do
            local w_index = w-1;
            local h_index = h-1;
            local grid = self.data[w_index][h_index];
            grid:setValue(0);
        end
    end
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