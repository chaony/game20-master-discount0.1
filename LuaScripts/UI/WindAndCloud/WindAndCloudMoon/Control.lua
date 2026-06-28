---@class DeliciousFeastRankControl: OOControlBase
local M = class("WindAndCloudMoonControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudMain")
        self:closeView()
    elseif msg == "peak_game_btn" then --名扬四海跳转
        self:openView("WindAndCloud.WindAndCloudRedEnvelope")
        self:setOnceTimer(0.5,function()
            self:closeView()
        end)
    elseif msg == "reward_btn" then --奖励
        self:openView("WindAndCloud.WindAndCloudMoonRankRewardPop",{version = self.m_model.current_show_tab_num,open_id = self.m_model.open_id})
    elseif msg == "check_tag" then
        if data > self.m_model.show_tab_max_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
            return
        end
        self:refreshListData(data)
        self.m_model:setSelectIndex(data)
        self.m_view:refreshRightNode()
    elseif msg == "refresh_data" then --倒计时结束后刷新
        self.m_model:refreshActiveData()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wind_clouds_text_0007"), delay_close = 4})
        self.m_view.is_refresh = 0
    elseif msg == "hint_btn" then --帮助
        local params = {}
        params.title = self.m_view.avtive_data.name
        params.content = "tid#DiamondEvent_4"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "load_rank" then --刷新到最低
        self:refreshListData()
    end
end

--刷新list数据
function M:refreshListData(data_id)
    local version_id = self.m_model.current_show_tab_num
    local start,stop = self.m_model:getLoadIndex()
    local is_new_list = true
    if data_id then
        version_id = data_id
        start,stop = 1,10
        is_new_list = false
    else
        local is_refresh_list = self.m_model:getIsRefreshList()
        if not is_refresh_list then
            return
        end
    end
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:updateServerData(response,is_new_list)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_diamond_rebate_ranks", {open_id = self.m_model.open_id,version = version_id,start = start, stop = stop},netCallback)
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M

