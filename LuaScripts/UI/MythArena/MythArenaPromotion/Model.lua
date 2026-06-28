local M = class("MythArenaPromotionModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_times") or {}
	self.m_pop_type = 1
	self.m_pop_data = self.m_params.pop_data
	if self.m_pop_data == 3 then
		self.m_pop_type = 3
	elseif  self.m_pop_data == 5  then
		self.m_pop_type = 2
	elseif self.m_pop_data == 7 or self.m_pop_data == 6  then
		self.m_pop_type = 1
	end
	self.m_stage_name = "wlsh_text_0013"
	local cur_stage_cfg = self:getCfgValueByKey(self.m_pop_data)
	if cur_stage_cfg then
		self.m_stage_name = cur_stage_cfg.name
	end
end

function M:getCfgValueByKey(cfg_key)
	if self.m_myth_times_cfg[cfg_key] then
		return self.m_myth_times_cfg[cfg_key]
	end
	return nil
end
return M
