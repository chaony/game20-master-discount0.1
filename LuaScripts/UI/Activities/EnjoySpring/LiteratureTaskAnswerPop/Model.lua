local M = class("LiteratureTaskAnswerPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cur_day = self.m_params.day or 0 --天数
	self.m_cur_question = self.m_params.question_index or 0 -- 第几道题
	local enjoy_spring_riddle = ConfigManager:getCfgByName("enjoy_spring_riddle") --题
	self.m_enjoy_spring_riddle = enjoy_spring_riddle[self.m_cur_day]
	self.m_cur_answer_id = nil -- 当前选择的答案
end

function M:getQuestion()
	return self.m_enjoy_spring_riddle[self.m_cur_question]
end

function M:getMaxNum()
	return #self.m_enjoy_spring_riddle
end

return M