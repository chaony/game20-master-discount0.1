local M = class("KingSoftChangeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_data or {}
	self.m_vsn = self.m_params.vsn or 1
	self.m_cell_data = self.m_params.cell_data or {}
	self.m_max_data = self.m_params.max_data or {}
	self.m_kingsoft_date_cfg = ConfigManager:getCfgByName("kingsoft_date")
	self.m_kingsoft_quest_cfg = ConfigManager:getCfgByName("kingsoft_quest")
	self.m_kingsoft_talk_cfg = ConfigManager:getCfgByName("kingsoft_talk")
	self.m_max_value = self:getMaxValue()
end

function M:getMaxValue()
	local max_value = 999999
	local show_id, real_id, real_num, cur_num  = self.m_cell_data[1], self.m_cell_data[2], self.m_cell_data[3], self.m_cell_data[4]
	local show_id  = self.m_cell_data[1]
	if next(self.m_max_data) and self.m_max_data[tostring(show_id)] then
		max_value = self.m_max_data[tostring(show_id)]
	end
	return max_value + cur_num
end

function M:getTipsCfgById(tips_id)
	if self.m_kingsoft_talk_cfg[tips_id] then
		return self.m_kingsoft_talk_cfg[tips_id]
	end
	return nil
end

function M:getTypeByNums(nums)
	local text_key = "kingsoft_text_0017"
	local type_key = 3
	if nums > 99999 then -- 文本4字节
		text_key = "kingsoft_text_0019"
		type_key = 5
	elseif nums > 999 then --文本双字节
		text_key = "kingsoft_text_0018"
		type_key = 4
	end
	return text_key, type_key
end

function M:getShowCfgById(id)
	if self.m_kingsoft_date_cfg and self.m_kingsoft_date_cfg[id] then
		return self.m_kingsoft_date_cfg[id]
	end
	return nil
end

function M:getRealCfgById(id)
	if self.m_kingsoft_quest_cfg and  self.m_kingsoft_quest_cfg[self.m_vsn] and self.m_kingsoft_quest_cfg[self.m_vsn][id] then
		return self.m_kingsoft_quest_cfg[self.m_vsn][id]
	end
	return nil
end


return M
