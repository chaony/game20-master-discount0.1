local M = class("HelpDagMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("big_game_index")
end



function M:onEnter()
	self.level_items = {
		{id = 1, item_name = "level_cell_1", name_text = "tid#BigGameStage_1",show_level_name = "level_1",show_level_line_name = "level_line_1"},
		{id = 2, item_name = "level_cell_2", name_text = "tid#BigGameStage_2",show_level_name = "level_2",show_level_line_name = "level_line_2"},
		{id = 3, item_name = "level_cell_3", name_text = "tid#BigGameStage_3",show_level_name = "level_3",show_level_line_name = "level_line_3"},
	}
	self.m_show_level_num = 1
	self.stage = self.m_params.stage
end


--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

--获取关卡列表
function M:getLevelData()
	return self.level_items
end

--获取游戏名称
function M:getActiveName()
	local open_condition =  ConfigManager:getCfgByName("open_condition")
	return open_condition[430]
end

--获取关卡通关进度
function M:getLevelCompleteNum()
	if self.m_show_level_num  == 2 and #self.m_data.stage["1"] < 15 then
		return -1
	end
	if  not self.m_data.stage[tostring(self.m_show_level_num)] then
		return 0
	end
	return #self.m_data.stage[tostring(self.m_show_level_num)]
end

--获取游戏奖励
function M:getGameReward()
	local big_game =  ConfigManager:getCfgByName("big_game")
	local current_level_data = big_game[self.m_show_level_num]
	local reward_data = {}
	for i, v in pairs(current_level_data) do
		if #v.reward >= 1 then
			local data  = {id = i,cfg = v}
			table.insert(reward_data,data)
		end
	end
	return reward_data
end

--获取奖励是否已领取
function M:getRewardStage(id)
	if self.m_data.receive[tostring(self.m_show_level_num)] then
		for i, v in ipairs(self.m_data.receive[tostring(self.m_show_level_num)]) do
			if v == id then
				return 1
			end
		end
	end
	return 0
end

--关卡是否可以开启
function M:getLevelIsOpen(level_id)
	local big_game =  ConfigManager:getCfgByName("big_game")
	local current_level_data = big_game[self.m_show_level_num]
	local current_data = current_level_data[level_id.id]
	local lastLevel = level_id.id - 1
	if self.m_show_level_num == 1 and level_id.id == 1 then
		return 1 --可以进入
	end
	if current_data.unlock_stage == 0 then --没有关卡限制
		if self.m_data.stage[tostring(self.m_show_level_num)] ~= nil
				and #self.m_data.stage[tostring(self.m_show_level_num)] >= lastLevel then --前一关通关
			return 1 --可以进入
		else
			return 2 --未通关上一关卡
		end
	else
		local curStage = UserDataManager:getCurStage()
		if curStage >= current_data.unlock_stage then  --达到通关标准
			if self.m_data.stage[tostring(self.m_show_level_num)] ~= nil
					and #self.m_data.stage[tostring(self.m_show_level_num)] >= lastLevel then --前一关通关
				return 1 --可以进入
			else
				return 2 --未通关上一关卡
			end
		else  --限制关卡没有通关
			if self.m_show_level_num == 1 then
				return 3 ,current_data.unlock_stage--跳转引导
			else
				return 4,current_data.unlock_stage --关卡未通关提示
			end
		end
	end
end

--是否有解锁关卡限制
function M:getLockStage(level_id)
	local big_game =  ConfigManager:getCfgByName("big_game")
	local current_level_data = big_game[self.m_show_level_num]
	local current_data = current_level_data[level_id]
	local unlock_stage = current_data.unlock_stage or 0
	return unlock_stage
end

return M
