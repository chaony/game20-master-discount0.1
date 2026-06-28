local M = class("LanternFestivalRiddlesPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
   
    elseif msg == "help_btn" then
        local params = {}
        params.title = "total_world_rank_text_02"
        params.content = self.m_model.m_help_id
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "answer_btn1" then
        self:requestAnswerData(1)
    elseif msg == "answer_btn2" then
        self:requestAnswerData(2)
    elseif msg == "answer_btn3" then
        self:requestAnswerData(3)
    elseif msg == "answer_btn4" then
        self:requestAnswerData(4)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestAnswerData(index)
    if self.m_model.m_status_data.res == 2 or self.m_model.m_status_data.res == 3 then
        return
    end
    local function netCallback(response)
        self.m_model.m_cur_select = index
        if self.m_view then
            if response.update then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:updateMsg("refresh_index",nil,"LanternFestival")
                self:closeView()
                return
            end
            if response["end"] then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:updateMsg("refresh_index",nil,"LanternFestival")
                self:closeView()
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            local question_data = self.m_model:getQuestion()
            if index ~= question_data.correct then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lantern_festival_text_0014"), delay_close = 2})
            end
            self.m_model:initData(response)
            self.m_view:refreshUI(question_data)
            self:updateMsg("refresh_data",response,"LanternFestival.LanternFestivalRiddles")
        end
    end
    local params = {}
    params.vsn = self.m_model.m_version
    params.day = self.m_model.m_question_index
    params.ans = index
    self.m_model:getNetData("active_lantern_riddle", params, netCallback)
end
return M;
