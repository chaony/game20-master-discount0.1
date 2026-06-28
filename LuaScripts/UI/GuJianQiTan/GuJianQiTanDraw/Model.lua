local M = class("GuJianQiTanDrawModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end
 
function M:onEnter()
	self.m_touch_btn_index = 1
	self.m_main_data = self.m_params.main_data or {}
	self.m_sword_count_done = 0 --已使用铸剑次数
	self.m_sword_count_total = 0 --总的铸剑次数
	self.m_sword_count_cur = 0 --当前铸剑次数
	self.m_sword_sequence = {} --铸剑气泡序列
	self.m_reward_id = 1 --左侧的奖励数据id
	self.m_progress_score = 0 --里程碑积分
	self.m_progress_reward_done = {} --已领取的里程碑奖励
	self:initData()
	
	self.m_sword_data = {
		["btn_moon"] 	= {type = 1, name_key = "gu_jian_qi_tan_str_007"},
		["btn_furnace"] = {type = 2, name_key = "gu_jian_qi_tan_str_008"},
		["btn_ice"] 	= {type = 3, name_key = "gu_jian_qi_tan_str_009"},
		["btn_default"] = {type = 0},
	} 
	self:initSwordData()

	self.m_progress_data = {}
	self:initProgressData()
	
	self:initRewardData()
end

--数据初始化
function M:initData()
	self.m_sword_count_done = self.m_main_data.sword_used_times or 0
	self.m_sword_sequence = self.m_main_data.bubbles or {}
	self.m_reward_id = self.m_main_data.reward_id or 1
	self.m_progress_score = self.m_main_data.score or 0
	self.m_progress_reward_done = self.m_main_data.reward_ids or {}
	self.m_sword_count_total = #self.m_sword_sequence
	self.m_sword_count_cur = self.m_sword_count_done + 1
end

--铸剑
----数据初始化
function M:initSwordData()
	local sword_sign_tab = ConfigManager:getCfgByName("sword_sign") or {}
	for k, v in pairs(self.m_sword_data) do
		for kk, vv in pairs(sword_sign_tab) do
			if v.type == vv.article_type then
				v.id = kk
				v.question = vv.question
				v.right_back = vv.right_back
				v.wrong_back = vv.wrong_back
				break
			end
		end
	end
end

function M:checkSwordForge(btn_key)
	return self.m_sword_data[btn_key].id, self.m_sword_count_cur <= self.m_sword_count_total
end

function M:getSwordCountCur()
	return self.m_sword_count_cur
end

function M:getContentWord()
	local sword_id = self.m_sword_sequence[self.m_sword_count_cur]
	if sword_id then
		for k, v in pairs(self.m_sword_data) do
			if sword_id == v.id then
				return v.question or ""
			end
		end
	else
		return self.m_sword_data["btn_default"].question or ""
	end
	return ""
end

function M:getResultTipWord(btn_key, result)
	local sword_item = self.m_sword_data[btn_key] or {}
	if result == true then
		return sword_item.right_back
	else
		return sword_item.wrong_back
	end
end

function M:getSwordForgeCount()
	return self.m_sword_count_total, self.m_sword_count_done
end

--里程碑
function M:initProgressData()
	self.m_progress_data = {}
	
	local sword_sign_jindu_tab = ConfigManager:getCfgByName("sword_sign_reward") or {}
	local sword_sign_jindu_tab_cur = sword_sign_jindu_tab[self.m_reward_id] or {}
	local score_reward = sword_sign_jindu_tab_cur.reward_score or {}
	local score_reward_group = sword_sign_jindu_tab_cur.reward_score_group or {}

	local status = 0
	for k, v in pairs(score_reward) do
		status = 0	--未完成
		if v <= self.m_progress_score then
			status = 1	--可领取
		end
		for kk, vv in pairs(self.m_progress_reward_done) do
			if v == vv then
				status = 2 --已领取
				break
			end
		end
		table.insert(self.m_progress_data, {score = v, reward = score_reward_group[k] or {}, status = status})
	end
end

function M:updateData(data)
	table.merge(self.m_main_data, data)
	self:initData()
	self:initSwordData()
	self:initProgressData()
end

function M:getProgressData()
	return self.m_progress_data, self.m_progress_score
end

----当前进度/总进度
function M:getProgressTextData()
	local max_index = #self.m_progress_data
	local total = self.m_progress_data[max_index].score
	return total, (self.m_progress_score <= total) and self.m_progress_score or total
end

--奖励展示
function M:initRewardData()
	local sword_sign_jindu_tab = ConfigManager:getCfgByName("sword_sign_reward") or {}
	local sword_sign_jindu_tab_cur = sword_sign_jindu_tab[self.m_reward_id] or {}
	self.m_reward_data = sword_sign_jindu_tab_cur.reward_group or {}
end

function M:getRewardData()
	return self.m_reward_data
end

--活动
function M:getActivityDate()
	local activity_data = UserDataManager:getActivesDataByOpenId(280)
	local time_start = TimeUtil.gmTime(activity_data.start_ts or 0)
	local time_start_str = Language:getTextByKey("gu_jian_qi_tan_str_024", time_start.month, time_start.day)
	local time_end = TimeUtil.gmTime(activity_data.end_ts or 0)
	local time_end_str = Language:getTextByKey("gu_jian_qi_tan_str_024", time_end.month, time_end.day)
	return time_start_str, time_end_str
end

function M:setTouchBtnIndex(index)
	self.m_touch_btn_index = index
end

function M:getTouchBtnIndex()
	return self.m_touch_btn_index
end

return M
