local M = class("GuildHighWarCityLogPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_city_id = self.m_params.city_id or 0
	local params = {}
	params.start = 1
	params.stop = 10
	params.city_id = self.m_city_id
	self:getData("guild_high_war_city_logs", params)
end

function M:onEnter()
	local data = self.m_data
	self.m_logs = self.m_data.logs or {}
	self.m_count = self.m_data.count or 0
	self.m_mode = "atk" --进攻或者驻守
end

function M:getRankNums()
	return #self.m_data.logs
end

function M:updateRank(data)
	if data then
		if data.logs then
			for i=1, #data.logs do
				table.insert(self.m_data.logs, data.logs[i])
			end
		end
		--self.m_data.logs = data.logs or self.m_data.logs
	end
end

return M
