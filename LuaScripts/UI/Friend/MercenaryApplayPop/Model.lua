local M = class("MercenaryApplayPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local params = {}
	params.friends = self.m_params.friends
	-- Logger.log(params,"params ====")
	self:getData("apostle_friend_apostle", params, nil, GlobalConfig.POST)
end

function M:onEnter()
	self.m_tab_index = 1
end

function M:setTabIndex(index)
	self.m_tab_index = index
end

function M:updateData(index, data)
	self.m_data.apply_num = data.apply_num
	self.m_data.apostles[index] = data.apostle
end

function M:getDataByIndex(index)
	return self.m_data.apostles[index]
end

function M:getApplayNum()
	local num = 0
	for i,v in ipairs(self.m_data.apostles) do
		if v.applied then
			num = num + 1
		end
	end
	return num
end

return M
