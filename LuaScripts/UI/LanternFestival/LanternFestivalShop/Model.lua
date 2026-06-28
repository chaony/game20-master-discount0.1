local M = class("LanternFestivalShopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.is_tokens = self.m_params.is_token
	if self.is_tokens then
		self:getData("active_lantern_index")
	else
		self:getData()
	end
end

function M:onEnter()
	self.m_lantern_clothes_id = 1
	self.m_lantern_festival_cfg = ConfigManager:getCfgByName("lantern_festival") or {}
	self.m_version = self.m_params.version
	self.m_gifts_data = self.m_params.gifts or {}
	self.m_clothes_gifts_data = self.m_params.clothes_gifts or {}
	self.m_end_ts = self.m_params.gift_end_ts or 0
	if self.is_tokens then
		self:initData(self.m_data)
	end
	self.m_clothes_cfg = self:get_lantern_clothes()
	self:dayCompute()
	self.m_help_id = self:getHelpDes()
end

function M:getHelpDes()
	if self.m_lantern_festival_cfg[self.m_version] then
		return self.m_lantern_festival_cfg[self.m_version].des
	end
	return "get des id from lantern_festival failed"
end

function M:initData(response)
	if response then
		self.m_version = response.version
		self:dayCompute()
		self.m_clothes_cfg = self:get_lantern_clothes()
		self.m_gifts_data = response.gifts or {}
		self.m_clothes_gifts_data = response.clothes_gifts or {}
		self.m_end_ts = response.gift_end_ts or 0
	end
end

function M:dayCompute()
	local active = UserDataManager:getActivesRechargeDataByOpenId(275)
	if active then
		local start_ts = active.start_ts
		self.m_day = GameUtil:getActityOpenDayCount(start_ts)
	end
end

--阶梯礼包配置数据
function M:get_lantern_clothes()
	local gift_value_tab = ConfigManager:getCfgByName("lantern_clothes")
	if next(gift_value_tab) ~= nil then
		return gift_value_tab[self.m_version][self.m_lantern_clothes_id]
	end
	return nil
end


--阶梯礼包配置数据
function M:get_ladderGiftData()
	local gift_value_tab = ConfigManager:getCfgByName("lantern_gift")
	local version_tab = gift_value_tab[self.m_gifts_data.version][self.m_day] or {}
	local new_tab = {}
	local giftData = self.m_gifts_data.data or {}
	for index, data in pairs(giftData) do
		index = tonumber(index)
		local xlsxSeatGiftDatas = version_tab[index] or {}
		local cid = data.cid
		local curGiftData = xlsxSeatGiftDatas[cid]
		if curGiftData then
			-- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
			local isCanBuy = true
			cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, data)
			-- <=0, 表示第一个礼包，第一个礼包不符合购买需求则隐藏礼包
			if cid > 0 then
				curGiftData = xlsxSeatGiftDatas[cid]
				table.insert(new_tab,{
					xlsxData = curGiftData,
					cid = data.cid,
					buyCount = data.times,
					isCanBuy = isCanBuy,
					index = index,
				})
			end
		end
	end

	table.sort(new_tab,function(itemData1,itemData2)
		local canBuyIndex1 = itemData1.isCanBuy and 1 or 2
		local canBuyIndex2 = itemData2.isCanBuy and 1 or 2
		if canBuyIndex1 ~= canBuyIndex2 then
			return canBuyIndex1 < canBuyIndex2
		else
			return itemData1.index < itemData2.index
		end
	end)

	return new_tab
end


-- 修改阶梯礼包数据，判断规则：限购次数，VIP等级，累计金额，章节限制，章节范围限制
function M:trimEveryDayLadderBagData(curGiftData, data)
	local cid = data.cid
	local isCanBuy = true
	if (curGiftData.time_limit > 0) then
		isCanBuy = data.times < curGiftData.time_limit
	end
	local userDataManager = UserDataManager
	local curVipLevel = userDataManager.user_data:getUserStatusDataByKey("vip")
	if isCanBuy and (curGiftData.vip > 0) then
		isCanBuy = curVipLevel >= curGiftData.vip
	end
	if isCanBuy and (curGiftData.add_recharge > 0) then
		isCanBuy = userDataManager.charge_sum >= curGiftData.add_recharge
	end
	local curChapterId = userDataManager:getCurStage()
	if isCanBuy and (curGiftData.stage > 0) then
		isCanBuy = curChapterId >= curGiftData.stage
	end
	if isCanBuy and curGiftData.stage_limit and #curGiftData.stage_limit > 0 then
		local chapterLimit = curGiftData.stage_limit
		isCanBuy = curChapterId >= chapterLimit[1] and curChapterId <= chapterLimit[2]
	end
	cid = isCanBuy and cid or (cid - 1)
	-- 1. 只有一层，买完后要显示已售罄
	-- 2. 只有一层，不符合条件要隐藏
	if cid <= 0 then
		cid = (data.times <= 0) and 0 or 1  --times 买没买过
	end
	return cid, isCanBuy
end


function M:checkActiveIsEnd(open_id)
	if self.m_end_ts == 0 or self.m_end_ts < UserDataManager:getServerTime() then
		return false
	end
	return true
end

--皮肤礼包是否有购买次数
function M:getClothesGift()
	for k,v in pairs(self.m_clothes_gifts_data) do
		if tonumber(k) == self.m_lantern_clothes_id then
			return false
		end
	end
	return true
end


function M:getShowSkip()
	if self.m_clothes_cfg then
		local reward_data = RewardUtil:getProcessRewardData(self.m_clothes_cfg.reward[1]) 
		if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
			return reward_data.item_cfg.hero_spine,reward_data
		elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
			return reward_data.item_cfg.hero_spine,reward_data
		end
	end
	return "hero_0602_SkeletonData",nil
end

function M:getRaceByCId(cid)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	return GlobalConfig.TYPE_HERO_RACE[hero_cfg.race] or  GlobalConfig.TYPE_HERO_RACE[1]
end

function M:getEndTs()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	local end_times = next_fresh_time + 24 * 3600
	return end_times
end

--阶梯礼包配置数据
function M:get_lantern_festival()
	local gift_value_tab = ConfigManager:getCfgByName("lantern_festival")
	if next(gift_value_tab) ~= nil then
		return gift_value_tab[self.m_version]
	end
	return nil
end

return M
