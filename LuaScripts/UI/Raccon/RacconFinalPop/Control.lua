local M = class("RacconFinalPopontrol",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "look_hero_btn" then
        self:showHeroInfo()
    elseif msg == "get_btn" then
        self:getBoxReward()
    end
end

function M:getBoxReward()
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
            if self.m_model.m_callback then
                self.m_model.m_callback(self.m_model.m_callback_new)
            end
            self:updateMsg("common_refresh", nil, "parent")
            self:closeView()
        end
    end
    local active = UserDataManager:getActivesDataByOpenId(347)
    if active and next(active) then
        local params = {}
        params.open_id = 347
        params.vsn = active.version
        params.quest_id = self.m_model.m_task_id
        self.m_model:getNetData("common_quest_recv_task", params, netCallback)
    end
end


function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = 116, is_new = false})
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
