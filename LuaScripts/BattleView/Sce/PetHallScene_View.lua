
--聚宝山场景
---@class PetHallScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("PetHallScene_View",Battle.Scene_View)

--初始化场景
function M:init(model)
    M.super.init(self,model)
    self.mouseDownTime = 0
end

--进入场景
function M:enter( data )
    M.super.enter(self, data )
    GameMain.addUpdate("MouseEvent",handler(self,self.MouseEvent) )
    Logger.log(data, " pet_hall_View 服务器数据 ")
end

function M:getCurSceneName()
    --self:createSceneConfig(141)
    --return self.scene_info.resource;
    return "pet_hall"
end

function M:getCurSceneObjName()
    return "hangUpscene_data_w";
end

function M:MouseEvent()
    self:mouseDown()
    self:mouseMove()
    self:mouseUp()
end

function M:mouseDown()
    if U3DUtil:Input_GetMouseButtonDown(0) then
        if static_rootControl:can3DTouchByViewName("PetBreeding.PetBreedingMain") then
            self.isMouseDown = true
            self.view_name = "PetBreedingMain"
            self.selectPlayer = nil
            self.mouse_down_pos = CS.wt.framework.PhysicsTool.GetHitLandPos()
            self.mouse_down_pos.y = 0
        elseif static_rootControl:can3DTouchByViewName("PetBreeding.PetShowSet") then
            self.isMouseDown = true
            self.view_name = "PetShowSet"
            self.selectPlayer = nil
            self.mouse_down_pos = CS.wt.framework.PhysicsTool.GetHitLandPos()
            self.mouse_down_pos.y = 0
        end
        if self.isMouseDown then
            local objList = CS.wt.framework.PhysicsTool.GetHitPlayer()
            if objList.Count > 0 then
                for i=1,objList.Count do
                    local obj = objList[i-1];
                    local helper = obj:GetComponent("LuaTransformHelper")
                    Logger.log(helper.index,"LuaTransformHelper index =======")
                    self.selectPlayer = self.plyMgr:getHeroByIndex(helper.index)
                    if self.selectPlayer ~= nil then
                        self.mouseDownTime = U3DUtil:RealtimeSinceStartup()
                        break
                    end
                end
            end
        end
    end
end

function M:mouseMove()
    if self.isMouseDown and self.isMouseMove ~= true then
        local pos = CS.wt.framework.PhysicsTool.GetHitLandPos()
        pos.y = 0
        local dis = Vector3.Distance(self.mouse_down_pos, pos)
        if dis > 0.5 then
            Logger.log("---------------------- mouse is move ")
            self.isMouseMove = true
        end
    end
end

function M:mouseUp()
    if U3DUtil:Input_GetMouseButtonUp(0) then
        if self.isMouseDown and self.isMouseMove ~= true then
            local upTime = U3DUtil:RealtimeSinceStartup()
            if upTime - self.mouseDownTime < 0.2 then
                if self.view_name == "PetBreedingMain" then
                    if self.selectPlayer then
                        static_rootControl:updateMsg("open_interact", nil, "PetBreeding.PetBreedingMain")
                        if self.model.showInteractPet then
                            self.model:showInteractPet(self.selectPlayer)
                        end
                    end
                elseif self.view_name == "PetShowSet" then
                    if self.model.InteractPet then
                        self.model:InteractPet(self.selectPlayer)
                    end
                end
            end
        end
        self.isMouseDown = false
        self.isMouseMove = false
        self.view_name = ""
        self.mouseDownTime = 0
        self.selectPlayer = nil
    end
end

function M:destroy( nextScene )
    M.super.destroy(self, nextScene)
    GameMain.removeUpdate("MouseEvent")
end

return M;