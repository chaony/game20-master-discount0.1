--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-08 15:37:07
]]

--天机楼战斗场景
---@class TianjiLouFightScene_View : FightScene_View @
---@field super FightScene_View @FightScene_View
local M = class("TianjiLouFightScene_View",Battle.FightScene_View)

function M:init(model)
    M.super.init(self,model)
    if self.battleCameraConfig.useCodeValue == "1" then
		self.useCodeValue = true;
	else
		self.useCodeValue = false;
	end

	local tianjilou_zd_position = self.battleCameraConfig.tianjilou_zd_position;
    local tianjilou_zd_pos = Vector3( tonumber(tianjilou_zd_position.x),tonumber(tianjilou_zd_position.y),tonumber(tianjilou_zd_position.z))

    local tianjilou_zd_rotation = self.battleCameraConfig.tianjilou_zd_rotation;
    local tianjilou_zd_rot = Vector3( tonumber(tianjilou_zd_rotation.x),tonumber(tianjilou_zd_rotation.y),tonumber(tianjilou_zd_rotation.z))

    local tianjilou_bz_position = self.battleCameraConfig.tianjilou_bz_position;
	local tianjilou_bz_pos = Vector3( tonumber(tianjilou_bz_position.x),tonumber(tianjilou_bz_position.y),tonumber(tianjilou_bz_position.z))

    local tianjilou_bz_rotation = self.battleCameraConfig.tianjilou_bz_rotation;
	local tianjilou_bz_rot = Vector3( tonumber(tianjilou_bz_rotation.x),tonumber(tianjilou_bz_rotation.y),tonumber(tianjilou_bz_rotation.z))

    --布阵位置
    self.camera_bz_pos = tianjilou_bz_pos
    self.camera_bz_rot = tianjilou_bz_rot

    self.camera_zd_pos = tianjilou_zd_pos
    self.camera_zd_rot = tianjilou_zd_rot
end

function M:enter(data)
    M.super.enter(self,data)
    self.linkSceneId = 4;
end

function M:setFog()

end


function M:getCurSceneName()
    return "tianjilou";
end

function M:getCurSceneObjName()
    return "tianjilou_data_fight";
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
    self.gameover = false;
end

function M:setCameraPos( vec_pos )
    local vec = self.cameraController.Camera_3D.transform.position
    vec.x = vec_pos.x;
    vec.y = vec_pos.y;
    vec.z = vec_pos.z;
    self.cameraController.Camera_3D.transform.position = vec
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


return M;