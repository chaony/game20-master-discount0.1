--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:33:07
]]

--进阶场景
---@class AdvancedScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("AdvancedScene_View",Battle.Scene_View)

M.plyMoveSpeed = 0;
M.lv_tab = {}
--初始化场景
function M:init(model)
    M.super.init(self,model)
end

function M:getCurSceneName()
    return "chuangongdian";
end

function M:getCurSceneObjName()
    return "advance_data";
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
    self:loadSceneItem()
end


function M:loadFinish()
    --英雄
    -- self.pantheon = U3DUtil:GameObject_Find("tree")
    -- local lv_pos = U3DUtil:GameObject_Find("lv_pos")
    M.super.loadFinish(self)
    self.gameover = false
    self:set_sceneState(3)
    self.cameraController.camera_move = false
    self.Camera = U3DUtil:GameObject_Find("Camera")
    self.camera_3d = self.Camera.transform:Find("3DCamera")
    self.m_hehua_a = {}
    self.m_hehua_b = {}
    for i=1,3 do
        local hehua = U3DUtil:GameObject_Find("lianhua_a" .. i)
        if hehua then
            self.m_hehua_a[i] = hehua
        end
        hehua = U3DUtil:GameObject_Find("lianhua_b" .. i)
        if hehua then
            self.m_hehua_b[i] = hehua
        end
    end
    self:hehuaHide()
end

--加载场景Item
function M:loadSceneItem()
    if self.obj ~= nil then

    end
end


--进入场景
function M:enter(data)
    M.super.enter(self, data)
end

--更新场景
function M:updateUnScaleDelay(unsdt)
    M.super.updateUnScaleDelay(self,unsdt)
end


--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    M.super.update_dt(self,dt)
    -- if self.Camera then
    --     self.Camera.transform:Rotate(0, dt*1, 0)

    --     for k,v in pairs(self.lv_tab) do
    --         v.rotation = U3DUtil:LookRotation(v.position - self.camera_3d.transform.position)
    --     end
    -- end
end

function M:destroy( nextScene)
    M.super.destroy(self, nextScene );
    self.Camera = nil;
    self.camera_3d = nil;
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

function M:addHero(oid, pos, number_type)
    self.m_type = number_type or 1
    local playerData,_ = UserDataManager.hero_data:getHeroDataById(oid)
    local PosIndex = tonumber(pos) - 1
    local player = self.plyMgr:createPlayer(playerData,number_type,PosIndex,function (player)
        if player.obj ~= nil then
            local pos = self:findSpawnPosition(number_type, PosIndex)
            player.obj.transform.localScale = Vector3.New(6,6,6)
            player:setPos(pos)
            player.data:set_moveSpeed(self.plyMoveSpeed);
            player:rotaTo(FixVector3(0,0,0),0)
            local listener = CS.GameObjectMouseEventListener.Get(player.obj)
            listener.onClick = function (data)
                static_rootControl:updateMsg("remove_hero",playerData,"Advanced")
            end
        end
    end)
end

function M:hehuaShow()
    -- if self.m_type == 1 then
    --     for i,v in ipairs(self.m_hehua_a) do
    --         v:SetActive(true)
    --     end
    -- else
    --     for i,v in ipairs(self.m_hehua_b) do
    --         v:SetActive(true)
    --     end
    -- end
end

function M:hehuaHide()
    for i,v in ipairs(self.m_hehua_a) do
        v:SetActive(false)
    end
    for i,v in ipairs(self.m_hehua_b) do
        v:SetActive(false)
    end
end

function M:removeHero(pos)
    local player = nil
    if self.m_type == 1 then
        player = self.plyMgr:getHeroByIndex(pos-1)
    else
        player = self.plyMgr:getEnemyByIndex(pos-1)
    end
    if player then
        self.plyMgr:destoryPlayer(player)
    end
    local players = self.plyMgr:getPlayers(self.m_type)
    if players.Count <= 0 then
        self:hehuaHide()
    end
end

function M:removeAllHero()
    self.plyMgr:destroy(true)
    self:hehuaHide()
end

return M