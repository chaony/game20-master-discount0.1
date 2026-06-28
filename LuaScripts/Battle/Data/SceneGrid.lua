--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-05 18:41:04
]]

--场景格子
---@class SceneGrid @
local M = class("SceneGrid")

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
    local left_pos;
    local top_pos;
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        left_pos = Battle.SceneGridConfig.guaji_left_pos_w
        top_pos = Battle.SceneGridConfig.guaji_top_pos_w
        self.grid_width = Battle.SceneGridConfig.guaji_grid_width;
        self.grid_height = Battle.SceneGridConfig.guaji_grid_height;
    else
        left_pos = Battle.SceneGridConfig.left_pos_w
        top_pos = Battle.SceneGridConfig.top_pos_w
        self.grid_width = Battle.SceneGridConfig.grid_width;
        self.grid_height = Battle.SceneGridConfig.grid_height;
    end
    self.lastVisi = true;
    self.IsVisi = true;
    self.value = 0;
    self.gap = 0
    self.vec2 = {x = 0,y =0 }
    self.vec2.x = w * ( self.grid_width + self.gap );
    self.vec2.y =  h * -(self.grid_width + self.gap);
    --格子索引
    self.index_pos = { x =self.w_pos,y = self.h_pos }
    --本地位置
    --self.position = Vector3( self.vec2.x, 0, self.vec2.y )
    --世界坐标位置
    --self.worldPosition = Vector3( self.position.x + left_pos, 0 , self.position.z + top_pos )
    --SceneManager.curScene.sceneId == SceneManager.SceneID.FightScene
    --self.obj = ResourceUtil:LoadCommon("grid",SceneManager.curScene.gridRoot.gameObject);
    --self.obj.transform.localScale = Vector3(self.grid_width,0.5,self.grid_width);
    --self.obj.transform.localPosition = self.position
    --self.sizeSet = self.obj:GetComponent("ShowPoint");
    --self.sizeSet.size = self.grid_width;
    
    self:reset();
end


--把自己设定成墙
function M:setValue( value )
    self.value = value;
    if self.value > 0 then
        self:setVisi(false);
        self:change(1)
        --Logger.logError(self.obj.name..">> ~~~~~~~~~~~~~~ 当前的点不能走 ["..self.w_pos..","..self.h_pos.."]" );
    else
        self:setVisi(true);
        self:change(0)
        --Logger.logError(self.obj.name..">> ~~~~~~~~~~~~~~ 当前的点可以走 ["..self.w_pos..","..self.h_pos.."]" );
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
    if math.abs(grid.w_pos - self.w_pos) <= 1 and math.abs(grid.h_pos - self.h_pos) then
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
        if scale == 2 then
            self.sizeSet.gizmoColor = Color(0,1,0,1);
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