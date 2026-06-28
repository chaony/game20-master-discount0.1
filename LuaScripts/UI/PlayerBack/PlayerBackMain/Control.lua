local M = class("PlayerBackMainControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:closeView()
    elseif msg == "old_btn" then
        if self:eightHoursCheck() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1077"), delay_close = 2})
            return
        end
        local params = {
            on_ok_call = function()
                if self:eightHoursCheck() == false then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1077"), delay_close = 2})
                    return
                end
                self:goToOld()
            end,
            tow_close_btn = true,
            text = Language:getTextByKey("new_str_1069")
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "new_btn" then
        if self:eightHoursCheck() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1077"), delay_close = 2})
            return
        end
        self:openView("PlayerBack.PlayerBackToNew", {servers = self.m_model:getServerData(), callback = self.m_model.m_callback , callback_new = self.m_model.m_callback_new})
    end
end

function M:eightHoursCheck()
    if UserDataManager.comeback_status == 1 then
        local min_unit = 60
        local hour_unit = min_unit * 60
        local day_unit = hour_unit * 24
        local time_left = hour_unit * 8 - (UserDataManager:getServerTime() - UserDataManager.comeback_ts or 0)
        local day_left = math.floor(time_left / day_unit)
        local hour_left = math.floor((time_left - day_unit * day_left) / (hour_unit))
        local min_left = math.floor((time_left - day_unit * day_left - hour_unit * hour_left) / min_unit)
        local sec_left = math.floor(time_left - day_unit * day_left - hour_unit * hour_left - min_unit * min_left)
        if hour_left > 0 or min_left > 0 or sec_left > 0 then
            return true
        end
    end
    return false
end

function M:goToOld()
    local params = {choose_type = 2}
    local netCallback = function(response)
        if response and response.comeback_status == 2 then
            UserDataManager.comeback_status = 2
            if self.m_model.m_callback then
                self.m_model.m_callback(self.m_model.m_callback_new)
            end
            self:updateMsg("common_refresh", nil, "parent")
            self:closeView()
        end
    end
    self.m_model:getNetData("user_comeback_choose", params, netCallback)
end

return M
