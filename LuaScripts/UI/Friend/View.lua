local M = class("FriendPopView", LikeOO.OOPopBase)

M.m_uiName = "Friend/FriendPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn = "friend_toggle", text = "friend_toggle_text", language = "friend_str_0001", lua_name = "UI.Friend.FriendNode", red_point_img = "friend_red_point_img", red_point_id = 1301},
    {btn = "mercenary_toggle", text = "mercenary_toggle_text", language = "friend_str_0002", lua_name = "UI.Friend.MercenaryNode", red_point_img = "mercenary_red_point_img", red_point_id = 48},
    {btn = "master_apprentice_toggle", text = "master_toggle_text", language = "master_apprentice_str_0020", lua_name = "UI.Friend.MasterApprenticeNode", red_point_img = "master_apprentice_red_point_img", red_point_id = 51},
    {btn = "mail_toggle", text = "mail_toggle_text", language = "mail_str_0015", lua_name = "UI.Friend.MailNode", red_point_img = "mail_red_point_img", red_point_id = 69},
    {btn = "gamenotice_toggle", text = "gamenotice_toggle_text", language = "union_str_1046", lua_name = "UI.Notice.InGameNoticePop", red_point_img = "gamenotice_red_point_img"}
}

function M:onEnter()
    self.toggle_panel = self:findGameObject("toggle_panel")
    self.child_panel = self:findGameObject("child_panel")
    self.master_apprentice_toggle = self:findGameObject("master_apprentice_toggle")
    self.mercenary_toggle = self:findGameObject("mercenary_toggle")
    self.mail_toggle = self:findGameObject("mail_toggle")
    self.gamenotice_toggle = self:findGameObject("gamenotice_toggle")
    self.gamenotice_toggle:SetActive(false)
    self.master_apprentice_toggle:SetActive(false )
    self.mercenary_toggle:SetActive(false)
    for i, v in ipairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.text, v.language)
        self:setTextColor(v.text, self.m_model.m_tab_index == i and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24)
        local tog_btn = self:findToggle(v.btn)
        UIUtil.addToggleListener(
            tog_btn,
            function(is_on, data)
                if is_on then
                    self:updateMsg("tab_btn", data)
                    self:setTextColor(__TAB_BTN_NODE[data].text, GlobalConfig.COMMON_COLLOR.COMMON_25)
                else
                    self:setTextColor(__TAB_BTN_NODE[data].text, GlobalConfig.COMMON_COLLOR.COMMON_24)
                end
            end,
            i,
            self.m_uiName
        )
        self:setObjectVisible(v.red_point_img, false)
    end
    self:AddChildPanel()
    self.m_control:freshBaseData()
end

function M:refreshUI()
    if self.m_model.m_tab_index == 1 then
        self:setText("common_title_text", Language:getTextByKey("friend_str_0001"))
    elseif self.m_model.m_tab_index == 2 then
        self:setText("common_title_text", Language:getTextByKey("friend_str_0002"))
    elseif self.m_model.m_tab_index == 3 then
        self:setText("common_title_text", Language:getTextByKey("master_apprentice_str_0030"))
    elseif self.m_model.m_tab_index == 4 then
        self:setText("common_title_text", Language:getTextByKey("mail_str_0015"))
    end
    self:setText("common_title_text", Language:getTextByKey("mail_str_0016"))
    self.mercenary_toggle:SetActive(self.m_model.m_unlock_mercenary == true and self.m_model.m_type == 0)
    self.mail_toggle:SetActive(self.m_model.m_type == 0)
    --self.gamenotice_toggle:SetActive(self.m_model.m_type == 0)
    self.m_cur_tab_node:refreshUI()
    self:refreshRedPoint()
end

function M:AddChildPanel()
    -- Logger.log(self.m_model.m_tab_index, "self.m_model.m_tab_index == ")
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end

    local btn_tab = __TAB_BTN_NODE[self.m_model.m_tab_index]
    if btn_tab then
        local tog_btn = self:findToggle(btn_tab.btn)
        tog_btn.isOn = true
        if btn_tab.btn ~= "gamenotice_toggle" then
            local tab_cls = CustomRequire(btn_tab.lua_name)
            self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.child_panel})
        end
        
    end
end

function M:switchFriendTab(data)
    if self.m_cur_tab_node and self.m_model.m_tab_index == 1 then
        self.m_cur_tab_node:AddChildPanel(data)
    end
end

function M:switchFriendTab(data)
    if self.m_cur_tab_node and self.m_model.m_tab_index == 1 then
        self.m_cur_tab_node:AddChildPanel(data)
    end
end

function M:refreshRedPoint()
    for k, v in pairs(__TAB_BTN_NODE) do
        local red_flag = RedPointUtil:isFuncRedPointById(v.red_point_id)
        if v.red_point_id == 1301 then
            red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
        end
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end
end

function M:getSearchText()
    if self.m_cur_tab_node and self.m_model.m_tab_index == 1 and self.m_cur_tab_node.getSearchText then
        return self.m_cur_tab_node:getSearchText()
    end
    return nil
end

function M:setSearchText(text)
    if self.m_cur_tab_node and self.m_model.m_tab_index == 1 and self.m_cur_tab_node.setSearchText then
        self.m_cur_tab_node:setSearchText(text)
    end
end

return M