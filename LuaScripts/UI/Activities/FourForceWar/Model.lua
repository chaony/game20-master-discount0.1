local M = class("FourForceWarIndexModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token
	self:getData("enjoy_spring_index")
end

function M:onEnter()
	Logger.log(self.m_data,"enjoy_spring_index ====")
	self.m_open_id = 309
	self.m_act_data = UserDataManager:getActivesDataByOpenId(self.m_open_id)
end

function M:updateData(data)
	if data then
		self.m_data = data
	end
end

function M:getEndTs()
	if self.m_act_data and self.m_act_data.end_ts then
		return self.m_act_data.end_ts - UserDataManager:getServerTime(), self.m_act_data.open_status
	end
	return 0
end

return M
