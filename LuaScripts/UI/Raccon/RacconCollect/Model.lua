local M = class("RacconCollectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.open_id = 344
	self.m_version = self.m_params.version or 1
	self:getData("common_quest_index",{open_id = self.open_id, vsn = self.m_version })
end

function M:setTabIndex(tab_index)
	self.m_cur_tab_index = tab_index
end


function M:onEnter()
	self.m_red_flag1 = false
	self.m_red_flag2 = false
	self.m_cur_tab_index = 1
	self.m_task_detail_cfg_data = {}
	self:updateData()
	self.raccon_active_cfg = self:getRacconActiveCfg()
	-- self.m_score = self.m_params.score or 0 --积分
	local day = self:getActityOpenDayCount()
	if day <= 0 then
		day = 1
	elseif day > 14 then
		day = 14
	end
	self.m_current_day = day --当前天数
	self.m_current_day_update = self.m_current_day
	local raccon_card = ConfigManager:getCfgByName("raccon_card") or {}
	local cur_card_cfg = raccon_card[self.open_id] or {}
	self.m_cur_vsn_card_cfg = cur_card_cfg[self.m_version] or {}
	self.m_background =  ""
	self.main_gacha_cfg = self:getMainGachaCfg()
	self:updateRewardBoxData()
end

function M:getCardCount()
	local count = self.m_cur_vsn_card_cfg.card ~= nil and #self.m_cur_vsn_card_cfg.card or 0
	return count
end

function M:getCardData(index)
	if self.m_cur_vsn_card_cfg then
		local card = self.m_cur_vsn_card_cfg.card or {}
		local card_reward = card[index] or {}
		local card_img = self.m_cur_vsn_card_cfg.card_msg or { }
		local card_name = self.m_cur_vsn_card_cfg.card_name or { }
		local card_path = card_img[index] or ""
		local card_namt_des = card_name[index] or ""
		return card_reward, card_path, card_namt_des
	end
	return nil , nil
end

function M:getMainGachaCfg()
	local main_gacha_tab = ConfigManager:getCfgByName("main_gacha")
	return main_gacha_tab[self.m_version]
end


function M:getMainCfgVByK(key_name)
	local raccon_main_cfg = ConfigManager:getCfgByName("raccon_main") or {}
	local cur_vsn_cfg = raccon_main_cfg[self.m_version] or {}
	local value = cur_vsn_cfg[key_name]
	return value
end

function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end
	self.m_score = self.m_data.score or 0 --积分
	self.m_task_detail_cfg_data = self.m_data.quests
	self.m_score_done = self.m_data.score_done or {} --已领取的积分id
	self.m_task_quest = self.m_data.quests or {}
end

-- 活动开启了几天
function M:getActityOpenDayCount()
	local serverTimer = UserDataManager:getServerTime()
	local activityData = UserDataManager:getActivesDataByOpenId(self.open_id)
	if activityData then
		local startTimer = activityData.start_ts
		local openDayCount = GameUtil:NumberOfDaysIntervalDay(startTimer,serverTimer)
		openDayCount = math.floor(openDayCount)
		openDayCount = openDayCount <= 0 and 1 or openDayCount
		return openDayCount
	end
	return 999
end

function M:getVersion()
	return self.m_version
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:setCurrentDayUpdate(day)
	if day > self.m_current_day then
		day = self.m_current_day
	end
	self.m_current_day_update = day
end

function M:getCurrentDayUpdate()
	return self.m_current_day_update
end

function M:setTaskDetailCfgData(data)
	self.m_task_detail_cfg_data = data or {}
end

--右上，传记详情
function M:getZhuanjiDetailName()
	if self.m_current_day_update > 0 and self.m_current_day_update < 8 then
		local lock_time = GameUtil:numberToChineseString(self.m_current_day_update) -- 数字转大写
		return Language:getTextByKey("dragonsword_text_0014",lock_time)
	end
	return ""
end

function M:getZhuanjiDetailTitle()
	local story_tab = ConfigManager:getCfgByName("raccon_active_story") or {}
	local story_data = story_tab[self.open_id][self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.name
	end
	return ""
end

function M:getZhuanjiDetailContent()
	local story_tab = ConfigManager:getCfgByName("raccon_active_story") or {}
	local story_data = story_tab[self.open_id][self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.story
	end
	return ""
end

function M:getZhuanjiDetailData(day)
	self.m_red_flag1 = false
	self.m_red_flag2 = false
	day = day or self.m_current_day_update
	local detail_data, detail_data2 = {}, {}
	local task_detail_tab = ConfigManager:getCfgByName("lianliankan_quest") or {}
	local task_detail_data = task_detail_tab[self.open_id][self.m_version] or {}
	local item_temp, item_temp2
	for key_cfg, item_cfg in pairs(self.m_task_detail_cfg_data) do
		item_temp = {}
		for key_detail, item_detail in pairs(task_detail_data) do
			if tonumber(key_cfg) == key_detail then
				table.merge(item_temp, item_cfg)
				table.merge(item_temp, item_detail)
				item_temp.quest_id = key_detail
				if item_temp.status == 2 then
					item_temp.status = -1
				end
				if item_detail.sort == 1 and item_detail.day == day then
					if item_temp.status == 1 then
						self.m_red_flag1 = true
					end
					table.insert(detail_data, item_temp)
				else
					if item_temp.status == 1 then
						self.m_red_flag2 = true
					end
					table.insert(detail_data2, item_temp)
				end
				break
			end
		end
	end
	table.sort(detail_data, function(item1, item2)
		if item1.status == item2.status then
			return item1.quest_id < item2.quest_id
		else
			return item1.status > item2.status
		end
	end)
	table.sort(detail_data2, function(item1, item2)
		if item1.status == item2.status then
			return item1.quest_id < item2.quest_id
		else
			return item1.status > item2.status
		end
	end)
	if self.m_cur_tab_index == 1 then
		return detail_data
	else
		return detail_data2
	end
end

--右下，传记
function M:getZhuanjiData()
	local raccon_active_story_tab = ConfigManager:getCfgByName("raccon_active_story")[self.open_id] or {}
	local evil_shadow_reward = raccon_active_story_tab[self.m_version] or {}
	local day_data = {}
	for i = 1, #evil_shadow_reward do
		local one_day_data = {}
		one_day_data.red_point = self:isZhuanjiItemHasRewardToGet(i)
		local lock_time = GameUtil:numberToChineseString(i) -- 数字转大写
		one_day_data.name_day = Language:getTextByKey("active_current_str_0002",lock_time)
		if i > self.m_current_day then --真实的当前天数
			one_day_data.status = 0 --未开启
			one_day_data.red_point = false
		elseif i == self.m_current_day_update then --点击传记的下标
			one_day_data.status = 2 --当前
		else
			if self:isZhuanjiItemComplete(i) then
				one_day_data.status = 1	--已完成
			else
				one_day_data.status = 3 --已开启，未完成
			end
		end
		one_day_data.day = i
		table.insert(day_data,one_day_data)
	end
	return day_data
end

function M:isZhuanjiItemComplete(day)
	local task_data = self:getZhuanjiDetailData(day) or {}
	for _, item in ipairs(task_data) do
		if item.status == 0 or item.status == 1 then
			return false
		end
	end
	return true
end

function M:isZhuanjiItemHasRewardToGet(day)
	local task_data = self:getZhuanjiDetailData(day) or {}
	for _, item in ipairs(task_data) do
		if item.status == 1 then
			return true
		end
	end
	return false
end

--左下，宝箱
function M:updateRewardBoxDataScore(score)
	self.m_score = score
end

function M:updateRewardBoxDataScoreDone(data)
	self.m_score_done = data or {}
end

--里程奖励
function M:updateRewardBoxData()
	local show_data = {}
	local active_reward_tab = ConfigManager:getCfgByName("raccon_active_reward")
	local open_tab = active_reward_tab[self.open_id] or {}
	local evil_shadow_reward = open_tab[self.m_version] or {}
	for k,v in pairs(evil_shadow_reward) do
		local score = v.score or 0
		local status = 0
		if table.keyof(self.m_score_done, k) then
			status = -1-- 已领取
		else
			if self.m_score >= score then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = k, cfg = v, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.score < data2.cfg.score
	end)
	self.m_arena_reward_week_data = show_data
end

function M:getRewardBoxData()
	return self.m_arena_reward_week_data, self.m_score
end

--获取里程奖励提示
function M:getRewardInfo()
	local active_reward_tab = ConfigManager:getCfgByName("raccon_active_reward")[self.open_id] or {}
	local evil_shadow_reward = active_reward_tab[self.m_version] or {}
	local need_data = RewardUtil:getProcessRewardData(evil_shadow_reward[#evil_shadow_reward].reward[1])
	local hero_name = need_data.item_cfg.class or ""
	return evil_shadow_reward[#evil_shadow_reward].score, Language:getTextByKey(hero_name)
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	--return event[self.m_data.version or 1] or {}
	return event[self.m_version] or {}
end

--活跃任务信息
function M:getRacconActiveCfg()
	local raccon_active = ConfigManager:getCfgByName("raccon_active")
	local normal_cfg = raccon_active[self.open_id] or {}
	local vsn_cfg = normal_cfg[self.m_version]
	if vsn_cfg then
		return vsn_cfg
	end
	return nil
end

return M
