--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-08 19:02:23
]]

--迷宫战斗场景
---@class MiGongFightScene_View : FightScene_View @
---@field super FightScene_View @FightScene_View
local M = class("MiGongFightScene_View",Battle.FightScene_View)

function M:init(model)
    M.super.init(self,model)
end

function M:setFog()
    U3DUtil:Set_RenderSettings_Fog_Distance(450)
end

function M:getCurSceneName()
    return "migong";
end

function M:getCurSceneObjName()
    return "migong_data_fight";
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
end


function M:initSceneObjects(data)
    M.super.initSceneObjects(self, data)
    if self.cameraController ~= nil and self.cameraController.Camera_3D ~= nil then
        local pos = self.cameraController.Camera_3D.transform.position
        pos.z = -48.11;
        self.cameraController.Camera_3D.transform.position = pos;
    end
end

function M:setCameraPos( vec_pos )
    
end


function M:setCameraPosition(isZhanDou)
    
end

return M;