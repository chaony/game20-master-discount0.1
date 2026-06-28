local M = class("KingsoftPopModel", LikeOO.OODataBase)

function M:onCreate()
	--self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("active_kingsoft_index")
end

function M:onEnter()
	self.m_cur_index = 1
	self.m_select_total_times = 0
	local server_ts = UserDataManager:getServerTime()
	self.m_kingsoft_date_cfg = ConfigManager:getCfgByName("kingsoft_date")
	self.m_kingsoft_quest_cfg = ConfigManager:getCfgByName("kingsoft_quest")
	self.m_kingsoft_talk_cfg = ConfigManager:getCfgByName("kingsoft_talk")
	self.m_version = 0
	self.m_is_show_logo = true
	if self.m_data.kingsoft_ranger and self.m_data.kingsoft_ranger.version then
		self.m_version = self.m_data.kingsoft_ranger.version
	end
end

function M:updateData(data)
	if data and next(data) then
		self.m_data = data
	end
end

function M:getTipsCfgById(tips_id)
	if self.m_kingsoft_talk_cfg[tips_id] then
		return self.m_kingsoft_talk_cfg[tips_id]
	end
	return nil
end

function M:getTypeByNums(nums)
	local text_key = "kingsoft_text_0019"
	if nums > 99999 then -- 文本4字节
		text_key = "kingsoft_text_0019"
	elseif nums > 999 then --文本双字节
		text_key = "kingsoft_text_0018"
	else
		text_key = "kingsoft_text_0017"
	end
	return text_key
end

function M:getSearchData()
	local s_data = {}
	if self.m_data.kingsoft_ranger and self.m_data.kingsoft_ranger.random_ids then
		s_data = self.m_data.kingsoft_ranger.random_ids
	end
	return s_data
end

function M:getResultData()
	local r_data = {}
	if self.m_data.kingsoft_ranger and self.m_data.kingsoft_ranger.select then
		r_data = self.m_data.kingsoft_ranger.select
	end
	return r_data
end

function M:getMaxData()
	local max_data = {}
	if self.m_data.max_values  then
		max_data = self.m_data.max_values
	end
	return max_data
end

function M:getHistoryData()
	local h_data = {}
	if self.m_data.kingsoft_ranger and self.m_data.kingsoft_ranger.modify then
		h_data = self.m_data.kingsoft_ranger.modify
	end
	return h_data
end

function M:isCanSelect(show_id)
	local r_data = self:getResultData()
	if #r_data >= 10 then
		return false, "kingsoft_text_0045"
	else
		for i = 1, #r_data do
			if r_data[i][1] == show_id then
				return false, "kingsoft_text_0046"
			end
		end
	end
	return true
end

function M:getShowCfgById(id)
	if self.m_kingsoft_date_cfg and self.m_kingsoft_date_cfg[id] then
		return self.m_kingsoft_date_cfg[id]
	end
	return nil
end

function M:getRealCfgById(id)
	if self.m_kingsoft_quest_cfg and  self.m_kingsoft_quest_cfg[self.m_version] and self.m_kingsoft_quest_cfg[self.m_version][id] then
		return self.m_kingsoft_quest_cfg[self.m_version][id]
	end
	return nil
end

function M:setCurIndex(index)
	self.m_cur_index = index
end

return M
