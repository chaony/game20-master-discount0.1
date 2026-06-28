local M = class("ActiveCurrentExchangeShopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 0 
	self.m_exchange_done_data = self.m_params.exchange_done_data or {}
	self.m_background = self.m_params.background
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_active_data = self.m_params.active_data or {}
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
	local curVip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local curSeason = UserDataManager:getCurSeason() or 0
	local exchange_tab = ConfigManager:getCfgByName("hero_event_exchange")
	local exchange_version_data = exchange_tab[self.m_version]
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
		local sortIndex1 = ((itemData1.curExchangeCount >= itemData1.allCount) or (itemData1.needNum > itemData1.userNum)) and 1 or -1
		local sortIndex2 = ((itemData2.curExchangeCount >= itemData2.allCount) or (itemData2.needNum > itemData2.userNum)) and 1 or -1
		if sortIndex1 ~= sortIndex2 then
			return sortIndex1 < sortIndex2
		else
			return itemData1.id < itemData2.id
		end
	end)
	return tempData
end

--获取花费id
function M:getCostId()
	local hero_event = ConfigManager:getCfgByName("hero_event")
	return hero_event[self.m_version].item_cost or 0
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	--return event[self.m_data.version or 1] or {}
	return event[self.m_version] or {}
end

return M
