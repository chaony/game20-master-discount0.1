local M = class("CombatSuppressSystemModel", LikeOO.OODataBase)
function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_team = self.m_params.main_team or {}
	self.m_enemy_team = self.m_params.def_data or {}
	self.m_formation_index = self.m_params.index or 1 -- 多阵容显示索引
	self.combat_repress_level_data = ConfigManager:getCfgByName("combat_repress_level")
	self.combat_repress_data = ConfigManager:getCfgByName("combat_repress")
	self.m_locate_type_data = {}
	self:getTypeData()
	self.m_level = 0
	self.m_enemy_level = 0
	self.m_type_value = table.copy(self.m_locate_type_data)
	self.m_enemy_type_value = table.copy(self.m_locate_type_data)
	self.m_target_table = {}
	self:reSetScoreByType()
	self:getLeftListData()
	self:getRightListData()
	self.m_locate_type_data = self:insertOneValueOnStart("",self.m_locate_type_data)
	self:compareLevel()
	
end

function M:getTypeData()
	for k,v in pairs(self.combat_repress_data) do
		self.m_locate_type_data[v.locate_type] = v.locate1_type_des
	end
end

function M:reSetScoreByType()
	for k,v in ipairs(self.m_type_value) do
		self.m_type_value[k] = 0
	end
	for k,v in ipairs(self.m_enemy_type_value) do
		self.m_enemy_type_value[k] = 0
	end
end
--计算自身数据
function M:getLeftListData()
	local my_score = 0
	for k,oid in ipairs(self.m_team) do
		local _,nums1 = GameUtil:countCombatRepressGrade(oid)
		my_score = my_score + nums1
		self:appendTypeValue(_,self.m_type_value)
	end
	local _,nums2 = GameUtil:countGlobalCombatRepressGrade()
	self:appendTypeValue(_,self.m_type_value)
	my_score = my_score + nums2
	self.m_type_value = self:insertOneValueOnStart(my_score,self.m_type_value)
	self.m_level = GameUtil:getCombatSupressLevel(my_score)
end

function M:getRightListData()
	--计算他人的分数
	local other_score = 0
	if self.m_enemy_team and next(self.m_enemy_team) and self.m_enemy_team.heros ~= nil then
		local teams
		if self.m_enemy_team.teams then
			teams = self.m_enemy_team.teams[self.m_formation_index]
		else
			teams = self.m_enemy_team.team or {}
		end
		for k,oid in pairs(teams) do
			local hero_data = self.m_enemy_team.heros[oid]
			local _,nums1 = GameUtil:countCombatRepressGrade(oid,hero_data)
			other_score = other_score + nums1
			self:appendTypeValue(_,self.m_enemy_type_value)
		end
		local _,nums3 = GameUtil:countGlobalCombatRepressGrade(self.m_enemy_team.combat_repress or {})
		self:appendTypeValue(_,self.m_enemy_type_value)
		other_score = other_score + nums3
	end
	self.m_enemy_type_value = self:insertOneValueOnStart(other_score,self.m_enemy_type_value)
	self.m_enemy_level = GameUtil:getCombatSupressLevel(other_score)
end

function M:appendTypeValue(ori,target)
	for k,v in pairs(ori) do
		target[k] = (target[k] or 0) + v
	end
end

function M:compareLevel()
	for k,v in ipairs(self.m_type_value) do
		self.m_target_table[k] = v > self.m_enemy_type_value[k] and v or self.m_enemy_type_value[k]	
	end		
end

function M:insertOneValueOnStart(value,ori_data)
	--特殊处理，插入等级
	local temp_table = {}
	table.insert(temp_table,value)
	for k1,v1 in ipairs(ori_data) do
		table.insert(temp_table,v1)
	end
	return temp_table
end

return M

