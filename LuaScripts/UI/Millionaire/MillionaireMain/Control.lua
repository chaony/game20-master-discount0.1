local M = class("MillionaireMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "explain_btn" then
        local title_name = ""
        if self.m_model.active_data then
            title_name = self.m_model.active_data.name
        end
        self:openView("Pops.CommonHelpPop", {title = title_name, content = "tid#monopoly_explain"})
    elseif msg == "streetfood_goto" then
       self:openItem(1)
    elseif msg == "Inn_goto" then
        self:openItem(2)
    elseif msg == "tavern_goto" then
        self:openItem(3) 
    elseif msg == "refresh_ui" then
        self.m_model:updateServerData(data.data)
        self.m_view:refreshUI()
    elseif msg == "refresh_red" then
        self.m_view:refreshUI()
    end
end

--打开二级页签
function M:openItem(id)
    local red_key = self.m_model:getRedPointKey(id)
    if red_key then
        RedPointUtil:saveLocalRedPointFreshTime(red_key)
    end
    if self.m_model.is_show_time then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("millionaire_text_014"), delay_close = 2})
        return
    end
    self:openView("Millionaire.MillionairePop",{id = id,data = self.m_model.m_data})
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end

return M
