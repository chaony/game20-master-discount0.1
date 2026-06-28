local M = class("MagicWeaponModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("relic_index")
end

function M:onEnter()
	local lv_top = UserDataManager.hero_data:getLevelTop()
	self.m_select_id = self:getDefID()
	if self.m_select_id == 0 then
		local tre_pos_cfg = self:getTreasurePosition(1)
		if tre_pos_cfg then
			local treasure = {}
			local seascon = UserDataManager:getCurSeason()
			if tre_pos_cfg.treasure_s and tre_pos_cfg.treasure_s[seascon] then
				treasure = tre_pos_cfg.treasure_s[seascon]
			else
				treasure = tre_pos_cfg.treasure
			end
			self.m_data.slots[tostring(1)] = treasure[1]
			self.m_select_id = treasure[1]
		else
			self.m_data.slots[tostring(1)] = 101
			self.m_select_id = 101
		end
	end
	if next(lv_top) == nil then
		if UserDataManager.m_clv > 0 then
			local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
			local crystal = crystal_upgrade[UserDataManager.m_clv]
			if crystal ~= nil and crystal.display_level > 300 then
				self.m_unlock_lv = crystal.display_level
			else
				self.m_unlock_lv = 300
			end
		else
			self.m_unlock_lv = 300
		end
	elseif lv_top[5] then
		self.m_unlock_lv = lv_top[5][2]
	else
		self.m_unlock_lv = 0
	end
end

--是否是新获得的法宝
function M:checkNewWeapon(id)
	if self.m_data.need_alert then
		for k,v in pairs(self.m_data.need_alert) do
			if v == id then
				return true
			end 
		end
	end
	return false
end

function M:clickNewWeapon(id)
	if self.m_data.need_alert then
		for k,v in pairs(self.m_data.need_alert) do
			if v == id then
				table.remove(self.m_data.need_alert,k)
				break
			end 
		end
	end
end

function M:getOutputItem()
	return self.m_data.output or {}
end

--有可能传过来空的表-- 检测用
function M:checkOptputNum()
	for k,v in pairs(self.m_data.output) do
		if next(v) ~= nil then
			return true
		end
	end
	return false
end

function M:getDefID()
	if self:getWeaponIdBySlot(1) then
		return self:getWeaponIdBySlot(1)
	end
	return 101
end

function M:getWeaponIdBySlot(pos)
	return self.m_data.slots[tostring(pos)] or 0
end

function M:checkSlotOpen(index)
	local slot_cfg = self:getTreasurePosition(index)
	return self.m_unlock_lv >= slot_cfg.unlock
end

function M:getWeaponData(id)
	local data = self.m_data.relics[tostring(id)] or {}
	return data
end

function M:getTreasureConfig(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_config")
	return tab_cfg[index]
end

--法宝槽位
function M:getTreasurePosition(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_position")
	return tab_cfg[index]
end

--法宝技能排序
function M:getTreasureSort(index, tre_table)
	local war_id_by_pos = self:getWeaponIdBySlot(index)
	local function SkillSort(data1, data2)
		local war_1 = war_id_by_pos == data1 and 0 or 1
		local war_2 = war_id_by_pos == data2 and 0 or 1
		if war_1 == war_2 then 
			return data1 < data2
		else
			return war_1 < war_2
		end
	end
	table.sort(tre_table, SkillSort)
	return tre_table
end

--技能信息
function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[id]
end

--法宝加持侠客
function M:getWeaHeros()
	local cur_cfg = self:getTreasureConfig(self.m_select_id)
	local cur_data = self:getWeaponData(self.m_select_id)
	local se_id = UserDataManager:getCurSeason()
	if cur_cfg then
		local show_cfg = cur_cfg.detail[cur_data.lv] or cur_cfg.detail[1]
		local heros = {}
		for k,v in pairs(show_cfg.att_unit_list) do
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
			if hero_cfg and se_id >= hero_cfg.season then
				table.insert(heros, v)
			end
		end
		return heros
	end
	return {}
end

--获得所有消耗
function M:getAllWeaCost()
	local treasure_cfg = self:getTreasureConfig(self.m_select_id)
	local cur_data = self:getWeaponData(self.m_select_id)
	local lv = cur_data.lv
	local bast_cfg = treasure_cfg.detail[1]
	local cost_num = 0
	local cost_cfg =  table.copy(bast_cfg.cost[1])
	for i = 1,lv-1 do
		local cur_cfg = treasure_cfg.detail[i]
		cost_num = cost_num + cur_cfg.cost[1][3]
	end
	cost_cfg[3] = cost_num
	return cost_cfg
end

function M:getCanLvUp()
	local cur_cfg = self:getTreasureConfig(self.m_select_id)
	local cur_data = self:getWeaponData(self.m_select_id)
	local show_cfg = cur_cfg.detail[cur_data.lv] or cur_cfg.detail[1]
	local cost_data = RewardUtil:getProcessRewardData(show_cfg.cost[1])
	if cost_data then
		if cost_data.user_num >=cost_data.data_num then
			return true
		else
			return false, Language:getTextByKey(cost_data.name)
		end
	end		
	return true
end

--获取使用的免费次数
function M:getUseFreeNum()
	return self.m_data.reset_times or 0
end

--获取免费次数总量
function M:getAllFreeNum()
	return ConfigManager:getCommonValueById(600,30)
end

--是否还有免费次数
function M:HavFreeNum()
	return self:getUseFreeNum() < self:getAllFreeNum()
end

--帮会法宝开启状态
function M:WeaponBangType(solt_id)
	local season = UserDataManager:getCurSeason()
	--奇门遁甲开启
	if BtnOpenUtil:isBtnOpen(246) == true then
		return true
	end
	return false
end

return M
