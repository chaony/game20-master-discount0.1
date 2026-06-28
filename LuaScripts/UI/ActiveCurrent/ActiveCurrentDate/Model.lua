local M = class("ActiveCurrentDateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.m_score = self.m_params.score or 0
	self.m_score_done = self.m_params.score_done or {}
	self.m_current_day = self.m_params.current_day or 1
	self.m_current_day_update = self.m_current_day
	self.m_task_detail_cfg_data = self.m_params.task_detail_data
	self.m_active_data = self.m_params.active_data or {}
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_background = self.m_params.background
	self:updateRewardBoxData()
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
	local story_tab = ConfigManager:getCfgByName("hero_event_story") or {}
	local story_data = story_tab[self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.name
	end
	return ""
end

function M:getZhuanjiDetailContent()
	local story_tab = ConfigManager:getCfgByName("hero_event_story") or {}
	local story_data = story_tab[self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.story
	end
	return ""
end

function M:getZhuanjiDetailData(day)
	day = day or self.m_current_day_update 
	local detail_data = {}
	local task_detail_tab = ConfigManager:getCfgByName("hero_event_quest") or {}
	local task_detail_data = task_detail_tab[self.m_version] or {}
	local item_temp
	for key_cfg, item_cfg in pairs(self.m_task_detail_cfg_data) do
		item_temp = {}
		for key_detail, item_detail in pairs(task_detail_data) do
			if item_detail.day == day and tonumber(key_cfg) == key_detail then
				item_temp = table.copy(item_detail)
				table.merge(item_temp, item_cfg)
				item_temp.quest_id = key_detail
				if item_temp.status == 2 then
					item_temp.status = -1
				end
				table.insert(detail_data, item_temp)
				break
			end
		end
	end
	
	table.sort(detail_data, function(item1, item2)
		return item1.status > item2.status
	end)
	
	
	return detail_data
end

--右下，传记
function M:getZhuanjiData()
	local event_story = ConfigManager:getCfgByName("hero_event_story")[self.m_version]
	local day_data = {}
	for i = 1, #event_story do
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
	local evil_shadow_reward = ConfigManager:getCfgByName("hero_event_reward")[self.m_version] or {}
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
	local evil_shadow_reward = ConfigManager:getCfgByName("hero_event_reward")[self.m_version] or {}
	local need_data = RewardUtil:getProcessRewardData(evil_shadow_reward[#evil_shadow_reward].reward[1])
	local hero_name = need_data.item_cfg.class
	return evil_shadow_reward[#evil_shadow_reward].score,Language:getTextByKey(hero_name)
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	--return event[self.m_data.version or 1] or {}
	return event[self.m_version] or {}
end

return M
