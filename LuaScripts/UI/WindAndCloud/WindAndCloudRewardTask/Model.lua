local M = class("WindAndCloudRewardTaskModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.version = self.m_params.version or 1
	self.open_id = self.m_params.open_id or 405
	self:getData()
end

function M:onEnter()
	
end


function M:getQuestList()
	local diamond_milepost = ConfigManager:getCfgByName("diamond_rebate_milepost")
	return diamond_milepost[self.open_id][self.version]
end

return M