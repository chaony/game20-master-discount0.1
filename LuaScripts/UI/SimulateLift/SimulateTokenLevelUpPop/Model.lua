local M = class("SimulateTokenLevelUpPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self:getData()
end

function M:onEnter()
	self.m_token_id = self.m_params.token_id
	self.m_token_lv = self.m_params.token_lv or 1
	self.m_lv = self.m_params.lv or 1
	self.m_callback = self.m_params.callback
	self.m_buy_lv = self.m_params.buy_lv or 1
	self.m_vsn = self.m_params.vsn or 1
	self.m_season = self.m_params.season or 0
	local war_table = self:getWarTable()
	local cur_table = table.copy(war_table[self.m_token_lv])
	self.max_lv = #cur_table
end

function M:updateData(data)
	self.m_token_lv = self.m_params.vm_lv or 1
	self.m_lv = self.m_params.lv or 1
	self.m_callback = self.m_params.callback
	self.m_buy_lv = self.m_params.buy_lv or 1
	self.m_vsn = self.m_params.vsn or 1
	local war_table = self:getWarTable()
	local cur_table = table.copy(war_table[self.m_token_lv])
	self.max_lv = #cur_table
end

function M:changeBuyNum(bl)
	if bl == true then
		if self.m_buy_lv + self.m_lv >= self.max_lv then
			return
		end
		self.m_buy_lv = self.m_buy_lv + 1
	else
		if self.m_buy_lv == 1 then
			return
		end
		self.m_buy_lv = self.m_buy_lv - 1
	end
end

function M:getCanHaveReward()
	local war_table = self:getWarTable()
	local c_lv = self.m_token_lv > 0 and self.m_token_lv or 1
	local cur_table = war_table[c_lv]
	local rewards = {}
	local add_lv = self.m_buy_lv
	if add_lv + self.m_lv > #cur_table then
		add_lv = #cur_table - self.m_lv
	end
	for i = self.m_lv+1, self.m_lv + add_lv do
		local m_cfg = table.copy(cur_table[i])
		if m_cfg then
			local seasonIndex = self:getNearestSeason(m_cfg.fee_incentives)
			local seasonData = m_cfg.fee_incentives[seasonIndex]
			for k,v in pairs(seasonData) do
				if self:checkInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else
					table.insert( rewards, v)
				end
			end
		end
	end
	return rewards
end

function M:getCanHaveReward2()
	local war_table = self:getWarTable()
	local c_lv = self.m_token_lv > 0 and self.m_token_lv or 1
	local cur_table = war_table[c_lv]
	local rewards = {}
	local add_lv = self.m_buy_lv
	if add_lv + self.m_lv > #cur_table then
		add_lv = #cur_table - self.m_lv
	end
	for i = self.m_lv+1, self.m_lv + add_lv do
		local m_cfg = table.copy(cur_table[i])
		if m_cfg then
			local seasonIndex = self:getNearestSeason(m_cfg.free_reward)
			local seasonData = m_cfg.free_reward[seasonIndex]
			for k,v in pairs(seasonData) do
				if self:checkInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else
					table.insert( rewards, v)
				end
			end
		end
	end
	return rewards
end

function M:checkInRewards(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			v[3] = v[3] + data[3]
		end
	end
	return rewards
end

function M:checkInTab(rewards, data)
	if rewards and table.nums(rewards) > 0 then
		for k,v in pairs(rewards) do
			if v[1] == data[1] and v[2] == data[2] then
				return true
			end
		end
	end
	return false
end

function M:getWarTable()
	return ConfigManager:getCfgByName("minigame_war_order_reward")
end

function M:getWarCfg()
	local war_table = ConfigManager:getCfgByName("war_order")
	return war_table[self.m_token_id]
end

function M:getNeedMoney()
	local rewards = {}
	local war_table = self:getWarTable()
	local c_lv = self.m_token_lv > 0 and self.m_token_lv or 1
	local cur_table = table.copy(war_table[c_lv])
	local add_lv = self.m_buy_lv
	if add_lv + self.m_lv > #cur_table then
		add_lv = #cur_table - self.m_lv
	end
	for i = self.m_lv+1, self.m_lv + add_lv do
		local m_cfg = cur_table[i]
		if m_cfg then
			--local seasonIndex = self:getNearestSeason(m_cfg.diamond_purchase)
			--local seasonData = m_cfg.diamond_purchase[seasonIndex]
			for k,v in pairs(m_cfg.diamond_purchase) do
				if self:checkInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else
					table.insert(rewards, v)
				end
			end
		end
	end
	if #rewards > 0 then
		return RewardUtil:getProcessRewardData(rewards[1])
	end
	return nil
end

-- 获取策划填的最近的season -- 服务器要求
function M:getNearestSeason(data)
	local tempList = {}
	for serverSeason, itemData in pairs(data) do
		table.insert(tempList, {
			serverSeason = serverSeason,
			itemData = itemData,
		})
	end
	table.sort(tempList, function(itemData1, itemData2) return itemData1.serverSeason < itemData2.serverSeason end)
	local maxItemData = tempList[#tempList]
	local curSeason = 0
	if self.m_season > maxItemData.serverSeason then
		return maxItemData.serverSeason
	else
		for index = 1, #tempList do
			local itemData = tempList[index]
			if itemData.serverSeason == self.m_season then
				return self.m_season
			else
				if self.m_season > itemData.serverSeason then
					curSeason = itemData.serverSeason
				else
					break
				end
			end
		end
		return curSeason
	end
	return 0
end

function M:getRewardId()
	local war_table = self:getWarTable()
	local c_lv = self.m_token_lv > 0 and self.m_token_lv or 1
	local cur_table = table.copy(war_table[c_lv])
	local c_cfg = cur_table[self.m_lv+self.m_buy_lv]
	if c_cfg then
		return self.m_lv+self.m_buy_lv
	end
	return nil
end

return M