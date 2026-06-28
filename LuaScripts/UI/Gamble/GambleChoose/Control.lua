local M = class("GambleChooseControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then
        if data and data.from_gamble_main == true then
        elseif self.m_model:getQuestionStage() < 3 then --展示期查看可直接关闭
            if self:chooseOneCheck() == false then
                return
            end
            if self:chooseDoubleCheck() == false then
                return
            end
            self:updateMsg("choose_answer", self.m_model:getParamsData(), "Gamble.GambleMain")
        end
        self:closeView()
    elseif msg == "choose_answer" then
        if self.m_model:getQuestionStage() > 1 then --【查看】阶段只展示正确答案，不做选择
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gamble_text_009"), delay_close = 2})
            return
        end
        self:chooseAnswer(data)
    elseif msg == "default_double_check_btn" then
        self.m_model:updateChooseDoubleCheckFlag()
        self.m_view:refreshChooseDoubleCheckButtonStatus()
    end
end

function M:chooseAnswer(index)
    if index ~= self.m_model:getChooseIndex() then
        self.m_model:chooseAnswer(index)
        self.m_view:updateLoopScroll()
    end
end

function M:chooseOneCheck()
    if self.m_model:hasChooseOne() == true then
        return true
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gamble_text_007"), delay_close = 2})
        return false
    end
end

function M:chooseDoubleCheck()
    if  self.m_model:getChooseDoubleCheckFlag() == 1 then
        local params = {
            on_ok_call = function()
                self:updateMsg("choose_answer", self.m_model:getParamsData(), "Gamble.GambleMain")
                self:closeView()
            end,
            tow_close_btn = true,
            text = Language:getTextByKey("gamble_text_006")
        }
        self:openView("Pops.CommonPop", params)
        return false
    end
    return true
end

return M
