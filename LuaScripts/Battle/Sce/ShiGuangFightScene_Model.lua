
--时光之巅战斗场景
---@class ShiGuangFightScene_Model : FightScene_Model @
---@field super FightScene_Model @FightScene_Model
local M = class("ShiGuangFightScene_Model",Battle.FightScene_Model)


function M:init()
    M.super.init(self)
    --布阵位置
end

function M:setFog()
    U3DUtil:Set_RenderSettings_Fog_Distance(450)
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
    self.gameover = false;
end


function M:setCameraPos( vec_pos )
    local vec = self.cameraController.Camera_3D.transform.localPosition
    vec.x = vec_pos.x;
    vec.y = vec_pos.y;
    vec.z = vec_pos.z;
    self.cameraController.Camera_3D.transform.localPosition = vec
end


function M:setCameraPosition(isZhanDou)
    if isZhanDou then
        self:setCameraPos(self.camera_zd_pos);
        self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.camera_zd_rot.x, self.camera_zd_rot.y, self.camera_zd_rot.z);
    else
        self:setCameraPos(self.camera_bz_pos);
        self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.camera_bz_rot.x, self.camera_bz_rot.y, self.camera_bz_rot.z);
    end
end


return M