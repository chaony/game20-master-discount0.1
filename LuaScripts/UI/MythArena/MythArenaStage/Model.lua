local M = class("MythArenaStageModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self:updateData(self.m_params)
	self.m_act_data = UserDataManager:getActivesDataByOpenId(320)
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_times") or {}
end

function M:updateData(data)
	if self.m_data == nil then self.m_data = {} end
	table.merge(self.m_data, data)
	self.m_version = self.m_data.version or 1
	self.m_act_data = UserDataManager:getActivesDataByOpenId(320)
	self.m_cur_day = self.m_data.active_day or 1
	self.m_small_stage = self.m_data.small_stage or 1
	self.m_big_stage = self.m_data.big_stage or 1
	self.m_small_end_time = self.m_data.small_end_time or 1
	self.m_pop_data =  self.m_data.pop_data or 0
end

function M:getCfgValueByKey(cfg_key)
	if self.m_myth_times_cfg[cfg_key] then
		return self.m_myth_times_cfg[cfg_key]
	end
	return nil
end

return M
