local M = class("UnionLogModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("guild_log_index")
end

function M:onEnter()
	local date = nil
	local data = {}
	for i,v in ipairs(self.m_data.logs) do
		local format_date = os.date("%m-%d", v.time)
		if date ~= format_date then
			date = format_date
			time = os.date("%H:%M", v.time)
			data[#data + 1] = {cell_type = 1, data = format_date, time = time}
		end
		data[#data + 1] = {cell_type = 2, data = v}
	end
	self.m_list_data = data
end

function M:callBack(data)
	local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    if guild_id and guild_id > 0 then
    	M.super.callBack(self,data)
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("union_str_0028"), delay_close = 2})
        static_rootControl:closeAllViewPop()
    end
end

return M
