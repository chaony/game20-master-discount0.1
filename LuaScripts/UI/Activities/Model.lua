local M = class("ActivitiesPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("active_active_index")
end

function M:onEnter()
	self:initActiveEndTime()
end

function M:updateData(data)
	self.m_data = data
	self:initActiveEndTime()
end

function M:getDataByIndex(index)
	return self.m_data[index]
end

function M:initActiveEndTime()
	local server_time = UserDataManager:getServerTime()
	for i,v in ipairs(self.m_data) do
		if v.remain_ts > 0 then
			v.end_ts = server_time + v.remain_ts
		end
	end
end

return M
