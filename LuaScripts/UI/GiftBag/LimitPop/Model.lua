local M = class("LimitPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_select_index = 1
	self.m_callback = self.m_params.callback
	self.m_data_callback = self.m_params.data_callback
	self.m_push_gift = self.m_params.push_gift
	self.m_tag_table = self:getShowLimitTab()
	self.m_is_token = self.m_params.is_token or false
	if next(self.m_tag_table) ~= nil then
		local cur_tag = self.m_tag_table[self.m_select_index]
		if cur_tag then
			self.m_gift_id = cur_tag.id
			self.m_gift_cfg = cur_tag.cfg
			local ex_resards = self:getExtraRewards(cur_tag.id)
			self.m_rewards = table.copy(self.m_gift_cfg.reward)  or {}
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


function M:updateSelectData()
	local cur_tag = self.m_tag_table[self.m_select_index]
	self.m_gift_id = cur_tag.id
	self.m_gift_cfg = cur_tag.cfg
	self.m_rewards =  table.copy(self.m_gift_cfg.reward)  or {} 
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
			table.insert( new_push_tab, {id = tonumber(k), cfg = gift_tab[tonumber(k)],end_ts = v})
		end
	end
	local function sortFunc(id_one, id_two)
		return id_one.end_ts > id_two.end_ts
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
	local push_gifts = UserDataManager.m_limit_push -- UserDataManager.user_data:getUserStatusDataByKey("push_gifts")
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

--获取活动类型
function M:getCurrentActiveMode()
	local common = ConfigManager:getCfgByName("common")
	return common[639].value or 0
end

--获取特殊活动信息
function M:getActiveInfo()
	local common = ConfigManager:getCfgByName("common")
	return common[640].value or {  }
end

--获取spine名称
function M:getSpineName(skin_spine_id)
	local hero_skin = ConfigManager:getCfgByName("hero_skin")
	return hero_skin[skin_spine_id].hero_spine
end

return M