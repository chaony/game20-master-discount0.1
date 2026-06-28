local M = class("PSQPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "left_to_right"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	local question_data = UserDataManager.questions -- {version: 问卷id, start_ts:开启时间， end_ts：结束时间 }
	self.is_open = false --是否打开
	self.version = question_data.version or 1
	local quest_tab = ConfigManager:getCfgByName("question")
	self.question_tab = quest_tab[self.version]
	
	self.m_select_id = nil --单选答案
	self.m_select_ids = {} --多选答案
end

function M:refreshData(data)
	self.m_qid = data.start_qid or 1 --题目id
end

function M:refreshNextData(data)
	self.m_qid = data.next_qid or 1 --题目id
	self.m_select_id = nil
	self.m_select_ids = {}
end

function M:checkLastQuest()
	local des_tab = ConfigManager:getCfgByName("question_des")
	local vers_b = des_tab[self.version]
	if self.m_qid >= #vers_b then
		return true
	else
		return false	
	end
end

--获取题目
function M:getQuestion()
	local des_tab = ConfigManager:getCfgByName("question_des")
	local vers_b = des_tab[self.version]
	local qu_des = vers_b[self.m_qid or 1]
	return qu_des
end

function M:getSortName()
	local question = self:getQuestion()
	if question.sort == 1 then
		return Language:getTextByKey("psq_str_0009")
	elseif question.sort == 2 then
		return Language:getTextByKey("psq_str_0010")
	elseif question.sort == 3 then
		return Language:getTextByKey("psq_str_0011")
	end
end

function M:getProgress()
	local des_tab = ConfigManager:getCfgByName("question_des")
	local vers_b = des_tab[self.version]
	local num_1 = self.m_qid - 1
	local num = (num_1/#vers_b) * 100
	return 	math.floor(num).."%" 
end

--获取题目答案
function M:getAnswer()
	local ans_tab = ConfigManager:getCfgByName("question_answer")
	local vers_b = ans_tab[self.version]
	local qu_ans = vers_b[self.m_qid or 1]
	return qu_ans
end

--获取题目答案--多选
function M:getAnswer2()
	local ans_tab = ConfigManager:getCfgByName("question_answer")
	local vers_b = ans_tab[self.version]
	local qu_ans = vers_b[self.m_qid or 1]
	for k,v in pairs(qu_ans) do
		v.id = k
	end
	return qu_ans
end

function M:seleType2Answer(is_on, id)
	if is_on == true then
		table.insert( self.m_select_ids, id)
	else
		for k,v in pairs(self.m_select_ids) do
			if v == id then
				table.remove( self.m_select_ids, k)
				break
			end
		end
	end
end

function M:checkAnswerNum()
	return table.nums(self.m_select_ids)
end

return M
