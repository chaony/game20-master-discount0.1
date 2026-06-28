---@class HalfAnniversaryTotalTaskControl: OOControlBase
---@field m_model HalfAnniversaryTotalTaskModel
---@field m_view HalfAnniversaryTotalTaskView
local M = class("HalfAnniversaryTotalTaskControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        self:closeView()
    elseif msg == "canReceived1" then
        self:onClickBox(1)
    elseif msg == "canReceived2" then
        self:onClickBox(2)
    elseif msg == "canReceived3" then
        self:onClickBox(3)
    elseif msg == "canReceived4" then
        self:onClickBox(4)
    elseif msg == "canReceived5" then
        self:onClickBox(5)
    elseif msg == "btn_goBtn" then
        -- 每日跳转
        audio:SendEvtUI("PLAY_UI_CLICK")
        local curDayIndex = self.m_model:getActivityOpenDay()
        curDayIndex = math.floor(curDayIndex)
        curDayIndex = curDayIndex <= 0 and 1 or curDayIndex
        local cell_data = self.m_model.m_taskData.dayTaskData[curDayIndex] or {}
        local xlsxData = cell_data.xlsxData
        if xlsxData then
            local jumpId = xlsxData.go_type
            static_rootControl:closeAllViewPop()
            QuickOpenFuncUtil:openFunc(jumpId)
        end
    elseif msg == "btn_getBtn" then
        -- 每日领取
        local curDayIndex = self.m_model:getActivityOpenDay()
        curDayIndex = math.floor(curDayIndex)
        curDayIndex = curDayIndex <= 0 and 1 or curDayIndex
        local cell_data = self.m_model.m_taskData.dayTaskData[curDayIndex] or {}
        local params = { vsn = self.m_model.m_version, quest_id = cell_data.id }
        self.m_model:getNetData("half_year_quest_reward", params, function(response)
            if response then
                if self:activityOverExamine(response) then
                    return
                end
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:refreshActivityData(response)
                self.m_model:setAllTaskData()
                self.m_view:refreshCurDayItem()
                self.m_view:refreshScoreAndSlider()
            end
        end, nil, nil, nil)
    elseif msg == "jifen_obj" then
        -- 点击每日积分img弹出
        local click_object = self.m_view:findGameObject("jifen_obj")
        GameUtil:lookInfoTips(self, { click_transform = click_object.transform, msg = Language:getTextByKey("half_year_text_0020") })
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0007"), content = Language:getTextByKey("tid#half_year_Des") })
    elseif msg == "everyDayRefresh" then
        self.m_model:getNetData("half_year_quest_index", {}, function(response)
            if response then
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0085"), delay_close = 2 })
                    static_rootControl:closeAllViewPop()
                    return
                end
                self.m_model:refreshActivityData(response)
                self.m_model:setAllTaskData()
                self.m_view:refreshMiddleNode()
                self.m_view:refreshScoreAndSlider()
            end
        end, nil, nil, nil)
    end
end

function M:lookAward(data)
    local awardData = self.m_model.m_allAwardsData[data.index]
    local xlsxData = awardData.xlsxData
    local rewards = xlsxData.reward
    self:openView("Pops.LookRewardTips", { rewards = rewards, click_transform = data.click_transform, show_check_mark = false })
end

function M:onClickBox(index)
    audio:SendEvtUI("UI_Tab_N7")
    local awardData = self.m_model.m_allAwardsData[index]
    local xlsxData = awardData.xlsxData
    local isCanRecv = (self.m_model.m_score >= xlsxData.score) and (not awardData.isReceived)
    if isCanRecv then
        self:recvScoreAward(index)
    end
end

function M:recvScoreAward(index)
    local params = { vsn = self.m_model.m_version, score_id = index }
    self.m_model:getNetData("half_year_score_reward", params, function(response)
        if response then
            if self:activityOverExamine(response) then
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateAwardState(response.score_done)
            self.m_view:refreshAwardNode()
        end
    end, nil, nil, nil)
end

function M:activityOverExamine(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0085"), delay_close = 2 })
        static_rootControl:closeAllViewPop()
        return true
    end
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M
