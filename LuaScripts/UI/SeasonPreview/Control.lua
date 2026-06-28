---@class SeasonPreviewControl
---@field m_model SeasonPreviewModel
---@field m_view  SeasonPreviewView
local M = class("SeasonPreviewControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif table.indexof(self.m_view.m_ui_data.btn_name, msg) then
        self.m_model:setFuncNodeStatus(true)
        self.m_view:updateFuncDesNode(msg)
    elseif msg == "func_des_pop_btn" then
        self.m_model:setFuncNodeStatus(false)
        self.m_view:updateFuncDesNode()
    elseif msg == "reward_btn" then
        self.m_model:setRewardNodeStatus(true)
        self.m_view:updateRewardDesNode()
    elseif msg == "reward_content_node" then
        self.m_model:setRewardNodeStatus(false)
        self.m_view:updateRewardDesNode()
    elseif msg == "hero_detail" then
        if data then
            local hero_id_tab = self.m_model:getShowHeroId()
            local hero_id = hero_id_tab[data]
            self:openView("Pops.HeroLookInfo", {hero_id = hero_id, is_new = false})
        end
    elseif msg == "goto_btn" then
        self:getRewardRequest()
    elseif msg == "road_btn" then
        self:openView("Achievement") -- 赛季旅程
    elseif msg == "vedio_btn" then
        self.m_view:seasonVideo()
    elseif msg == "gift_btn" then
        local active_data = UserDataManager:getActivesRechargeDataByOpenId(313)
        if active_data then
            self:openView("SeasonPreview.SeasonGiftBag", {active_data = active_data})
        end
    elseif msg == "refresh_red_point" then
        self.m_view:refreshUI()
        self:updateMsg("refreshRedPoint",nil, "Main.TotalWorld")
        self:updateMsg("refreshRedPoint",nil, "Main")
    end
end
function M:getRewardRequest()
    local function getRewardCallback(response)
        RewardUtil:rewardTipsByData(response.reward or {})
        UserDataManager:setSeasonPreviewStatus(1)
        self.m_model.m_can_get_reward = self.m_model:getRewardStatus()
        self.m_view:refreshUI()
        self:updateMsg("refreshRedPoint",nil, "Main.TotalWorld")
        self:updateMsg("refreshRedPoint",nil, "Main")
    end
    self.m_model:getNetData("world_recv_season_reward", nil, getRewardCallback)
end

function M:updateTime()
    self.m_view:updateTime()   
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end
return M
