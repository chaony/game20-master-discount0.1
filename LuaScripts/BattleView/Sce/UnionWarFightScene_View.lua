---@class UnionWarFightScene_View : FightScene_View @
---@field super FightScene_View @FightScene_View
local M = class("UnionWarFightScene_View",Battle.FightScene_View)

function M:init(model)
    M.super.init(self,model)

    local migong_zd_position = self.battleCameraConfig.migong_zd_position;
    local migong_zd_pos = Vector3( tonumber(migong_zd_position.x),tonumber(migong_zd_position.y),tonumber(migong_zd_position.z))

    local migong_zd_rotation = self.battleCameraConfig.migong_zd_rotation;
    local migong_zd_rot = Vector3( tonumber(migong_zd_rotation.x),tonumber(migong_zd_rotation.y),tonumber(migong_zd_rotation.z))

    local migong_bz_position = self.battleCameraConfig.migong_bz_position;
    local migong_bz_pos = Vector3( tonumber(migong_bz_position.x),tonumber(migong_bz_position.y),tonumber(migong_bz_position.z))

    local migong_bz_rotation = self.battleCameraConfig.migong_bz_rotation;
    local migong_bz_rot = Vector3( tonumber(migong_bz_rotation.x),tonumber(migong_bz_rotation.y),tonumber(migong_bz_rotation.z))

    --布阵位置
    self.camera_bz_pos = migong_bz_pos
    self.camera_bz_rot = migong_bz_rot
    self.camera_zd_pos = migong_zd_pos
    self.camera_zd_rot = migong_zd_rot

end

function M:setFog()
    U3DUtil:Set_RenderSettings_Fog_Distance(450)
end

function M:getCurSceneName()
    return "unionwar";
end

function M:getCurSceneObjName()
    return "unionwar_data_fight";
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);

end

function M:createPlayerAndEnemyFinish()
    M.super.createPlayerAndEnemyFinish(self)
    self.gameover = false;
end

function M:setCameraPos( vec_pos )

end


function M:setCameraPosition(isZhanDou)

end

return M;