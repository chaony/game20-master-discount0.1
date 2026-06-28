local M = class("FateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hotel_love_info")
end

function M:onEnter()
	self.m_cur_hero = self.m_data.cur_hero
	self.m_cur_dare_num = self.m_data.cur_dare_num
	self.m_dare_num_max = self.m_data.dare_num_max
	self.m_listen_cd = self.m_data.listen_cd
	self:formatFate(self.m_data.clear_recv, self.m_data.stage)
end

function M:formatFate(clear_recv, stages)
	self.m_fates = {}
	local cfg = ConfigManager:getCfgByName("hotel_love_base")
	local stage = ConfigManager:getCfgByName("stage")
	for k,v in pairs(cfg) do
		local i = #self.m_fates + 1
		self.m_fates[i] = {}
		self.m_fates[i].hero_id = k
		self.m_fates[i].clear_awards = v.clear_awards
		self.m_fates[i].reward_status = 0 --未通关
		self.m_fates[i].stage = 0
		local stage_item = stage[v.open_stage] or {}
		self.m_fates[i].open_stage = v.open_stage
		self.m_fates[i].open_stage_name = Language:getTextByKey(tostring(stage_item.map_point_name))
		local isPass = false
		local key = tostring(k)
		if table.keyof(clear_recv, k) ~= nil then
			self.m_fates[i].reward_status = 2 --已领取
			isPass = true
		end
		local stage = stages[key]
		if isPass == false and stage ~= nil then
			self.m_fates[i].stage = stage
			self.m_fates[i].reward_status = self:getRewardStatus(k, stage)
		end
	end
	--按照开启关卡排序
	local function sortFunc(fate1, fate2)
		return fate1.open_stage < fate2.open_stage
	end
	table.sort(self.m_fates, sortFunc)
end

function M:updateData(response)
	self.m_cur_hero = response.cur_hero
	self.m_cur_dare_num = response.cur_dare_num
	self.m_dare_num_max = response.dare_num_max
	self.m_listen_cd = response.listen_cd
	self:formatFate(response.clear_recv, response.stage)
end

function M:getFate(hero_id)
	for i,v in ipairs(self.m_fates) do
		if v.hero_id == hero_id then
			return v
		end
	end
end

function M:getFateStages(hero_id)
	local all_cfg = ConfigManager:getCfgByName("hotel_love_stage")
	local cfg = all_cfg[hero_id]
	local stages = {}
	for k,v in pairs(cfg) do
		local i = #stages + 1
		stages[i] = {}
		stages[i] = table.copy(v)
		stages[i].id = k
	end
	local function sortFunc(stage1, stage2)
		return stage1.id < stage2.id
	end
	table.sort(stages, sortFunc)
	return stages
end

function M:getRewardStatus(hero_id, stage)
	if stage == nil or stage <= 0 then
		return 0 --未通关 不可领取
	end
	local all_cfg = ConfigManager:getCfgByName("hotel_love_stage")
	local stages = all_cfg[hero_id]
	if stages[stage].is_end == 1 then
		return 1 --通关 可领取
	end
	return 0 --未通关 不可领取
end

function M:isChallenge(fate)
	if self.m_cur_dare_num >= self.m_dare_num_max then
		return false
	end
	if self.m_cur_hero ~= fate.hero_id then
		return false
	end
	local flag = fate.reward_status == 0 --未通关
	return flag
end

function M:updateFate(hero_id, stage)
	if stage == nil or stage <= 0 then
		return
	end
	for i, v in ipairs(self.m_fates) do
		if v.hero_id == hero_id then
			v.stage = stage
			v.reward_status = self:getRewardStatus(hero_id, stage)
			break
		end
	end
end

--某个侠客情缘通关，领取奖励后更新状态
function M:updateRewardStatus(hero_id)
	for i,v in ipairs(self.m_fates) do
		if v.hero_id == hero_id then
			v.reward_status = 2
			break
		end
	end
end

return M