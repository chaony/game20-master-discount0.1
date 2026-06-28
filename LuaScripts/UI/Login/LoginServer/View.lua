local M = class("LoginServerView",LikeOO.OOPopBase)

M.m_uiName = "Login/LoginServer"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0663")
    self:setTextByLanKey("sign_in_title_text", "new_str_0667")
    self:setTextByLanKey("top_title_text", "new_str_0672")
    self:setTextByLanKey("top_status_text_1", "new_str_0673")
    self:setTextByLanKey("top_status_text_2", "new_str_0674")
    self:setTextByLanKey("top_status_text_3", "new_str_0675")
    self:setTextByLanKey("top_status_text_4", "new_str_0676")
    self:setTextByLanKey("new_server_tips_text", "new_str_1073")
    self:setObjectVisible("new_server_tips_text", false)
    self:refreshUI()
end

function M:refreshUI(keep_offset)
    --local server_data = self.m_model:getLastLoginServerData()
    local server_data = self.m_model:getLastServerInfo()
    if server_data[1] ~= nil and server_data[1].zone ~= nil then
        --self:setTextByLanKey("top_server_name_text", server_data.server_name)
        self:setTextByLanKey("top_server_name_text", server_data[1].zone.server_name)
    else
        self:setTextByLanKey("top_server_name_text","legend_str_019" )
    end
    self:createMenuLoopScroll()
    self:createSignInLoopScroll()
    self:updateServer(keep_offset)
end

function M:updateServer(keep_offset)
    self:setTextByLanKey("server_title_text", self.m_model.m_sel_menu_index == 1 and "new_str_0668" or "new_str_0669")
    self:createLoopScroll(keep_offset)
end


function M:createMenuLoopScroll()
    local data = self.m_model:getMenuData()
    self.m_sel_cell = nil
    if self.m_menu_list_scroll == nil then
        local list_scroll = self:findGameObject("menu_list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "current_img", self.m_model.m_sel_menu_index == index)
                if self.m_model.m_sel_menu_index == index then
                    self.m_sel_cell = cell_object
                end
                local name_text = LuaBehaviourUtil.setText(luaBehaviour, "name_text", data.zone_name)
                local name_text2 = LuaBehaviourUtil.setText(luaBehaviour, "name_text2", data.zone_name)
                name_text.gameObject:SetActive(index == 1)
                name_text2.gameObject:SetActive(index ~= 1)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if  self.m_model.m_sel_menu_index ~= index then
                    if self.m_sel_cell then
                        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "current_img", false)
                    end
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "current_img", true)
                    self.m_model.m_sel_menu_index = index
                    self.m_sel_cell = cell_object
                    self:updateMsg("menu_btn", cell_data)
                end
            end
        }
        self.m_menu_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_menu_list_scroll:reloadData(data,true)
    end
end

function M:createSignInLoopScroll()
    local data = self.m_model:getLastServerInfo()
    if self.m_sign_in_list_scroll == nil then
        local list_scroll = self:findGameObject("sign_in_list_scroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local current_img = luaBehaviour:FindGameObject("current_img")
                local zone = data.zone or {}
                local role = data.role or {}
                current_img:SetActive(self.m_model.m_server == zone.server)
                LuaBehaviourUtil.setText(luaBehaviour, "name_text", zone.server_name)
                LuaBehaviourUtil.setText(luaBehaviour, "player_name_text", role.name or "")
                LuaBehaviourUtil.setText(luaBehaviour, "uid_text", role.uid)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_img", false)
                local statue_name = self:setttingStatusImg(zone.is_open,zone.flag)
                LuaBehaviourUtil.setImg(luaBehaviour,"status_img",statue_name,"login_ui")
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_server", cell_data.zone)
            end
        }
        self.m_sign_in_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_sign_in_list_scroll:reloadData(data)
    end
end

function M:createLoopScroll(keep_offset)
    local data = self.m_model:getShowServerData()
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local server_data = cell_data
                local role_data = cell_data
                if cell_data.role == nil then
                    server_data = cell_data
                else
                    server_data = cell_data.zone
                    role_data = cell_data.role
                end
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                --Logger.log(data, "createLoopScroll data ========")
                local current_img = luaBehaviour:FindGameObject("current_img")
                --current_img:SetActive(self.m_model.m_server == data.server)
                current_img:SetActive(false)
                LuaBehaviourUtil.setText(luaBehaviour, "name_text", role_data.server_name)
                local roleName = role_data.name or ""
                if role_data.level then
                    roleName = roleName .. " Lv." .. tostring(role_data.level)
                end
                LuaBehaviourUtil.setText(luaBehaviour, "player_name_text", roleName)
                LuaBehaviourUtil.setText(luaBehaviour, "uid_text", role_data.uid)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_img", false)
                local statue_name = self:setttingStatusImg(server_data.is_open,server_data.flag)
                LuaBehaviourUtil.setImg(luaBehaviour,"status_img",statue_name,"login_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recommend", "new_str_1143")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recommend", server_data.recommend and server_data.recommend == 1)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_server", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,keep_offset)
    end
end

--获取火爆信息对饮的图片名称
--[[
function M:setttingStatusImg(is_open,flag)
    local status_img_name = "a_dl_icon_liuchang"
    if is_open == "Online" then --在线
        if flag == "Idle" then
            status_img_name = "a_dl_icon_liuchang"
        elseif flag == "Busy" then
            status_img_name = "a_dl_icon_manglu"
        elseif flag == "Full" then
            status_img_name = "a_dl_icon_huobao"
        end
    elseif is_open == "InMaintenance" then
        status_img_name = "a_dl_icon_weihu"
    end
    return status_img_name
end
]]--

function M:setttingStatusImg(is_open,flag)
    local status_img_name = "a_dl_icon_liuchang"
    if is_open == 1 then --在线
        if flag == 0 or flag == 1 then
            status_img_name = "a_dl_icon_liuchang"
        elseif flag == 2 then
            status_img_name = "a_dl_icon_manglu"
        elseif flag == 3 then
            status_img_name = "a_dl_icon_huobao"
        end
    elseif is_open == 0 then
        status_img_name = "a_dl_icon_weihu"
    end
    return status_img_name
end

return M