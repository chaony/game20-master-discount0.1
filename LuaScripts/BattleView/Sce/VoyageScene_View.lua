--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:27:50
]]

--盗帅迷踪场景视图
---@class VoyageScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("VoyageScene_View",Battle.Scene_View)

--初始化场景
function M:init(model)
    M.super.init(self, model)
    self.use_hov = U3DUtil:IsHov();
    self.use_foot_effect = false;
    self:addEventListener_Local(Battle.EventType.MV_SceneGuideModelCreateFinish,{self,self.SceneGuideModelCreateFinish})
end

--场景向导 创建完成
function M:SceneGuideModelCreateFinish(eventName, data) 
    local sceneGuideMode = data;
    self:initGuide( sceneGuideMode );
end

--初始化场景向导
function M:initGuide( model )
    self.guide = Battle.SceneGuide_View.new()
    self.guide:init( self.guideObj, self, model)
end

--加载场景
function M:initSceneObjectsFinish( data )
    M.super.initSceneObjectsFinish(self)
    if self.obj ~= nil then
        self.gridRoot = self.obj.transform:Find("gridRoot");
        self.guideObj = self.obj.transform:Find("Guide")
        self.heroPosObj = self.obj.transform:Find("HeroPos")
        self.m_daoShuaiMiGong_1V10 = self.obj.transform:Find("DaoShuaiMiGong_1V10")
        if not IsNull(self.m_daoShuaiMiGong_1V10) then
            self.timeLinePlay = self.m_daoShuaiMiGong_1V10:GetComponent("TimeLinePlay")
            --self.m_jinYi = self.m_daoShuaiMiGong_1V10:Find("W_JinY@daoshuai_1v1guadian/Root/W_JinY")
            --self.m_camera_3D = self.m_daoShuaiMiGong_1V10:Find("Camera_Root/Camera_3D")
            self.m_camera_root = self.m_daoShuaiMiGong_1V10:Find("Idle/Camera_Root")
            self.m_daoShuaiMiGong_1V10.gameObject:SetActive(true)
            
            --触发Unity的 Timeline 刷新机制
            --旋转角度必须大于 某个角度 目测必须 > 60
            --self.m_camera_root.transform.localRotation = Quaternion.Euler(0,-9,0)
            --TimeTools:delayTimeUnity(0.03, function()
            --    self.m_camera_root.transform.localRotation = Quaternion.Euler(0,-90,0)
            --end)
            self:play("DaoShuaiMiZong_Timeline_idle", true)
        end
    end
end

--视图更新
function M:view_update(dt, unsdt)
    M.super.view_update(self, dt, unsdt);
    if self.cameraControllerHasTarget ~= nil and self.cameraControllerHasTarget == false then
        --local mode = self.model.guide:get_mode()
        --if mode == 1 or mode == 3 then
        --    local mainPlayer = self.model:get_mainPlayer();
        --    if mainPlayer ~= nil then
        --        local player_view = self.plyMgr:GetPlayerViewByModel( mainPlayer );
        --        if player_view ~= nil and player_view.tran ~= nil then
        --            self.cameraController.Target = player_view.tran;
        --            self.cameraControllerHasTarget = true;
        --        end
        --    end
        --elseif mode == 2 then
        --    if not IsNull(self.heroPosObj) then
        --        self.cameraController.Target = self.heroPosObj.transform;
        --        self.cameraControllerHasTarget = true;
        --    end
        --end
        self:setCameraControllerTarget(true)
    end
end

-- 初始化完成
function M:initFinish()
    self.cameraControllerHasTarget = false
end

function M:play(name, loop)
    if not IsNull(self.timeLinePlay) then
        if not IsNull(self.m_daoShuaiMiGong_1V10) then
            local daoshuai_idle = self.m_daoShuaiMiGong_1V10:Find("Idle")
            local daoshuai_1V1 = self.m_daoShuaiMiGong_1V10:Find("1V1")
            local daoshuai_1V10 = self.m_daoShuaiMiGong_1V10:Find("1V10")
            daoshuai_idle.gameObject:SetActive(name == "DaoShuaiMiZong_Timeline_idle")
            daoshuai_1V1.gameObject:SetActive(name == "DaoShuaiMiZong_Timeline_1v1")
            daoshuai_1V10.gameObject:SetActive(name == "DaoShuaiMiZong_Timeline_1V10")
            if name == "DaoShuaiMiZong_Timeline_idle" then
                -- 之前跟随锦衣， 现在跟随空相机的位置节点
                self.m_jinYi = self.m_daoShuaiMiGong_1V10:Find("Idle/Camera_Root/Camera_3D")
            elseif name == "DaoShuaiMiZong_Timeline_1v1" then
                self.m_jinYi = self.m_daoShuaiMiGong_1V10:Find("1V1/Camera_Root/Camera_3D")
            elseif name == "DaoShuaiMiZong_Timeline_1V10" then
                self.m_jinYi = self.m_daoShuaiMiGong_1V10:Find("1V10/Camera_Root/Camera_3D")
            end
            self:setCameraControllerTarget(true)
        end
        self.timeLinePlay:Play(name, loop)
    end
end

function M:resetTimeLineCamera()
    --if not IsNull(self.m_camera_3D) then
    --    local lpos = self.m_camera_3D.localPosition
    --    lpos.x = 0
    --    self.m_camera_3D.localPosition = lpos
    --end
end

function M:setCameraControllerTarget(set_flag)
    if set_flag then
        if not IsNull(self.m_jinYi) then
            self.cameraController.Target = self.m_jinYi
            self.cameraControllerHasTarget = true
        end
    else
        self.cameraController.Target = nil
    end
end

function M:destroy( nextScene )
    if not IsNull(self.m_daoShuaiMiGong_1V10) then
        self.m_daoShuaiMiGong_1V10.gameObject:SetActive(false)
        self.m_daoShuaiMiGong_1V10 = nil
    end
    M.super.destroy(self, nextScene);
end

return M