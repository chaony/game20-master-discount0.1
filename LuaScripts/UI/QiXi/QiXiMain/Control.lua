local M = class("QiXiMainControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    --刷新红点
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "explain_btn" then
        local active_data = self.m_model:getActiveData() or {}
        self:openView("Pops.CommonHelpPop", {title = active_data.name or "", content = "tid#ValentineFestival_1"})
    else
        self:tryOpenItem(msg)
    end
end

function M:tryOpenItem(btn_name)
    if self.m_model:getItemTimeLimit(btn_name) == 2 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
        return
    end

    local item = self.m_model:getItem(btn_name)
    if item then
        if item.open_id == 375 then --团购狂欢
            local function netCallback(response)
                if response.update then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    self:closeView()
                    return
                end
                if response["end"] then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    self:closeView()
                    return
                end
                response.is_token = self.m_model:getTokenFlag()
                self:openView("QiXi." .. item.prefab_name, response)
            end
            self.m_model:getNetData("valentine_festival_box_index", nil, netCallback)
        else
            self:openView("QiXi." .. item.prefab_name, {is_token = self.m_model:getTokenFlag()})
        end
    end
end

return M
