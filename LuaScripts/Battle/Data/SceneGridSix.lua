--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-26 13:38:32
]]

--场景格子
---@class SceneGridSix @
local M = class("SceneGridSix")

M.w_pos = 0;
M.h_pos = 0;

--表示从某位置移动到网格上指定位置点的移动耗费 (距离)—包含前一位置耗费
M.G = 0;
--表示从指定的位置点移动到终点 B 的预计耗费
M.H = 0;
--总值
M.F = 0;

M.IsVisi = true;

function M:init(w, h)
    self.w_pos = w;
    self.h_pos = h;
    self.lastVisi = true;
    self.IsVisi = true;
    self.value = 0;
    --实际的坐标 
    self.vec2 = {x= 0, y= 0}
    self.h_scale = h % 2;  --0 和 1
    self.grid_width = Battle.SceneGridConfig.grid_width;
    self.grid_height = Battle.SceneGridConfig.grid_height;
    if SceneManager.curScene.sceneId == 1 then
        self.grid_width = Battle.SceneGridConfig.guaji_grid_width
        self.grid_height = Battle.SceneGridConfig.guaji_grid_height
    elseif SceneManager.curScene.sceneId == 11 then
        self.grid_width = Battle.SceneGridConfig.sg_grid_width
        self.grid_height = Battle.SceneGridConfig.sg_grid_height
    elseif SceneManager.curScene.sceneId == 5 or SceneManager.curScene.sceneId == 20 then
        self.grid_width = Battle.SceneGridConfig.yijie_left_pos
        self.grid_height = Battle.SceneGridConfig.yijie_top_pos
    end

    -- ["yijie_left_pos"] = -17.99,
    -- ["yijie_top_pos"] = 7.91,

    self.vec2.x = w * self.grid_width + self.h_scale * self.grid_width/2;
    self.vec2.y =  h * -(self.grid_height);
    --索引
    self.index_pos = {x = 0, y = 0 }
    self.index_pos.x = self.w_pos;
    self.index_pos.y = self.h_pos;
    --3D位置
    local left = 0;
    local top = 0;
    left = SceneManager.curScene.gridRootPos.x;
    top = SceneManager.curScene.gridRootPos.z;
    
    self.position = Vector3( self.vec2.x, 0, self.vec2.y )
    self.worldPosition = Vector3( self.position.x + left, 0 , self.position.z + top )
    
    --if SceneManager.curScene.gridRoot ~= nil then
    --    if GameVersionConfig.Debug == true then
    --        self.obj = ResourceUtil:LoadCommon("grid",SceneManager.curScene.gridRoot.gameObject);
    --        self.obj.transform.localScale = Vector3(1,1,1);
    --        self.obj.transform.localPosition = self.position
    --        self.sizeSet = self.obj:GetComponent("ShowPoint");
    --        self.sizeSet.size = self.grid_width;
    --    end
    --end
    
    self:reset();
end

--把自己设定成墙
function M:setValue( value )
    self.value = value;
    if self.value > 0 then
        self:setVisi(false);
        self:change(1)
    else
        self:setVisi(true);
        self:change(value)
    end
end

--是否可以移动
function M:setVisi( visi )
    self.IsVisi = visi;
end


--格子是否改变
function M:gridChange()
    if self.IsVisi ~= self.lastVisi then
        self.lastVisi = self.IsVisi;
        return true;
    end
    return false;
end

--是否在我周围 
function M:InAround( grid )
    if math.abs(grid.w_pos - self.w_pos) <= 1 and math.abs(grid.h_pos - self.h_pos) <= 1 then
        return true;
    end
    return false;
end


--就是一个显示
function M:change( scale )
    if self.sizeSet ~= nil then
        if scale > 0 then
            self.sizeSet.gizmoColor = Color(1,0,0,1);
        else
            self.sizeSet.gizmoColor = Color(1,0,0,0.1);
        end
        if scale == -1 then
            self.sizeSet.gizmoColor = Color(0,1,0,0.5);
        end
    end
end

--重置
function M:reset()
    self.parent = nil;
    self.G = 0;
    self.H = 0;
    self.F = 0;
end

--是否相等
function M:equip( other_grid )
    if self.w_pos == other_grid.w_pos and self.h_pos == other_grid.h_pos then
        return true;
    end
    return false;
end


--更新 父级对象
function M:updateParent( parent, g )
    self.parent = parent;
    self.G = g;
    self.F = self.G + self.H;
end


function M:destroy()
    if self.obj ~= nil then
        --U3DUtil:GameObjectDestroy(self.obj)
        self.obj = nil;
    end
end 

return M