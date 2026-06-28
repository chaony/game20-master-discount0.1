local M = class("LiteratureTaskAnswerPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:updateMsg("update_data", nil, "Activities.EnjoySpring")
        self:closeView()
    elseif msg == "answer_btn1" then
        self:requestAnswer(1)
    elseif msg == "answer_btn2" then
        self:requestAnswer(2)
    elseif msg == "answer_btn3" then
        self:requestAnswer(3)
    elseif msg == "answer_btn4" then
        self:requestAnswer(4)
    end
end

function M:requestAnswer(ans_id)
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(2, function ()
        if self.m_view then
            self.m_view:unlockTouch()
        end
        self.timer_id = nil
    end)
    local function indexCallback(response)
        self.m_model.m_cur_answer_id = ans_id
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:showTurns(function ()
            self.m_view:unlockTouch()
            self:updateMsg("update_question", self.m_model.m_cur_question, "Activities.EnjoySpring")
            self.m_model.m_cur_question = self.m_model.m_cur_question + 1
            if self.m_model.m_cur_question > self.m_model:getMaxNum() then
                self:updateMsg(99999)
                return
            end
            audio:SendEvtUI("UI_XK_ChuanQi_Page")
            self.m_view:refreshUI()
        end)
    end
    local params = {}
    params.answer_id = ans_id
    params.question_id = self.m_model.m_cur_question
    params.library = self.m_model.m_cur_day
    self.m_model:getNetData("enjoy_spring_answer", params, indexCallback)
end



return M;
