local M = class("WakeUpFundPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("")
end

function M:onEnter()
	self.m_popup_window_cfg = ConfigManager:getCfgByName("popup_window") or {}
	self.m_growth_fund_cfg = ConfigManager:getCfgByName("growth_fund") or {}
	self.m_from_main = self.m_params.from_main or false
	self.m_cur_index = 1
	self.m_pop_flag = self.m_params.pop_flag or {}
	self.m_page_data = self.m_params.page_data or {}
	self.m_page_type = self.m_params.page_type or {}
	--self.m_order_lv = self.m_params.order_lv or 0
	self:getRoyalShowLv()
	self:saveLocalPopFlag()
end

function M:saveLocalPopFlag()
	for i = 1, #self.m_pop_flag do
		local pop_flag = self.m_pop_flag[i]
		RedPointUtil:saveLocalRedPointFreshTime(pop_flag)
	end
end

function M:getCurPageData()
	if self.m_page_data[self.m_cur_index] then
		return self.m_page_data[self.m_cur_index]
	end
	return nil
end

function M:getPageNums()
	local nums = 1
	if #self.m_page_type > 1 then
		nums = #self.m_page_type
	end
	return nums
end

function M:getCurPageType()
	if self.m_page_type[self.m_cur_index] then
		return self.m_page_type[self.m_cur_index]
	end
	return nil
end

function M:getDataDes()
	local cur_page_type = self:getCurPageType()
	local cur_page_data = self:getCurPageData()
	if cur_page_type == "sign_fund" then
		return self:getDayDiff()
	elseif cur_page_type == "war_order" then
		return self.m_order_lv
	elseif cur_page_type == "grow_fund" then
		local _, chapter_tab = self:getGrowFundRewardCfg()	
		return chapter_tab[#chapter_tab] - 1
	end
end

function M:getDayDiff()
	local cur_page_data = self:getCurPageData() or {}
	local tim_ts = cur_page_data.sign_fund and  cur_page_data.sign_fund.start_ts or 0
	local server_ts = UserDataManager:getServerTime()
	local day = GameUtil:NumberOfDaysInterval(tim_ts, server_ts, 0)
	return GameUtil:formatNum(day + 1)
end

function M:getCurCfgId()
	local cur_page_type = self:getCurPageType()
	local cur_page_data = self:getCurPageData()
	local cfg_id = 1
	if cur_page_type == "sign_fund" then
		local opened_lv = cur_page_data.sign_fund.opened_lv
		if opened_lv == 0 then
			cfg_id = 2
		elseif opened_lv == 1 then
			cfg_id = 3
		end
	elseif cur_page_type == "war_order" then
		cfg_id = 1
	elseif cur_page_type == "grow_fund" then
		cfg_id = 4
	end
	return cfg_id
end

function M:getShowReward()
	local cur_page_type = self:getCurPageType()
	local cur_page_data = self:getCurPageData()
	if cur_page_type == "sign_fund" then
		local vsn = cur_page_data.sign_fund.vsn
		local days = self:getDayDiff()
		local opened_lv = cur_page_data.sign_fund.opened_lv
		local data = self:getSignFundRewardCfg(vsn, days, opened_lv)
		return data
	elseif cur_page_type == "war_order" then
		local data = self:getRoyalReward()
		return data
	elseif cur_page_type == "grow_fund" then
		local data = self:getGrowFundRewardCfg()
		return data
	end
	return {}
end

function M:getCurTitlePath()
	local img_path = "a_zljj_biaotijijin"
	local cur_page_type = self:getCurPageType()
	if cur_page_type == "war_order" then
		img_path = "a_zljj_biaoti"
	end
	return img_path
end

function M:getPrice()
	local cur_page_type = self:getCurPageType()
	local cur_page_data = self:getCurPageData()
	local price = 99999
	if cur_page_type == "sign_fund" then
		local opened_lv = cur_page_data.sign_fund.opened_lv
		if opened_lv == 0 then
			price = self:getSignFundCfg(1).price or 99999
		elseif opened_lv == 1 then
			price = self:getSignFundCfg(2).price or 99999
		end
	elseif cur_page_type == "war_order" then
		local war_cfg = self:getWarOrderCfg() or {}
		price = war_cfg.price or 99999
	elseif cur_page_type == "grow_fund" then
		local grow_fund_cfg = self:getGrowthFundCfg() or {}
		price = grow_fund_cfg.price or 99999
	end
	return price
end

--签到基金
function M:getSignFundCfg(index)
	local sign_fund_tab = ConfigManager:getCfgByName("sign_fund")
	return sign_fund_tab[index]
end

--战令表
function M:getWarOrderCfg()
	local war_tab = ConfigManager:getCfgByName("war_order")
	return war_tab[80]
end

--成长基金购买项
function M:getGrowthFundCfg()
	local growth_fund_tab = ConfigManager:getCfgByName("growth_fund")
	return growth_fund_tab[85]
end

--签到基金奖励配置
function M:getSignFundRewardCfg(version, max_day, opened_lv)
	local sig_fund_tab = ConfigManager:getCfgByName("sign_fund_reward")
	local c_version = version or 1
	local version_tab = sig_fund_tab[c_version]
	local new_tab = {}
	for i = 1, max_day do
		local reward = nil
		if opened_lv == 0 then
			reward = version_tab[i].reward_normal
		elseif opened_lv == 1 then
			reward = version_tab[i].reward_high
		end
		self:mergeCfgReward(new_tab, reward)
	end
	return new_tab
end

function M:mergeCfgReward(rewards, add_reward)
	for i,v in ipairs(add_reward) do
		local is_new = true
		for ii,vv in ipairs(rewards) do
			if v[1] == vv[1] and v[2] == vv[2] then
				vv[3] = vv[3] + v[3]
				is_new = false
				break
			end
		end
		if is_new then
			rewards[#rewards + 1] = table.copy(v)
		end
	end
end

function M:getGrowFundRewardCfg()
	local all_tab = ConfigManager:getCfgByName("growth_fund_reward")
	local cur_page_data = self:getCurPageData()
	local fund_quests = cur_page_data.fund_quests or {}
	local fund_reward_tab = all_tab[85]
	local new_tab = {}
	local chapter_tab = {}
	for k,v in pairs(fund_quests) do
		local cfg = fund_reward_tab[tonumber(k)]
		local can_get = tonumber(GameUtil:BitAnd(v.status,1)) or 0  --可领

		if can_get ~= 0 and cfg then
			local reward = cfg.reward
			self:mergeCfgReward(new_tab, reward)
			table.insert(chapter_tab, v.value)
		end
	end
	table.sort(chapter_tab)
	return new_tab, chapter_tab
end

function M:getRoyalCfg()
	local valor_tab = ConfigManager:getCfgByName("royal_reward")
	local cur_page_data = self:getCurPageData()
	if cur_page_data.vm_lv == 0 then
		cur_page_data.vm_lv = 1
	end
	return valor_tab[cur_page_data.vm_lv or 1]
end

function M:getRoyalReward()
	local heroic_tab = ConfigManager:getCfgByName("royal_reward")
	local cur_page_data = self:getCurPageData()
	if cur_page_data.vm_lv == 0 then
		cur_page_data.vm_lv = 1
	end
	local new_tab = {}
	for i = 1, self.m_order_lv do
		local reward = heroic_tab[cur_page_data.vm_lv or 1][i].fee_incentives
		self:mergeCfgReward(new_tab, reward)
	end
	return new_tab
end

function M:getRoyalShowLv()
	local tab = self:getRoyalCfg()
	local c_lv = 1
	local cur_page_data = self:getCurPageData()
	for i = 1, table.nums(tab) do
		local c_cfg = tab[i]
		if cur_page_data.valor_medals and cur_page_data.valor_medals >= c_cfg.condition then
			c_lv = i
		end
	end
	self.m_order_lv = c_lv
end

function M:getUiCfg(key)
	local cfg_id = self:getCurCfgId()
	local cur_cfg = self.m_popup_window_cfg[cfg_id] or {}
	if cur_cfg[key] then
		return cur_cfg[key]
	end
	return nil
end

function M:getChargeId()
	local cur_page_type = self:getCurPageType()
	local cur_page_data = self:getCurPageData()
	local charge_id = 99999
	if cur_page_type == "sign_fund" then
		local opened_lv = cur_page_data.sign_fund.opened_lv
		if opened_lv == 0 then
			charge_id = self:getSignFundCfg(1).charge_id
		elseif opened_lv == 1 then
			charge_id = self:getSignFundCfg(2).charge_id
		end
	elseif cur_page_type == "war_order" then
		local war_cfg = self:getWarOrderCfg() or {}
		charge_id = war_cfg.charge_id
	elseif cur_page_type == "grow_fund" then
		local fund_cfg = self:getGrowthFundCfg()
		charge_id = fund_cfg.charge_id
	end
	return charge_id
end

return M