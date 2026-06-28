local M = class("NationalBeautifulMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    --刷新红点
    elseif msg == "refresh_red_point" or msg == "refreshRedPoint" or msg == "refresh_data" then
        self.m_view:refreshRedPoint()
    elseif msg == "explain_btn" then
        local title_name = ""
        if self.m_model.active_data then
            title_name = self.m_model.active_data.name
        end
        self:openView("Pops.CommonHelpPop", {title = title_name, content = "tid#BeautyEvent"})
    else
        self:tryOpenItem(msg)
    end
end

function M:tryOpenItem(btn_name)
    local item = self.m_model:getItem(btn_name)
    if (self.m_model:getItemTimeLimit(btn_name) == 2 or self.m_model:getItemTimeLimit(btn_name) == 0) and not item.show_start_open then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
        return
    end
    if item then
        local show_active_data = self.m_model:getActiveData(item.open_id) or {}
        local version = self.m_model:getActVsn(item.open_id,item.is_recharge)
        local params = {
            is_token = self.m_model:getTokenFlag(),
            open_id = item.open_id,
            active_data = show_active_data,
            version = version,
            is_show = self.m_model:getItemTimeLimit(btn_name),
            refresh_main = "NationalBeautiful.NationalBeautifulMain",
            refresh_name = "NationalBeautiful.NationalBeautifulMain"}
        if item.open_id == 411 then --郿坞试炼
            params.is_show_break_btn = 1
        end
        self:openView(item.prefab_folder.."."..item.prefab_name, params)
    end
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end

return M
