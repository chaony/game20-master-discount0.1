local M = class("MasterApprenticeRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView() 
    elseif msg == "CloseBtn" then
        self:closeView()    
    elseif msg == "get_reward" then
        self:requestReceiveQuest(data)
    end
end

--领奖励
function M:requestReceiveQuest(data)
    local function callback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:initData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_receive_quest", {quest_id = data}, callback)
end


return M;
