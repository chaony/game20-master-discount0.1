local M = class("CollectionPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_output = self.m_params.output_data or {}
end

function M:getAllRewards()
	local reward_num = nil
	--Logger.logErrorAlways(self.m_output,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
	for i,v in pairs(self.m_output) do
		if next(v) ~= nil then
			if reward_num == nil then
				reward_num = v[1]
			else
				reward_num[3] = reward_num[3] + v[1][3]
			end
		end
	end
	return reward_num
end


return M
