local M = class("LegendModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	if self.m_params.data then
		self:getData()
	else
		self:getData("world_boss_trial_index")
	end
	
end

function M:onEnter()
	if self.m_params.data then
		self.m_data = self.m_params.data
	else
		self.m_data = self.m_data.legend	
	end

	self:updateData()
end

function M:updateData()
	local legend_stage_cfg = ConfigManager:getCfgByName("legend_stage")
	self.legend_stage = legend_stage_cfg[self.m_data.stage_id]
	self:getTalkCfg()
end

function M:getLegend()
	return self.legend_stage
end

function M:getTalkCfg()
	local legend_random_talk_cfg = ConfigManager:getCfgByName("legend_random_talk")

	self.talk_list = {}
	if self.legend_stage ~= nil then
		for k,v in ipairs(self.legend_stage.talk) do
			local cfg = legend_random_talk_cfg[v]
			if cfg ~= nil and self.talk_group_id == nil then
				for k1,v1 in pairs(cfg) do
					if v1.condition == 0 then
						self.talk_group_id = v
						if v1.before ~= 0 then
							self.talk_list[v1.before] = k1
						else
							self.talk_start = k1
						end
					else
						break	
					end
				end
			else
				break	
			end
		end
	end
end

function M:isAtTopLevel()
	local level_cur = self.m_data.level or 0
	local level_total = 0
	for k, v in pairs(self.m_data.weekly_quests or {}) do
		level_total = level_total + 1
	end
	return level_cur >= level_total and level_total > 0
end

return M
