---@class LoyaltyRankControl: OOControlBase
local M = class("LoyaltyRankControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point",nil,"Loyalty.LoyaltyMain")
        self:closeView()
    elseif msg == "explain_btn" then -- 说明
        self.avtive_data = self.m_model:getActiveData()
        local params = {}
        params.title = self.avtive_data.name
        params.content = "tid#ValentineFestival_5"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "rank_reward_btn" then
        self:openView("Loyalty.LoyaltyRankRewardPop", {version = self.m_model.m_version})
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
        if self.m_view.m_roleScroll_view then
            self.m_view.m_roleScroll_view:moveToCellIndex(1)
        end
    elseif msg == "btn_myTeamTab" then
        self:refreshTeamData()
        self.m_model:setSelectIndex(2)
        self.m_view:switchTabView()
        if self.m_view.m_teamScroll_view then
            self.m_view.m_teamScroll_view:moveToCellIndex(1)
        end
    elseif msg == "btn_flowerBtn" then --查看排行榜按钮
        local activityData = UserDataManager:getActivesDataByOpenId(self.m_model.open_id)
        if not activityData then
            return
        end
        self:openView("FlowerFestival.FlowerGiveRank",{version = activityData.version})
    elseif msg == "load_rank" then
        self:requestLoadRank(data)
    end
end


--更新帮会信息
function M:refreshTeamData()
    if #self.m_model.teamRankData == 0 then
        local function netCallback(response)
            self.m_model.guildData = response
            self.m_model:refreshRankData(response,2)
            self.m_view:refreshRightNode()
        end
        self.m_model:getNetData("red_envelope_guild_rank", { start = 1, stop = 10 }, netCallback)
    end
end

function M:requestLoadRank(index)
    local start_pos, end_pos = self.m_model:getLoadIndex(index)
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                if index == 1 then
                    self.m_model.personData = response
                else
                    self.m_model.guildData = response
                end
                self.m_model:refreshRankData(response,index)
                self.m_view:refreshRightNode()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        local url = index == 1 and "red_envelope_personal_rank" or "red_envelope_guild_rank"
        self.m_model:getNetData(url, params, netCallback)
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M

