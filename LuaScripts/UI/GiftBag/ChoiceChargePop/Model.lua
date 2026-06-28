local M = class("ChoiceChargePopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	self.m_open_type = self.m_params.open_type or "main" --首页的数据是push_gift，或者活动页，活动页的数据是choice_gifts
	self.m_new_id = self.m_params.new_id --当前新触发的礼包 在最上面
	self.m_is_token = self.m_params.is_token or false
	self.m_select_index = 1
	self.m_charge_index = self:getDefaultChargeIndex()-- 下面的价格页签
	self.m_is_show_charge_lv = false -- 是否展示下面的价格页签
	self.m_callback = self.m_params.callback
	self.m_data_callback = self.m_params.data_callback
	self.m_push_gift = self.m_params.push_gift
	self.m_tag_table = self:getShowLimitTab()
	self.m_choice_gifts = UserDataManager.m_choice_gifts
	self.m_gift_btn = self.m_params.gift_btn
	
	if next(self.m_tag_table) ~= nil then
		local cur_tag = self.m_tag_table[self.m_select_index]
		if cur_tag then
			self.m_gift_id = cur_tag.id
			self.m_gift_cfg = cur_tag.cfg
			local ex_resards = self:getExtraRewards(cur_tag.id)
			--self.m_rewards = table.copy(self.m_gift_cfg.reward)  or {}
			if self.m_gift_cfg.three_charge then
				self.m_is_show_charge_lv = true
				local rewards = self:getChoiceCfgData(self.m_gift_cfg.three_charge, self.m_charge_index, "reward") or {}
				self.m_rewards =  table.copy(rewards)  or {}
			else
				self.m_is_show_charge_lv = false
				self.m_rewards =  table.copy(self.m_gift_cfg.reward)  or {}
			end
			if next(ex_resards) ~= nil then
				if #self.m_rewards >= 1 then
					for i = 1, #ex_resards do
						table.insert(self.m_rewards, i+1, ex_resards[i] )
					end
				else
					for i = 1, #ex_resards do
						table.insert(self.m_rewards, ex_resards[i] )
					end
				end
			end
		end
	end 
end

--设置下面的价格页签
function M:setChargeIndex(charge_index)
	self.m_charge_index = charge_index
end

function M:getDefaultChargeIndex()
	local default_charge_index = 1
	local need_vip = ConfigManager:getCommonValueById(635,-1)
	if self.m_vip >= need_vip and need_vip > -1 then
		default_charge_index = 3
	end
	return default_charge_index
end

function M:initChoiceToPush(choice_gifts_data)-- 将choice_gits的数据转换成
	local temp_push_data = {}
	for i, v in pairs(choice_gifts_data) do
		temp_push_data[i] = v.ets
	end
	return temp_push_data
end

function M:getChoiceCfgData(three_charge_id, charge_index, cfg_key)
	local three_charge = ConfigManager:getCfgByName("three_charge") or {}
	local cur_charge_cfg = {}
	local get_data = nil
	if three_charge[three_charge_id] then
		cur_charge_cfg = three_charge[three_charge_id] or {}
		if charge_index then
			local gifts_data = cur_charge_cfg.gifts_data or {}
			if gifts_data[charge_index] and gifts_data[charge_index][cfg_key] then
				get_data = gifts_data[charge_index][cfg_key]
			end
		else
			if cur_charge_cfg and cur_charge_cfg[cfg_key] then
				get_data = cur_charge_cfg[cfg_key]
			end
		end
		
	end
	return get_data
end

function M:getChoiceNetData(charge_id)
	local sub_ids = {1,2,3}
	--if self.m_choice_gifts and self.m_choice_gifts[tostring(self.m_gift_id)] and self.m_choice_gifts[tostring(self.m_gift_id)]["sub_ids"] then
	--	sub_ids = self.m_choice_gifts[tostring(self.m_gift_id)]["sub_ids"]
	--end
	return sub_ids
end

function M:refreshCurRewardsData()
	if self.m_gift_cfg.three_charge then
		local rewards = self:getChoiceCfgData(self.m_gift_cfg.three_charge, self.m_charge_index, "reward") or {}
		self.m_rewards = table.copy(rewards)  or {}
	else
		self.m_rewards = {}
	end
end

function M:updateSelectData()
	local cur_tag = self.m_tag_table[self.m_select_index]
	self.m_gift_id = cur_tag.id
	self.m_gift_cfg = cur_tag.cfg
	self:setChargeIndex(self:getDefaultChargeIndex())
	if self.m_gift_cfg.three_charge then
		self.m_is_show_charge_lv = true
		local rewards = self:getChoiceCfgData(self.m_gift_cfg.three_charge, self.m_charge_index, "reward") or {}
		self.m_rewards =  table.copy(rewards)  or {}
	else
		self.m_is_show_charge_lv = false
		self.m_rewards =  table.copy(self.m_gift_cfg.reward)  or {}
	end
	local ex_resards = self:getExtraRewards(cur_tag.id)
	if next(ex_resards) ~= nil then
		if #self.m_rewards >= 1 then
			for i = 1, #ex_resards do
				table.insert(self.m_rewards, i+1, ex_resards[i] )
			end
		else
			for i = 1, #ex_resards do
				table.insert(self.m_rewards, ex_resards[i] )
			end
		end
	end
end

function M:getShowLimitTab()
	local push_tab = self:getGiftPushs()
	local new_push_tab = {}
	local gift_tab = ConfigManager:getCfgByName("limit_gift")
	for k,v in pairs(push_tab) do
		if gift_tab[tonumber(k)] then
			local gift_cfg = gift_tab[tonumber(k)] or {}
			local three_charge_id = gift_cfg.three_charge or 0
			local gift_name = self:getChoiceCfgData(three_charge_id, nil, "gift_name") or "gf_str_0007"
			local sort = 0
			if self.m_new_id and tonumber(self.m_new_id) == tonumber(k) then
				sort = 1
			end
			table.insert( new_push_tab, {id = tonumber(k), cfg = gift_tab[tonumber(k)],end_ts = v, gift_name = gift_name, sort = sort})
		end
	end
	local function sortFunc(id_one, id_two)
		if id_one.sort == id_two.sort then
			return id_one.end_ts > id_two.end_ts
		else
			return id_one.sort > id_two.sort
		end
    end
	table.sort(new_push_tab, sortFunc) 
	return new_push_tab
end

function M:getGiftPushById(id)
	local gift_pushs = self:getGiftPushs()
	return gift_pushs[tostring(id)] or 0
end

function M:getGiftPushs()
	if self.m_push_gift then
		return self.m_push_gift
	end
	local push_gifts = self:initChoiceToPush(UserDataManager.m_choice_gifts)  -- 
	return push_gifts
end

function M:getGiftPushTim()
    local gift_tab = self:getGiftPushs()
    return gift_tab[tostring(self.m_gift_id)]
end

function M:getExtraRewards(id)
	return UserDataManager.m_push_gifts_extra[tostring(id)] or {}
end

--获取奖励中的英雄、皮肤、宝箱等
function M:getHeroInReward()
	if self.m_gift_cfg and self.m_gift_cfg.three_charge then
		local hero_id = self:getChoiceCfgData(self.m_gift_cfg.three_charge, nil, "hero_id")
		if hero_id then
			return hero_id
		end
	end
	for k,v in pairs(self.m_rewards) do
		local data = v
		if data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
			return v[2]
		elseif data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
			local cfg = card_hero_cfg[v[2]]
			return cfg.hero_id
		elseif data[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			local itemData = RewardUtil:getProcessRewardData(data)
			GameUtil:updateItemEffect(itemData)
			if itemData.item_cfg.type == 3 and itemData.item_cfg.effect and next(itemData.item_cfg.effect) ~= nil then
				if itemData.item_cfg.effect[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
					return itemData.item_cfg.effect[1][2]
				end
			elseif itemData.item_cfg.type == 20 and itemData.item_effect and next(itemData.item_effect) ~= nil then 	
				if itemData.item_effect[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROS or itemData.item_effect[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
					return itemData.item_effect[1][2]
				end
			end
		elseif data[1] == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
			return v[2]
		end
	end
	return nil
end

return M