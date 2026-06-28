--玩家的技能管理器 
---@class Team_View : ViewBase @
---@field plyMgr PlayerManager_View
---@field model Team_Model
local M = class("Team_View", Battle.ViewBase)

--技能初始化
function M:init(plyMgr, teamModel)
	self.plyMgr = plyMgr;
	self.model = teamModel
	
	self:addEventListener_Local(Battle.EventType.MV_PetContestValueChanged, {self, self.MV_PetContestValueChanged})
end

function M:MV_PetContestValueChanged()
	Logger.log(Json.encode({self.model.camp, self.model.petContest}), "宠物气势------")
end

--销毁
function M:destroy()
	self.plyMgr = nil;
end

return M