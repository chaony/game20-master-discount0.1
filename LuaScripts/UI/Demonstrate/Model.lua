local M = class("DemonstrateSceneModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	local main_team = table.copy(UserDataManager.hero_data:getTeamByKey("stage"))
    local atk_deployment = UserDataManager.hero_data:getDeploymentByKey("stage")
    self:getData("stage_battle_start2",{team = main_team, deployment = atk_deployment},nil, GlobalConfig.POST, {forceBack = true})
end

function M:onEnter()

end

return M
