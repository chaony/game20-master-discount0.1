local M = class("GambleChooseModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--【查看】阶段展示正确答案，【已预测】阶段不让进来，【未预测】阶段进来预测
	self.m_choose_index = self.m_params.data.stage == 3 and self.m_params.cfg.correct_answer[1] or 0
	self.m_choose_double_check_flag = UserDataManager.local_data:getLocalDataByKey("GambleChooseDoubleCheckFlag", 1)
	self.m_content_data = {}
	self:initData()
end

function M:getParamsData()
	return self.m_params
end

function M:initData()
	self.m_content_data = self.m_params.cfg.answers or {}
end

function M:getQuestionData()
	return self.m_params.cfg
end

function M:getQuestionStage()
	return self.m_params.data.stage
end

function M:getChooseIndex()
	return self.m_choose_index
end

function M:chooseAnswer(index)
	self.m_choose_index = index
	self.m_params.data.selected_answer_id = index
end

function M:getContentData()
	return self.m_content_data
end

function M:hasChooseOne()
	return self.m_choose_index ~= 0
end

function M:getChooseDoubleCheckFlag()
	return self.m_choose_double_check_flag
end

function M:updateChooseDoubleCheckFlag()
	local flag = self.m_choose_double_check_flag == 0 and 1 or 0
	self.m_choose_double_check_flag = flag
	UserDataManager.local_data:setLocalDataByKey("GambleChooseDoubleCheckFlag", flag)
end

return M
