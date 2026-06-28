--悬赏列表
local M = class("RewardSpecialControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Reward.RewardSend.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_bounty" then
        self.m_model.m_select_index = data
        self.m_view:refreshUI()
    end
end



return M;
