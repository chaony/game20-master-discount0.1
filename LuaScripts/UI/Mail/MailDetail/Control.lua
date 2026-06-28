local M = class("MailDetailPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "yes_btn" then
        if #self.m_model.m_rewards > 0 and self.m_model.m_params.is_received == false then
            self:receiveMail()
        else
            self:updateMsg(99999)
        end
    end
end

function M:receiveMail()
    local params = {}
    params.mail_id = self.m_model.m_params.id
    local function receiveCallback(response)
        if response then
            self.m_model.m_params.is_received = true
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("receive_mail", response.mail_ids, "Friend")
            --self:updateMsg("receive_mail", response.mail_ids, "Mail")
            self:closeView()
        end
    end
    self.m_model:getNetData("mail_receive", params, receiveCallback)
end

return M;
