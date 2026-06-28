---@class DeliciousFeastBlessControl: OOControlBase
---@field m_model DeliciousFeastBlessModel
---@field m_view DeliciousFeastBlessView
local M = class("DeliciousFeastBlessControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:closeView()
    elseif msg == "bless_btn" and self:checkActivityOpen() then
        --祈愿
        self:requestBless()
    elseif msg == "tgl_btn1" then
        --页签1
        self:switchTabBtn(1)
    elseif msg == "tgl_btn2" then
        --页签2
        self:switchTabBtn(2)
    elseif msg == "recvReward" and self:checkActivityOpen() then
        --领取奖励
        self:requestRecvReward(data)
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("feast_text_0011"), content = Language:getTextByKey("tid#MTDes1") })
    elseif msg == "daily_update_data" then
        --更新每日任务
        self:updateDailyData()
    elseif msg == "goto_btn" then
        --跳转
        self:updateMsg("common_refresh", nil, "parent")
        static_rootControl:closeAllViewPop()
        local go_type = data.cfg.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    end
end

function M:requestBless()
    if not self.m_model:checkCanBless() then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("feast_text_0020"), delay_close = 2 })
        return
    end
    local function callback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateBlessNum(response.pray)
            self.m_view:refreshBless()
        end
    end
    self.m_model:getNetData("feast_pray", { vsn = self.m_model:getCurVersion(), times = 1 }, callback)
end

function M:switchTabBtn(index)
    self.m_model:setCurTabIndex(index)
    self.m_view:switchTabNode()
end

function M:requestRecvReward(data)
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateQuestsData(response.quests, response.update == 1)
            self.m_model:setCurDayIndex(response.cur_day)
            local add_pray_num = response.pray - self.m_model:getBlessNum()
            if add_pray_num > 0 then
                GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("feast_text_0021", add_pray_num), delay_close = 2 })
            end
            self.m_model:updateBlessNum(response.pray)
            self.m_view:refreshBless()
            self.m_view:refreshTaskLoopScrollList()
            self.m_view:refreshRedPoint()
            self:updateMsg("updata_task", {quests = response.quests, refresh = response.update == 1}, "Activities.DeliciousFeast.DeliciousFeastMain")
        end
    end
    local params = { vsn = self.m_model:getCurVersion(), quest_id = data.id, cur_day = self.m_model:getCurDayIndex()}
    self.m_model:getNetData("feast_recv_quest_reward", params, netCallback)
end

function M:checkActivityOpen()
    if not self.m_model:checkActivityOpen() then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        self:closeView("Activities.DeliciousFeast.DeliciousFeastBless")
        return false
    end
    return true
end

function M:updateDailyData()
    local function callback(response)
        if response then
            local isExchangeDay = response.cur_day ~= self.m_model:getCurDayIndex()
            self.m_model:updateQuestsData(response.quests, isExchangeDay)
            self.m_model:setCurDayIndex(response.cur_day)
            self.m_view:refreshTaskLoopScrollList()
            self.m_view:refreshRedPoint()
            self:updateMsg("updata_task", {quests = response.quests, refresh = isExchangeDay}, "Activities.DeliciousFeast.DeliciousFeastMain")
        end
    end
    self.m_model:getNetData("feast_main_index", nil, callback)
end

return M
