local M = class("LanternFestivalFunPlayControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_index", nil, "LanternFestival")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "help_btn" then
        local params = {}
        params.title = "lantern_festival_text_0002"
        params.content = self.m_model.m_help_id
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "detail_reward_btn" then --领取奖励
        self:questRewardTaskDetail(data)
    elseif msg == "detail_goto_btn" then  --跳转活动
        static_rootControl:closeAllViewPop()
        local go_type = data.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "fire_btn" then --抽奖
        local score_num = self.m_model:getShowScore()
        if self.m_model.m_data.score >= score_num then --积分达标，可以抽奖
            self:draw()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lantern_festival_text_0013"), delay_close = 2})
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

--任务奖励
function M:questRewardTaskDetail(data)
    local function netCallback(response)
        if response then
            if response.update then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            if response["end"] then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            self.m_model:initData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.vsn = self.m_model.m_version
    params.quest_id = data.quest_id
    self.m_model:getNetData("active_lantern_recv_quest", params, netCallback)
end

--抽奖
function M:draw()
    local function netCallback(response)
        if response then
            if response.update then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            if response["end"] then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            self.m_model:initData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("active_lantern_draw", params, netCallback)
end

return M;
