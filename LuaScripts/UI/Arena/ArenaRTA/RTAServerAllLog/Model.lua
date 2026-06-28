---@class RTAServerAllLogModel:OODataBase
local M = class("RTAServerAllLogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"

	self:getData("rta_server_battle_logs")
end

function M:onEnter()
	self.refresh_cd=self.m_data.refresh_cd
end


function M:updateData(callback)
	self:getNetData("rta_server_battle_logs",nil,function(data)
		self.m_data=data
		self.refresh_cd=data.refresh_cd
		if callback then
			callback()
		end
	end)
end

function M:getShowData()
	local logs = self.m_data.logs or {}
	logs=self:checkErroData(logs)
	return logs
end

function M:checkErroData(logs)
	local data={}
	for i, log in pairs(logs) do
		if type(log.atk.avatar)~="function" then
			table.insert(data,log)
		end
	end

	return data
end

function M:getWinerAndLoser(logData)
	local winer=nil
	local loser=nil
	if logData.atk.uid==logData.winer then
		winer=logData.atk
		loser=logData.def
	else
		winer=logData.def
		loser=logData.atk
	end
	return winer,loser
end

function M:getFreeTimes()
	if self.m_is_zf then
		return self.m_free_times
	else
		local arena_free_times = ConfigManager:getVipValueByKey("arena_free_times", 0)
		return arena_free_times - self.m_free_times
	end

end

function M:initData(data)
    table.merge(self.m_data, data)
end

return M
