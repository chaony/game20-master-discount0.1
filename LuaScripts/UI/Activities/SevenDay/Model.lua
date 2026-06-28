local M = class("SevenDayPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("active_seven_tour_index")
end

function M:onEnter()
	self:dayCompute()
	self:updateList()
end

function M:updateData(data)
	self.m_data.seven_tour_received = data
	self:updateList()
end

function M:dayCompute()
	local reg_ts = UserDataManager.reg_ts
	local server_ts = UserDataManager:getServerTime()
	local day = GameUtil:getTimeLayoutBySecond(server_ts - reg_ts) or 0
	self.m_day = day + 1
end

function M:getStatus(day)
	if self.m_day < day then
		return 0 -- 不可领取
	end
	for i,v in ipairs(self.m_data.seven_tour_received) do
		if v == day then
			return 2 -- 以领取
		end
	end
	return 1 -- 可领取
end

function M:updateList()
	local seven_tour = ConfigManager:getCfgByName("seven_tour")
	self.m_seven_cfg = table.copy(seven_tour)
	local function listsort(data1,data2)
		local status1 = self:getStatus(data1.day)
		local status2 = self:getStatus(data2.day)
		if status1 == 2 then
			if status2 == 2 then
				return data1.day < data2.day
			else
				return false
			end
		elseif status2 == 2 then
			return true
		else
			return data1.day < data2.day
		end
	end
	table.sort(self.m_seven_cfg, listsort)
end

return M
