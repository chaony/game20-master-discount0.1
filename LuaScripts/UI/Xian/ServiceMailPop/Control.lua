local M = class("ServiceMailPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:openMail(self.m_model.m_select_index)
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:updateMsg("updateUI", nil, "Xian")
        self:closeView()
    elseif msg == "fast_remove_btn" then -- 一键删除
        local params =
        {
            on_ok_call = function(msg)
                self:getRemoveRewards()
            end,
            on_cancel_call = function (msg)

            end,
            no_close_btn = false,
            text = Language:getTextByKey("mail_str_0008")
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "fast_get_btn" then --一键领取
        self:getAllRewards()
    elseif msg == "updateData" then --单个邮件刷新
        self.m_model:updateOnMail(data)
        self.m_view:refreshUI()
    elseif msg == "select" then
        self.m_model.m_select_index = data
        self.m_view:refreshUI()
        self:openMail(self.m_model.m_select_index)
    elseif msg == "copy_btn" then
        CS.UnityEngine.GUIUtility.systemCopyBuffer = self.m_model:getCurCDK()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0698"), delay_close = 2})
    elseif msg == "delete_btn" then
        self:getRemoveRewards()
	end
end

function M:openMail(index)
    local mail_data = self.m_model:getMailData(index)
    if mail_data then
        if mail_data.data.status == 0 then
            local params = {}
            params.code_id = mail_data.id
            local function readCallback(response)
                if response then
                    self.m_model:updateOnMail({id = mail_data.id, data = response.code})
                    self:updateMsg("updateOneCode", {id = mail_data.id, code = response.code}, "Xian")
                    self.m_view:refreshUI()
                end
            end
            self.m_model:getNetData("read_code", params, readCallback)
        else
            self.m_view:refreshUI()
        end
    end
end

function M:getAllRewards()
    local function readCallback(response)
        if response then
            self.m_model:updateMail(response)
            self:updateMsg("remove_code", response, "Xian")
            if next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("receive_all_mail", nil, readCallback)
end

function M:getRemoveRewards()
    local function readCallback(response)
        self.m_model:updateMail(response)
        self:updateMsg("remove_code", response, "Xian")
        self.m_view:refreshUI()
    end
    local code_id = self.m_model:get_Codeid()
    self.m_model:getNetData("remove_code", {code_id = code_id}, readCallback)
end

return M