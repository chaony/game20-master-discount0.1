local M = class("BossFightMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("full_service_index")
end

function M:onEnter()
	self:updateData(self.m_data)
	self:initBossCfg()
end

function M:updateData(response)
	self.m_boss_max_damage = response.boss_max_damage or 0
	self.m_version = response.version or 0
	self.m_active_day = response.active_day or 0
	self.m_top_three_info = response.boss_damage_ranks_info or {}
	self.m_actives_name = response.phase_info.phase_cfg.name or ""
	self.m_phase = response.phase_info.phase or 0
	self.m_phase_day =  response.phase_info.phase_day
	self.m_self_boss_damage_rank = response.self_boss_damage_rank or 0
	self.m_rank_count = response.boss_rank_count or 1
	self.m_rank_count = response.end_ts or 1
end

function M:initBossCfg()
	local cfg = ConfigManager:getCfgByName("full_service_boss")
	local full_service_phase_cfg = ConfigManager:getCfgByName("full_service_phase")
	self.m_boss_cfg = {}
	self.m_phase_info_cfg = {}
	if next(cfg) then
		for i, v in ipairs(cfg[self.m_version]) do
			self.m_boss_cfg[i] = cfg[self.m_version][i] or {}
			self.m_boss_cfg[i].id = i
		end
		--self.m_boss_cfg = cfg[self.m_version] or {}
		if self.m_phase == 1 then --boss准备阶段
			self.m_select_data = self.m_boss_cfg[1]
		else
			self.m_select_data = self.m_boss_cfg[self.m_phase_day]  --服务器返回了day  去用接口里面的
		end
	end
	if next(full_service_phase_cfg) then
		self.m_phase_cfg = full_service_phase_cfg[self.m_version] or {}
		self.m_phase_time_cfg = {}
		for k,v in ipairs(self.m_phase_cfg) do
			self.m_phase_info_cfg[v.type] = {time = v.phase_time,name = v.name} --Type对应的阶段
			self.m_phase_time_cfg[v.type] = {end_day = v.end_day}
		end
	end
end

--获取活动结束时间
function M:getEndTs()
	local end_ts = self.m_data.phase_info.phase_end_ts
	if end_ts ~= nil or end_ts ~= 0 then
		return end_ts - UserDataManager:getServerTime()	
	end
	--if self.m_params and self.m_params.end_ts then
	--	return self.m_actives.end_ts - UserDataManager:getServerTime()
	--end
	return 0
end

return M
