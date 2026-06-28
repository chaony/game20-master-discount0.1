local M = class("LanternFestivalFunPlayModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	--self:initData(self.m_params)
	self.m_version = self.m_params.version
	self.m_cur_day = self.m_params.cur_day or 1
	self.m_help_id = self.m_params.help_id or ""
	self.m_lantern_reward_cfg = ConfigManager:getCfgByName("lantern_reward") or {}
end

function M:initData(response)
	if response then
		table.merge(self.m_data,response)
	end

end

function M:getRewardByIndex(index)
	local reward = {}
	if self.m_lantern_reward_cfg[self.m_version] and self.m_lantern_reward_cfg[self.m_version][index] then
		reward = self.m_lantern_reward_cfg[self.m_version][index]["reward"][1]
	end
	return reward
end

function M:getTaskDetailData(day)
	day = day or self.m_cur_day
	local detail_data = {}
	local task_detail_tab = ConfigManager:getCfgByName("lantern_quest") or {}
	local task_detail_data = task_detail_tab[self.m_version] or {}
	local item_temp
	for key_cfg, item_cfg in pairs(self.m_data.quests) do
		item_temp = {}
		for key_detail, item_detail in pairs(task_detail_data) do
			if item_detail.day == day and tonumber(key_cfg) == key_detail then
				table.merge(item_temp, item_cfg)
				table.merge(item_temp, item_detail)
				item_temp.quest_id = key_detail
				if item_temp.status == 2 then
					item_temp.status = -1
				end
				table.insert(detail_data, item_temp)
				break
			end
		end
	end

	table.sort(detail_data, function(item1, item2)
		return item1.status > item2.status
	end)


	return detail_data
end

--点花灯积分
function M:getShowScore()
	local lantern_festival = ConfigManager:getCfgByName("lantern_festival")
	return lantern_festival[self.m_version].score or 100
end

--判断是否抽取过奖励
function M:isHasReward(id)
	for i, v in pairs(self.m_data.recv_list) do
		if v == id then
			return true
		end
	end
	return false
end

--判断是否抽取过全部奖励
function M:isCompleteReward()
	if self.m_lantern_reward_cfg[self.m_version] then
		for i, v in pairs(self.m_lantern_reward_cfg[self.m_version]) do
			if not self:isHasReward(i) then
				return true
			end
		end
	end
	return false
end

return M
