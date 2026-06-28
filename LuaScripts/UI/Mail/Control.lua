local M = class("MailPopControl",LikeOO.OOControlBase)

function M:onEnter()
    local data = self.m_model:getMailByIndex(self.m_model.m_select_index)
    if data and data.status == 0 then
        self:updateMsg("open", self.m_model.m_select_index)
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "back_btn" then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "open" then
        self:openMail(data)
    elseif msg == "fast_get_btn" then
        self:receiveAllMail()
    elseif msg == "fast_remove_btn" then
        local params =
        {
            on_ok_call = function(msg)
                self:deleteAllMail()
            end,
            on_cancel_call = function (msg)
                
            end,
            no_close_btn = false,
            text = Language:getTextByKey("mail_str_0008")
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "get_btn" then
        self:receiveMail()
    -- elseif msg == "receive_mail" then
    --     self.m_model:setMailReceived(data)
    --     self.m_view:refreshUI()
    end
end

function M:openMail(index)
    local data = self.m_model:getMailByIndex(index)
    if data then
        if data.status == 0 then
            local params = {}
            params.mail_id = data.id

            local function readCallback(response)
                if response then
                    self.m_model:setMailStatus(response.mail_ids, 1)
                    self.m_model:setSelectIndex(index)
                    self.m_view:refreshUI()
                    -- self:openView("Mail.MailDetail", data)
                end
            end
            self.m_model:getNetData("mail_read", params, readCallback)
        else
            self.m_model:setSelectIndex(index)
            self.m_view:refreshUI()
            -- self:openView("Mail.MailDetail", data)
        end
    end
end

function M:receiveAllMail()
    local function receiveCallback(response)
        if response then
            Logger.log(response,"receiveCallback response =====")
            if next(response.reward) ~= nil then
                self.m_model:setMailReceived(response.mail_ids)
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(response.reward)
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mail_str_0007"), delay_close = 2})
            end
        end
    end
    self.m_model:getNetData("mail_receive_all", nil, receiveCallback)
end

function M:deleteAllMail()
    local function deleteCallback(response)
        if response then
            self.m_model:deleteMail(response.mail_ids)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("mail_delete_all", nil, deleteCallback)
end

----------------邮件内容------------------------------------------------------------

function M:receiveMail()
    local data = self.m_model:getMailByIndex(self.m_model.m_select_index)
    local params = {}
    params.mail_id = data.id
    local function receiveCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:setMailReceived(response.mail_ids)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("mail_receive", params, receiveCallback)
end

return M;
