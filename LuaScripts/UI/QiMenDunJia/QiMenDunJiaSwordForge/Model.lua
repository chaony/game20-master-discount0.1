local M = class("QiMenDunJiaSwordForgeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_selected_cell_data = {}
	self.m_relics_progress_loopScroll_position = 0
	self.m_data = self.m_params.main_data or {}
	self.m_version = self.m_data.ver or 0
	self.m_relics_id = 1
	self.m_relics_level = 1
	self.m_relics_position = 1
	self.m_relics_data = {}
	self:initRelicsData()
	self:initSelectedCellData()
end

function M:getVersion()
	return self.m_version
end

function M:getRelicsID()
	return self.m_relics_id
end

function M:getRelicsLevel()
	return self.m_relics_level
end

function M:getRelicsPosition()
	return self.m_relics_position
end

function M:initRelicsData()
	local relics_data = self.m_data.guild_relics or {}
	for k, v in pairs(relics_data) do
		self.m_relics_id = tonumber(k)
		self.m_relics_level = v
		break
	end
	self.m_relics_data = {}
	local relics_tab = ConfigManager:getCfgByName("treasure_config") or {}
	local relics_id_tab = relics_tab[self.m_relics_id] or {}
	self.m_relics_position = relics_id_tab.position or 0
	for k,v in pairs(relics_id_tab.detail or {}) do
		local status = 0
		if k <= self.m_relics_level then
			status = 2	-- 已领取
		else
			status = 0 -- 未完成
		end
		table.insert(self.m_relics_data, {id = v.skill_id, lv = k, status = status, cfg = v})
	end
	table.sort(self.m_relics_data, function(data1, data2)
		return data1.lv < data2.lv
	end)
end

--默认选中当前等级
function M:initSelectedCellData()
	for k, v in pairs(self.m_relics_data) do
		if v.lv == self.m_relics_level then
			self.m_selected_cell_data = v
			break
		end
	end
end

function M:updateRelicsData(data)
	self.m_data.guild_relics = data.guild_relics or {}
	self.m_data.relic_exp = data.relic_exp or 0
	self:initRelicsData()
	self:initSelectedCellData()
end

function M:getRelicsData()
	return self.m_relics_data, self.m_relics_level
end

function M:getCurrentRelicsData()
	for k, v in pairs(self.m_relics_data) do
		if self.m_relics_level == v.lv then
			return v
		end
	end
end

function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[id]
end

function M:isRelectMaxLevel()
	for k, v in pairs(self.m_relics_data) do
		if v.lv > self.m_relics_level then
			return false
		end
	end
	return true
end

function M:isRelicsFunctionOpen()
	return next(UserDataManager.m_slots) ~= nil
end

function M:isCurrentRelicsAvailableToUse()
	local slot_data = UserDataManager.m_slots or {}
	return slot_data[tostring(self.m_relics_position)] and slot_data[tostring(self.m_relics_position)] ~= self.m_relics_id
end

function M:isSelectCurrentLevel()
	return self.m_relics_level == self.m_selected_cell_data.lv
end

function M:getRelicsExpCount()
	return self.m_data.relic_exp or 0
end

function M:getCurrentLevelRelicsCost()
	if next(self.m_selected_cell_data) then
		local cost_data = RewardUtil:getProcessRewardData(self.m_selected_cell_data.cfg.cost[1]) or {}
		return cost_data.data_num or 0
	end
	return 0
end

function M:getSelectedCellData()
	return self.m_selected_cell_data
end

function M:setSelectedCellData(data)
	self.m_selected_cell_data = data
end

function M:setRelicsProgressLoopScrollPosition(position)
	self.m_relics_progress_loopScroll_position = position
end

function M:getRelicsProgressLoopScrollPosition()
	return self.m_relics_progress_loopScroll_position
end

function M:getShareLv()
	local weapon_lock_lv = ConfigManager:getCommonValueById(577,160)
	local top_hero = UserDataManager.hero_data:getLevelTop()
	if next(top_hero) == nil then
		return true
	end
	if #top_hero >= 5 then
		local cur_data = top_hero[5]
		if cur_data[2] >= weapon_lock_lv then
			return true
		end
	else
		return false
	end
	return false
end

return M
