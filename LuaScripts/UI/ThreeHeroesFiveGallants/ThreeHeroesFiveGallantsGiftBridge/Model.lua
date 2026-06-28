local M = class("ThreeHeroesFiveGallantsGiftBridgeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.open_id = self.m_params.open_id or 389
	self.m_version = self.m_params.version or 1
	self.m_active_data = self:getActiveData()
	--if self.m_active_data ~= nil then
	--	self.m_version = self.m_active_data.version or 1
	--else
	--	self.m_version = 1
	--end
	self.m_hero_gift_times = self.m_params.hero_gift_times or 0 --是否购买英雄
	self:getData("active_common_gift_index",{open_id = self.open_id, vsn = self.m_version})
end

function M:onEnter()
	self.cur_page = "1" -- 页签本功能只有1
	self.is_tokens = self.m_params.is_token
	self.m_end_ts = GameUtil:stringToTimesTamp(self.m_active_data.end_time)
	self.m_show_data = {}
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	else
		self.is_tokens = false
	end
	self:initHeroSkinCfg()
	self:initData(self.m_data)
end

function M:netData(data, tag)
	table.merge(self.m_data, data or {})
	self:initData(self.m_data)
end

function M:initData(response)
	if response then
		self.m_gifts_data = response.gifts_data or {}
		self.m_day = response.config_day[self.cur_page] or 1
		self.m_clothes_gifts = response.clothes_gifts or {}
	end
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:getVersion()
	return self.m_version
end

function M:canGiftBagBeBuy(gift_id)
	for _, gift_item in pairs(self.m_gift_data) do
		if gift_item.gift_id == gift_id then
			if gift_item.history then
				return gift_item.time_limit < #gift_item.history
			end
		end
	end
	return true
end

function M:updateGiftDataFree(data)
	self.m_gift_data = data or {}
	self:getGiftShowData()
end

function M:updateGiftData(callback)
	local function netCallback(response)
		self:initData(response)
		self:getGiftShowData()
		if callback then
			callback()
		end
	end
	self:getNetData("active_common_gift_index", {open_id = self.open_id, vsn = self.m_version}, netCallback)
end

--获取礼包展示数据
function M:getGiftShowData()
	local gift_value_tab = ConfigManager:getCfgByName("tongyong_gift")
	local version_tab = gift_value_tab[self.open_id][self.m_version][tonumber(self.cur_page)] or {}
	local new_tab = {}
	local giftData = self.m_gifts_data[self.cur_page] or {}
	for index, data in pairs(giftData) do
		index = tonumber(index)
		local xlsxSeatGiftDatas = version_tab[self.m_day][index] or {}
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

--获取展示数据
function M:getGiftData(gift_id)
	local evil_shadow_gift_tab = ConfigManager:getCfgByName("hero_event_gift")[self.m_version] or {}
	for i, v in pairs(evil_shadow_gift_tab) do
		if i == gift_id then
			return v
		end
	end
	return {}
end

function M:getShowData()
	return self.m_show_data or {}
end


--获取活动数据
function M:getActiveData()
	local active_tab = ConfigManager:getCfgByName("active_recharge")
	for i, v in pairs(active_tab) do
		if v.open_id == self.open_id and v.version == self.m_version then
			return v
		end
	end
	return nil
end

----数据初始化-英雄皮肤/宝箱
function M:initHeroSkinCfg()
	local clothes_tab = ConfigManager:getCfgByName("tongyong_hero_gift")[self.open_id] or {}
	local clothes_version_tab = clothes_tab[self.m_version] or {}
	self.m_hero_skin_data = clothes_version_tab[1] or {}
end

--获取礼包购买状态
function M:setGiftTimes(gift_id)
	for i, v in pairs(self.m_data.gifts_data[self.cur_page]) do
		if tonumber(i) == gift_id then
			return v.times
		end
	end
	return 0
end

--获取皮肤购买次数
function M:getClothesGift()
	return self.m_data.clothes_gifts[self.cur_page] or 0
end


return M
