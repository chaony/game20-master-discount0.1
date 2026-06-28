local M = class("KingSoftChangeControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn2" or msg == "cancel_btn" then    -- 返回
        self:closeView()
    elseif msg == "sure_btn" then
        audio:SendEvtUI("UI_DJQDing")
        local change_num = self.m_view:getMsg()
        if change_num and change_num ~= "" then
            if tonumber(change_num)  < self.m_model:getMaxValue() then
                self:popTips(change_num)
            elseif tonumber(change_num) > self.m_model:getMaxValue() then
                self.m_view:showTips()
            else
                self:requestChange(change_num)
            end
        end
    elseif msg == "close_tips_btn" then
        self.m_view:closeTips()
    end
end

function M:popTips(change_num)
    local tips = Language:getTextByKey("kingsoft_text_0043")
    local params =
    {
        on_ok_call = function(msg)
            self:requestChange(change_num)
        end,
        tow_close_btn = true,
        text = tips,
        title = "",
        new_cancel_call = function(msg)
        end,
        tow_close_btn = true,
        ok_text = Language:getTextByKey("new_str_0006"),
        cancel_text = Language:getTextByKey("new_str_0007"),
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:requestChange(change_num)
    local function modifyCallback(response)
        if response.success then
            if not(next(response.reward))  then --修改成功但是没奖励 弹提示
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("kingsoft_text_0048"), delay_close = 2})
            end
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("kingsoft_text_0044"), delay_close = 2})
        end
        RewardUtil:rewardTipsByData(response.reward or {})
        self:updateMsg("refrehIndex", {new_data = response}, "Activities.Kingsoft")
        self:closeView()
    end
    local params = {}
    params.value = tonumber(change_num)
    params.date_id = self.m_model.m_cell_data[1]
    params.vsn = self.m_model.m_vsn
    self.m_model:getNetData("active_kingsoft_modify", params, modifyCallback)
end
return M
