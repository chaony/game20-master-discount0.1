---@class DeliciousFeastRankControl: OOControlBase
local M = class("QiXiLoveControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "explain_btn" then -- 说明
        self.avtive_data = self.m_model:getActiveData()
        local params = {}
        params.title = self.avtive_data.name
        params.content = "tid#ValentineFestival_5"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "rank_reward_btn" then
        self:openView("QiXi.QiXiLoveRankRewardPop", {version = self.m_model.m_version})
    elseif msg == "refresh_flowerEvent" then
        self.m_model:getNetData("flower_index", {vsn = self.m_model.m_version, start = 1, stop = 10}, function(response)
            if response then
                if self:activityOverExamine(response) then
                    return
                end
                self.m_model:refreshRankData(response)
                self.m_view:refreshUI()
            end
        end, nil, nil, nil)
    elseif msg == "btn_myTab" then
        self.m_model:setSelectIndex(1)
        self.m_view:switchTabView()
    elseif msg == "btn_myTeamTab" then
        self.m_model:setSelectIndex(2)
        self.m_view:switchTabView()
    elseif msg == "btn_flowerBtn" then --查看排行榜按钮
        local activityData = UserDataManager:getActivesDataByOpenId(self.m_model.open_id)
        if not activityData then
            return
        end
        self:openView("FlowerFestival.FlowerGiveRank",{version = activityData.version})
    end
end


--function M:updateTime()
--    self.m_view:updateActivityTimer()
--end

--function M:activityOverExamine(response)
--    if response["end"] == 1 then
--        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
--        self:closeView()
--        return true
--    end
--    return false
--end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M

