local M = class("QiXiExchangeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.open_id = self.m_params.open_id or 377
	local m_active_data = self:getActiveData()
	self.m_version = m_active_data.version or 1
	local param = {}
	param.open_id = self.open_id
	param.vsn = self.m_version
	self:getData("active_common_exchange_index",param)
end

function M:onEnter()
	self.m_exchange_done_data = self.m_data.exchange or {}
end

function M:getVersion()
	return self.m_version
end

function M:updateExchangeData(data)
	table.merge(self.m_exchange_done_data, data)
end

function M:getExchangeData()
	return self.m_exchange_done_data
end

function M:getExchangeShopData()
	local tempData = {}
	local curVip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0  --vip等级
	local curSeason = UserDataManager:getCurSeason() or 0 --当前赛季
	local exchange_tab = ConfigManager:getCfgByName("tongyong_exchange")
	local exchange_version_data = exchange_tab[self.open_id][self.m_version]
	for id, itemData in pairs(exchange_version_data) do
		local curExchangeCount = self.m_exchange_done_data[tostring(id)] or 0
		local awardData = RewardUtil:getProcessRewardData(itemData.need_reward[1])
		if (curVip >= itemData.vip) and (curSeason >= itemData.season) then
			if (itemData.season1 < 0) or (itemData.season1 == curSeason) then
				table.insert(tempData, {
					id = id,
					xlsxData = itemData,
					userNum = awardData.user_num,
					needNum = awardData.data_num,
					curExchangeCount = curExchangeCount,
					allCount = itemData.times,
				})
			end
		end
	end
	table.sort(tempData, function(itemData1, itemData2)
		local sortIndex1 = ((itemData1.curExchangeCount >= itemData1.allCount)) and 1 or -1
		local sortIndex2 = ((itemData2.curExchangeCount >= itemData2.allCount)) and 1 or -1
		--local exchangeCount1 = itemData1.needNum > itemData1.userNum and 0 or 1
		--local exchangeCount2 = itemData2.needNum > itemData2.userNum and 0 or 1
		if sortIndex1 ~= sortIndex2 then
			return sortIndex1 < sortIndex2
		else
			--if exchangeCount1 ~= exchangeCount2 then
			--	return itemData1.id > itemData2.id
			--end
			return itemData1.id < itemData2.id
		end
	end)
	return tempData
end

--获取剩余购买次数
function M:getEatExchangeData(id)
	for i, v in pairs(self.m_exchange_done_data) do
		if i == id then
			return v
		end
	end
	return 0
end

--获取活动数据
function M:getActiveData()
	local activity_info = UserDataManager:getActivesDataByOpenId(self.open_id)
	if activity_info then
		local active_tab = ConfigManager:getCfgByName("active")
		return active_tab[activity_info.id]
	else
		activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.open_id)
		if activity_info then
			local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
			return active_recharge_tab[activity_info.id]
		end
	end
end

return M
