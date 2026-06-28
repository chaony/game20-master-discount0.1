local M = class("LiteratureTaskPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "start_btn" then
        if self.m_model.m_finish == false then
            local params = {}
            params.day = self.m_model.m_cur_day
            params.question_index = self.m_model:getQuestionIndex()
            self:openView("Activities.EnjoySpring.LiteratureTaskAnswerPop", params)  
        end
        self:updateMsg(99999)
    end
end

return M;
