local M = class("LiteratureTaskPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	self.m_vsn = self.m_params.version or 1
	self.correct_times = self.m_params.correct_times or -1
	self.m_enjoy_spring_riddle_reward = ConfigManager:getCfgByName("enjoy_spring_riddle_reward") --答题奖励
	local enjoy_spring_riddle = ConfigManager:getCfgByName("enjoy_spring_riddle") --题目
	self.m_cur_day = self.m_data.cur_day or 0 --天数
	self.m_cur_question = self.m_data.cur_question or 0 -- 已答第几道题
	if self.m_cur_day == 0 then
		self.m_cur_day = 1
	end
	self.cur_riddle = enjoy_spring_riddle[self.m_cur_day] or enjoy_spring_riddle[1]
	if self.m_cur_question >= #self.cur_riddle then
		self.m_finish = true --今日已答完
	else
		self.m_finish = false	
	end
end

function M:getQuestionIndex()
	return self.m_cur_question + 1
end

function M:getRiddleReward(index)
	local reward_data = self.m_enjoy_spring_riddle_reward[self.m_vsn][index] or self.m_enjoy_spring_riddle_reward[self.m_vsn][1]
	return reward_data.reward
end

return M
