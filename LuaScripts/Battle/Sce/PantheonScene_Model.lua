--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:33:07
]]
---@class PantheonScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("PantheonScene_Model",Battle.Scene_Model)


M.lv_tab = {}
--初始化场景
function M:init()
    M.super.init(self)
    self.plyMoveSpeed = GlobalTools.base0;
end

function M:getCurSceneName()
    return "pantheon";
end

function M:getCurSceneObjName()
    return "pantheon_data";
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
    self:loadSceneItem()
end


function M:loadFinish( data )
    --英雄
    self.pantheon = U3DUtil:GameObject_Find("tree")
    local lv_pos = U3DUtil:GameObject_Find("lv_pos")
    for k,v in pairs(data or {}) do
        local playerData,_ = UserDataManager.hero_data:getHeroDataById(v[1])
        local PosIndex = tonumber(k) - 1
        local player = self.plyMgr:createPlayer(playerData,1,PosIndex,function(player)
            player.obj.transform.localScale = Vector3.New(1.8,1.8,1.8)
            player.data:set_moveSpeed(self.plyMoveSpeed);
            local fix_target_pos = GlobalTools:ToFixVector3(self.pantheon.transform.position);
            local dir = GlobalTools:Dir(fix_target_pos, player.position);
            player:setForward(-dir)

            -- local lv_trans = lv_pos.transform:GetChild(PosIndex)
            -- lv_trans.gameObject:SetActive(true)
            -- UIUtil.setText(lv_trans, Language:getTextByKey("union_str_0004") .. playerData.lv, "Text")
            -- self.lv_tab[k] = lv_trans
        end)
    end
    
    self.gameover = false
    self:set_sceneState(3)
    self.cameraController.camera_move = false
    self.Camera = U3DUtil:GameObject_Find("Camera")
    self.camera_3d = self.Camera.transform:Find("3DCamera")
    
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
    if self.Camera then
        -- local angle = self.pantheon.transform.rotation.eulerAngles
        -- angle.y = angle.y + dt*30
        self.Camera.transform:Rotate(0, dt*3, 0)

        for k,v in pairs(self.lv_tab) do
            v.rotation = U3DUtil:LookRotation(v.position - self.camera_3d.transform.position)
        end
    end
end


function M:destroy( nextScene )
    M.super.destroy(self, nextScene);
    self.Camera = nil;
    self.camera_3d = nil;
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

return M