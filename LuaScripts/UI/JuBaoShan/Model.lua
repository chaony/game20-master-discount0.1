local M = class("JuBaoShanModel", LikeOO.OODataBase)


function M:onCreate()
	M.super.onCreate(self)
	self:getData("richman_index", nil, nil, nil)
end

function M:onEnter()
	UserDataManager:setRichMan(self.m_data.quests);
	self:updateServerData();
end


function M:updateServerData()
	--服务器返回数据 self.m_data
	--作弊筛子道具id
	self.zuobiItemId = ConfigManager:getCommonValueById(414);
	self.zuobiItemData = UserDataManager.item_data:getItemDataById(self.zuobiItemId)
	--购买次数
	self.m_buy_times = self.m_data.buy_times;
	--聚宝山结束时间
	self.m_time = self.m_data.end_time;
	--礼包是否开启
	self.m_gift_open = self.m_data.gift_open;
	--格子奖励
	self.m_cell_lv_gift = self.m_data.cell_lv_gift
	--当前的vip等级
	self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	--vip配置
	self.m_vip_config = ConfigManager:getCfgByName("vip")[self.m_vip]
	--消耗配置
	local renovate_config = ConfigManager:getCfgByName("renovate");
	self.m_cost_config = renovate_config[16];
	--行脚商
	self.race_shop_type = self.m_data.race_shop_type;
	--聚宝上跑的圈数
	self.cycle = self.m_data.cycle;
	self:refreshQuest();
	self:buildData();
	--版本号
	self.m_version = self.m_data.version;
	-- 自动派遣
	self.m_autoDispatch = false;
	-- 连续投掷
	self.m_seriesThrow = false;
end

function M:modifyAutoDispatch(autoDispatch)
	self.m_autoDispatch = autoDispatch
end

function M:modifySeriesThrow(seriesThrow)
	self.m_seriesThrow = seriesThrow
end

function M:getGift( buildingId, lv )
	local building = self.m_cell_lv_gift[tostring(buildingId)]
	if building ~= nil then
		return building[tostring(lv)]
	end
	return nil;
end


function M:refreshQuest()
	self.quest = self.m_data.quests[tostring(104)]
	local quest_value = 0;
	if self.quest ~= nil then
		quest_value = self.quest.value
	end
	local quest_credit_dice = ConfigManager:getCfgByName("credit_dice")[104]
	local max_quest = nil;
	local min_quest_value = 99999;
	for i, v in pairs(quest_credit_dice) do
		max_quest = v;
		if quest_value < v.target_value and min_quest_value > v.target_value then
			self.cur_quest = v;
			min_quest_value = v.target_value;
		end
	end
	if self.cur_quest == nil then
		self.cur_quest = max_quest;
	end
end


function M:getCurQuest()
	return self.cur_quest;
end

--获取可领取奖励
function M:HasCanUseReward()
	local quest_data = UserDataManager:getChapterQuestSpecialData(104)
	for i, v in pairs(quest_data) do
		if v.status == 2 then
			return true;
		end
	end
	return false;
end


--构建数据
function M:buildData()
	self.buildingData = {}
	self.minTriggerTimeCell = nil;
	self.minTriggerTime = 999;
	self.m_allCells = SceneManager:getCurSceneModel().allCellPools;
	if self.m_allCells ~= nil then
		for i, v in pairs(self.m_allCells) do
			--类型是建筑的
			if v.cell_type == 4 then
				if v.lv >= 1 then
					if v.trigger_time ~= nil then
						if self.minTriggerTime > v.trigger_time then
							self.minTriggerTime = v.trigger_time
							self.minTriggerTimeCell = v;
						end
					end
					table.insert(self.buildingData, v)
				end
			end
		end
	end
	--Logger.logError(self.minTriggerTimeCell," 最小触发时间的格子 ")
	return self.buildingData, self.minTriggerTimeCell;
end


--剩余购买次数
function M:getRemainBuyTimes()
	return self.m_vip_config.dice_buy_limit - self.m_buy_times;
end


function M:refreshItemData()
	self.zuobiItemData = UserDataManager.item_data:getItemDataById(self.zuobiItemId)
end


function M:refreshData( data )
	self.m_data.times = data.times;
	self.m_data.quests = data.quests;
end

return M
