local M = class("GambleMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg(99999, {from_gamble_main = true}, "Gamble.GambleChoose")
        self:updateMsg(99999, nil, "Gamble.GambleRank")
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "switch_toggle" then
        self:switchToggleIndex(data)
    elseif msg == "open_question" then
        self:openQuestion(data)
    elseif msg == "rank_btn" then
        self:openView("Gamble.GambleRank", self.m_model:getRankCfg())
    elseif msg == "explain_btn" then
        local active_data = self.m_model:getActiveCfg() or {}
        local content = self.m_model:getHelpContent()
        self:openView("Pops.CommonHelpPop", {title = active_data.name or "", content = content})
    elseif msg == "choose_answer" then
        self:chooseAnswerRequest(data)
    end
end

function M:switchToggleIndex(index)
    local selected_index = self.m_model:getSelectedIndex()
    if index ~= selected_index then
        self.m_model:dataOutdateCheck()
        self.m_model:setSelectedIndex(index)
        self.m_view:switchToggleIndex()
    end
end

function M:openQuestion(question_data)
    if question_data.data.stage == 1 and question_data.data.status == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gamble_text_014"), delay_close = 2})
        return
    end
    if question_data.data.stage == 2  then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gamble_text_015"), delay_close = 2})
        return
    end
  
    self:openView("Gamble.GambleChoose", question_data)
end

function M:outdateCheck()
    self.m_model:dataOutdateCheck()
    self.m_view:refreshUI()
end

function M:chooseAnswerRequest(question_data)
    local function netCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.version = self.m_model:getVersion()
    params.group = self.m_model:getSelectedIndex()
    params.q_id = question_data.data.id
    params.option = {question_data.data.selected_answer_id}
    self.m_model:getNetData("world_cup_bet", params, netCallback)
end

function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
