local M = class("RecruitPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point",nil,"Activities")
        self:closeView()
    elseif msg == "receive_btn" then
        self:requestReceive(data)
    elseif msg == "day_1_btn" then
        self.m_model:selectDay(1)
        self.m_view:refreshUI()
    elseif msg == "day_2_btn" then
        self.m_model:selectDay(2)
        self.m_view:refreshUI()
    elseif msg == "day_3_btn" then
        self.m_model:selectDay(3)
        self.m_view:refreshUI()
    elseif msg == "day_4_btn" then
        self.m_model:selectDay(4)
        self.m_view:refreshUI()
    elseif msg == "day_5_btn" then
        self.m_model:selectDay(5)
        self.m_view:refreshUI()
    elseif msg == "day_6_btn" then
        self.m_model:selectDay(6)
        self.m_view:refreshUI()
    elseif msg == "day_7_btn" then
        self.m_model:selectDay(7)
        self.m_view:refreshUI()
    end
end

function M:requestReceive(data)
    Logger.log(data,"data =====")
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data.id
    self.m_model:getNetData("quest_recv_recruit_reward", params, receivetCallback)
end

return M;
