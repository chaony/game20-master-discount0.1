local M = class("BTokenLevelUpPoppModel", LikeOO.OODataBase)

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
			for k,v in pairs(m_cfg.fee_incentives) do
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
			for k,v in pairs(m_cfg.free_reward) do
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
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			return true
		end
	end	
	return false
end

function M:getWarTable()
	if self.m_token_id == 80 then
		return ConfigManager:getCfgByName("royal_reward")
	elseif self.m_token_id == 109 then
		return ConfigManager:getCfgByName("warrior_reward")
	elseif self.m_token_id == 452 then
		return ConfigManager:getCfgByName("hero_isle_reward")
	end 
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