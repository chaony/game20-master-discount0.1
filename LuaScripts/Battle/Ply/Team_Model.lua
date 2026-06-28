---@class Team_Model @队伍
---@field camp number 我方:1 敌方:-1
---@field petContest number
local M = class("Team_Model", Battle.ModelBase)

function M:init(plyMgr, camp)
	self.plyMgr = plyMgr
	self.camp = camp
	self.petContest = 0
	self.plyMgr:dispatchEvent_Local(Battle.EventType.MV_TeamModelCreateFinish, self);
end

function M:destroy()
	
end

function M:setPetContest(value)
	self.petContest = value
	self:dispatchEvent_Local(Battle.EventType.MV_PetContestValueChanged, self);
end

return M
