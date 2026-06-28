local M = class("ReportPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "select_toggle" then
        self.m_model:setReportIndex(data)    
    elseif msg == "report_btn" then
        self:reportRequest()
    end
end

function M:reportRequest()
    if self.m_model.m_report_id == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("report_str_0007"), delay_close = 2})
        return
    end

    local other_text = self.m_view:getOtherDes()
    if self.m_model.m_report_type == "12_1" then -- 选项其他
        if other_text == nil or other_text == "" then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("report_str_0008"), delay_close = 2})
            return
        end
    end
    
    local params = {}
    params.report_uid = self.m_model.m_uid
    params.report_type = self.m_model.m_report_type
    params.chat_content = self.m_model.m_chat
    params.report_content = other_text
    local detail = {}
    detail.module_id = self.m_model.m_module_id
    params.report_detail = Json.encode(detail)

    local function callback()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("report_str_0009"), delay_close = 2})
        self:closeView()
    end
    self.m_model:getNetData("bytedance_report", params, callback)
end

return M;
