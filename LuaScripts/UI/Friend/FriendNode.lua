--- 好友
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/FriendPanel"

local __TAB_BTN_NODE = {
    {btn = "friend_toggle", text = "friend_toggle_text", language = "friend_str_0042", lua_name = "UI.Friend.FriendListNode", red_point_img = "friend_red_point_img", red_point_id = 1303},
    {btn = "add_toggle", text = "add_toggle_text", language = "friend_str_0012", lua_name = "UI.Friend.FriendApplyNode", red_point_img = "add_red_point_img", red_point_id = 1302},
    {btn = "apply_toggle", text = "apply_toggle_text", language = "friend_str_0043", lua_name = "UI.Friend.FriendAddNode", red_point_img = "apply_red_point_img"},
    {btn = "black_toggle", text = "black_toggle_text", language = "friend_str_0018", lua_name = "UI.Friend.FriendBlackNode", red_point_img = "black_red_point_img"}
}

function M:onEnter()  
    self.node_panel = self:findGameObject("node_panel")
    for i, v in ipairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.text, v.language)
        local tog_btn = self:findToggle(v.btn)
        UIUtil.addToggleListener(
            tog_btn,
            function(is_on, data)
                if is_on then
                    self:updateMsg("friend_tab_btn", data)
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
    local red_add = self:findGameObject("add_red_point_img")
    UIUtil.setLocalPosition(red_add.transform, 82.6, -10,0)
    self:AddChildPanel(1)
end


function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
    self:refreshRedPoint()
end

function M:AddChildPanel(data)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    self.m_model.m_friend_tab_index = data
    local btn_tab = __TAB_BTN_NODE[self.m_model.m_friend_tab_index]
    if btn_tab then
        local tog_btn = self:findToggle(btn_tab.btn)
        tog_btn.isOn = true
        local tab_cls = CustomRequire(btn_tab.lua_name)
        self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.node_panel})
    end
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    for k, v in pairs(__TAB_BTN_NODE) do
        local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end
end

function M:getSearchText()
    if self.m_cur_tab_node then
        return self.m_cur_tab_node:getSearchText()
    end
end

function M:setSearchText(text)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:setSearchText(text)
    end
end

return M