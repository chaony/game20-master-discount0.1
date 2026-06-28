local M = class("LuckyCharmModel",LikeOO.OODataBase)

function M:onCreate()

	M.super.onCreate(self)
	self:getData()
		

end

function M:onEnter()
	self.m_gift_vsn = self.m_params.gift_vsn
	self.m_gift_buy_log = self.m_params.gift_buy_log
	self.m_active_time = self.m_params.active_time
	self.m_is_token = self.m_params.is_token or false
end

--获取购买次数
function M:hasGift(gift_id)
	return self.m_gift_buy_log[gift_id]
end


--更新服务器数据
function M:updateServerData(serverData)
	
	if serverData and serverData["end"] then
		UserDataManager.active_121_end = true
		static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
		
	end
	
	self.m_gift_buy_log = serverData.gift_buy_log
	self.m_gift_vsn = serverData.gift_vsn
end

--读取数据
function M:getListData()
	local gift_list = {}
	local chest_gift = ConfigManager:getCfgByName("chest_gift")
	local version = self.m_gift_vsn
	local gift = table.copy(chest_gift[version])
	--Logger.logError(gift,"gift")
	if chest_gift[version] then
		for k,v in ipairs(chest_gift[version]) do
			local gift_buy = {}
			gift_buy.cfg = v
			local buy_num = self:hasGift(tostring(k)) or 0
			local times_limit = gift_buy.cfg.times_limit-buy_num
			if  gift_buy.cfg.times_limit <= buy_num then
				gift_buy.status = -1 --已购买
			else
				gift_buy.status = 0 --可购买
			end
			gift_buy.id = k
			gift_buy.buy_num = buy_num
			local stage = self:stageLimit(gift_buy.cfg.stage_limit)
			if stage then
				table.insert(gift_list,gift_buy)
			end
		end
	end
	table.sort(gift_list,function(data1,data2) --排序
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end)
	return gift_list
end

--判断奖励是否可以显示（关卡限制）
function M:stageLimit(stage_limit)
	local CurStage = UserDataManager:getCurStage()
	local stageMin = true
	local stageMax = true
	if stage_limit[1] ~= nil then
		stageMin = CurStage > stage_limit[1]
	end
	if stage_limit[2] ~= nil then
		stageMax = CurStage < stage_limit[2]
	end
	return stageMin and stageMax
end

return M
