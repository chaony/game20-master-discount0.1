local M = class("ReportPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/ReportPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {toggle = "Toggle_1", name = "toggle_text_1", text = "report_str_0001",},
    {toggle = "Toggle_2", name = "toggle_text_2", text = "report_str_0002",},
    {toggle = "Toggle_3", name = "toggle_text_3", text = "report_str_0003",},
    {toggle = "Toggle_4", name = "toggle_text_4", text = "report_str_0004",},
    {toggle = "Toggle_5", name = "toggle_text_5", text = "report_str_0005",},
}

function M:onEnter()
    self:setTextByLanKey("common_title_text", "report_str_0011")
    self:setTextByLanKey("report_btn_text", "report_str_0006")
    self:setTextByLanKey("name_text", "report_str_0010", self.m_model.m_user_name)
    self:setTextByLanKey("des_title_text", "reportPop_des_title_text")
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.toggle)
        local item = self:findGameObject(v.toggle)
        self:setTextByLanKey(v.name, v.text)
        UIUtil.addToggleListener(tog_btn, function(is_on, data)
            if is_on then
                self:updateMsg("select_toggle",data)
            end
        end, i, self.m_uiName)
    end

    self.des_text = self:findInputField("des_text")
    self.des_text.placeholder.text = ""
    self.des_text.text = ""
    self:refreshUI()
end

function M:refreshUI()
    
end

function M:getOtherDes()
    local text = GameUtil:formatInputText(self.des_text.text)
    return text
end

return M
