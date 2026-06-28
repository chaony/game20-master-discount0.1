local M = class("StageRewardDetailsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_stage_id = self.m_params
	local key_id = 1 
	local index = 1
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	for i,v in ipairs(stage_tab) do
		if v.stage_id >= key_id and v.stage_id <= self.m_stage_id then
			key_id = v.stage_id
			index = i
		end
	end
	self.m_show_id = index
	Logger.log(self.m_show_id, "m_show_id ====")
	self:getBeInLineForData()
	self:getBeInLineFor()
end

--可获得
function M:getObtainable()
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	local stage_show = stage_tab[self.m_show_id] or {} 
	return stage_show.idle_reward_show or {}
end

--下阶段名字
function M:getNextName()
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	local next_tab = stage_tab[self.m_show_id+1]
	if next_tab ~= nil then
		local stage_tab2 = ConfigManager:getCfgByName("stage")
		local next_nn = stage_tab2[next_tab.stage_id]
		local name = Language:getTextByKey(next_nn.map_point_name)
		return name
	end
	return nil
end


--下阶段可获得
function M:getNextObtainable()
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	local stage_show = stage_tab[self.m_show_id + 1] or {} 
	return stage_show.idle_reward_show or {}
end

--即将获得
function M:getBeInLineFor()
	local cur_table =  table.copy(self:getObtainable()) 
	local next_table = table.copy(self:getNextObtainable()) 
	
	local i, m = 1, #next_table
	while i <= m do
		local c_d = next_table[i]
		if self:isHav(c_d,cur_table) then
			table.remove(next_table, i)
			i = i -1
			m = m -1
		end
		i = i +1
	end

	return next_table
end
  
function M:isHav(data,t)
	for k,v in pairs(t) do
		local data_1 = RewardUtil:getProcessRewardData(data)
		local data_2 = RewardUtil:getProcessRewardData(v)
		if data_1.data_id == data_2.data_id then
			return true
		end
	end
	return false
end

--下次获得新装备的关卡id
function M:getBeInLineForData()
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	local stage_show = {} or stage_tab[1]
	local k_tab = {}
	for k,v in pairs(stage_tab) do
		table.insert( k_tab,{id = k ,data = v} )
	end	
	table.sort(k_tab,function(a,b) return a.id < b.id end)
	for k,v in ipairs(k_tab)do
		if self.m_stage_id < v.id then
			return v.id
		end
	end
	return nil
end

--下次获得新道具关卡的名字
function M:getNewEqpStage()
	local stage_tab = ConfigManager:getCfgByName("stage")
	local new_id = self:getBeInLineForData()
	if stage_tab[new_id] then
		return stage_tab[new_id].map_point_name
	end
	return nil
end

return M
