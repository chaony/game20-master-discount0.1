--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-05 18:39:18
]]

---@class FightSceneData @
local M = class("FightSceneData")

--给AStar提供数据的数据体 
function M:init()
    --格子数据
    self.data = {}
    self.gridList = Battle.List.new();
    if  SceneManager.curScene.sceneId ~= SceneManager.SceneID.ShiGuangScene then
        --初始化数据
        self.max_w = Battle.SceneGridConfig.map_width;
        self.max_h = Battle.SceneGridConfig.map_height;
        if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
            self.max_w = Battle.SceneGridConfig.guaji_map_width;
            self.max_h = Battle.SceneGridConfig.guaji_map_height;
        end
        --初始化格子
        self:setData(self.max_w, self.max_h);
    else
        self:resetId()
    end
end

function M:setData( max_w, max_h )
    --初始化格子
    for h=1,max_h do
        for w=1,max_w do
            local w_index = w-1;
            local h_index = h-1;
            local grid = require("Battle.Data.SceneGrid").new();
            grid:init(w_index,h_index);
            grid:setValue(0);
            if self.data[w_index] == nil then
                self.data[w_index] = {}
            end
            self.data[w_index][h_index] = grid;
            self.gridList:add( grid );
        end
    end
end



function M:resetId()
    self.max_w = 2;
        self.max_h =3;
end

--重置
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


--获取中心点center 周围的点，取到空的，距离最近的
function M:getAroundGrid_Free_MinDis( center, player )
    --上
    local up = nil
    --下
    local down = nil
    
    --左
    local left = nil
    --左上
    local left_up = nil
    --左下
    local left_down = nil
    
    --格子右
    local right = nil
    --右上
    local right_up = nil
    --右下
    local right_down = nil
    
    --找到的列表
    local around = Battle.List.new();
    --周围可以走的
    local aroundNoVisi = Battle.List.new();
    --路径
    local path = Battle.List.new();
    --是否是挂机
    local hangUp = SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene;

    --上
    if center.h_pos > 0 then
        up = self.data[center.w_pos][center.h_pos-1];
    else 
        up =  require("Battle.Data.SceneGrid").new();
        up:setVisi(false);
    end
    
    --下
    if center.h_pos < self.max_h - 1 then
        down = self.data[center.w_pos][center.h_pos + 1];
    else 
        down = require("Battle.Data.SceneGrid").new();
        down:setVisi(false);
    end
    
    --左
    if center.w_pos > 0 then
        left = self.data[center.w_pos - 1][center.h_pos];
    else 
        left = require("Battle.Data.SceneGrid").new();
        left:setVisi(false);
    end
    
    --右
    if center.w_pos < self.max_w - 1 then
        right = self.data[center.w_pos + 1][center.h_pos];
    else
        right = require("Battle.Data.SceneGrid").new();
        right:setVisi(false);
    end

    --左上
    if center.w_pos > 0 and center.h_pos > 0 then
        left_up = self.data[center.w_pos - 1][center.h_pos - 1];
    else
        left_up = require("Battle.Data.SceneGrid").new();
        left_up:setVisi(false);
    end

    --左下
    if center.w_pos > 0 and center.h_pos < self.max_h - 1 then
        left_down = self.data[center.w_pos - 1][center.h_pos + 1];
    else
        left_down = require("Battle.Data.SceneGrid").new();
        left_down:setVisi(false);
    end
    
    
    --右上
    if center.w_pos < self.max_w - 1 and center.h_pos > 0 then
        right_up = self.data[center.w_pos + 1][center.h_pos - 1];
    else 
        right_up = require("Battle.Data.SceneGrid").new();
        right_up:setVisi(false);
    end
    
    --右下
    if center.w_pos < self.max_w - 1 and center.h_pos < self.max_h - 1 then
        right_down = self.data[center.w_pos + 1][center.h_pos + 1];
    else 
        right_down = require("Battle.Data.SceneGrid").new();
        right_down:setVisi(false);
    end

    --上面的和最开始的相等  或者  和目标相等
    --上
    if up.IsVisi then
        around:add(up);
    else
        aroundNoVisi:add(up);
    end
    --下
    if down.IsVisi then
        around:add(down);
    else
        aroundNoVisi:add(down);
    end
    --左
    if left.IsVisi then
        around:add(left);
    else
        aroundNoVisi:add(left);
    end
    --右
    if right.IsVisi then
        around:add(right);
    else
        aroundNoVisi:add(right);
    end
    --左上
    if left_up.IsVisi then
        around:add(left_up);
    else
        aroundNoVisi:add(left_up);
    end
    --左下
    if left_down.IsVisi then
        around:add(left_down);
    else
        aroundNoVisi:add(left_down);
    end
    --右上
    if right_up.IsVisi then
        around:add(right_up);
    else
        aroundNoVisi:add(right_up);
    end
    --右下
    if right_down.IsVisi then
        around:add(right_down);
    else
        aroundNoVisi:add(right_down);
    end

    if player.grid ~= nil then
        for i=1,aroundNoVisi.Count do
            local cur_grid = aroundNoVisi:get(i-1);
            --如果玩家的格子已经在附近了，直接反会完成路径
            if cur_grid:equip(player.grid) then
                return path;
            end
        end
    end
    
    --绝对位置
    local minDis = GlobalTools:ToFix2(10000)
    local minGrid = nil;
    for i=1,around.Count do
        local grid = around:get(i-1);
        local fix_target_pos = GlobalTools:ToFixVector3( grid.worldPosition );
        local distance = GlobalTools:Distance(fix_target_pos, player.position );
        if distance < minDis then
            minDis = distance;
            minGrid = grid;
        end
    end

    if minGrid ~= nil then
        path:add(minGrid)
    end
    return path;
end


function M:destroy()
    for i=1,self.gridList.Count do
        local grid = self.gridList:get(i-1);
        grid:destroy();
    end
end


return M;