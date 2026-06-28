--- 黑名单
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/FriendBlack"

function M:onCreate()
    self:setTextByLanKey("black_text", "friend_str_0050")
    self:setTextByLanKey("no_friend_text", "friend_str_0039")
    self:setTextByLanKey("common_no_have_text", "friend_str_0032")
    
end

function M:onEnter()  
    self.m_sort_active = false
    self:refreshUI()
end

function M:refreshUI()
    local common = ConfigManager:getCfgByName("common")
    self:setText("black_num_text", "0/" .. common[42].value)
    self:updateListScroll()
end

function M:updateListScroll()
    local num,data = self.m_model:getListNum()
    if num == nil and data == nil then
        return
    end
    if num == 0 then
        self:setObjectVisible("no_friend", true)
        self:setObjectVisible("btn_panel", false)
    else
        self:setObjectVisible("no_friend", false)
        self:setObjectVisible("btn_panel", true)
    end
    local common = ConfigManager:getCfgByName("common")
    self:setText("black_num_text", tostring(num).."/" .. common[42].value)
    if self.m_list_scroll == nil then
        
        local list_scroll = self:findGameObject("friend_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:cellBtnHandle(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, id)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = self.m_model:getDataByIndex(id)
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 0.6})
    local power_text = UIUtil.setText(obj.transform, data.full_combat, "power_text")
    local server_name = data.server_name
    --[[
    if tonumber(data.server) == 0 then
        server_name = UserDataManager.server_data:getServerName()
    else
        server_name = UserDataManager.server_data:getServerNameById(data.server)
    end
    ]]--
    UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0089") .. server_name, "server_text")
    local time_str = ""
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_text_1", "friend_str_0041")
    if data.is_online == 0 then
        local time = UserDataManager:getServerTime() - data.last_active_time
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
        if day > 0 then
            time_str = string.format(Language:getTextByKey("mail_str_0002"),day)
        elseif hour > 0 then
           time_str = string.format(Language:getTextByKey("mail_str_0003"),hour)
        elseif min > 0 then
            time_str = string.format(Language:getTextByKey("mail_str_0004"),min)
        else
            time_str = Language:getTextByKey("mail_str_0005")
        end
        UIUtil.setTextColor(obj.transform, Color( 183/255, 65/255, 65/255), "online_time")
    else
        time_str = Language:getTextByKey("mail_str_0006")
        UIUtil.setTextColor(obj.transform, Color( 64/255, 118/255, 17/255), "online_time")
    end
    local stage = ConfigManager:getCfgByName("stage")
    local stage_cfg = stage[data.stage]
    if stage_cfg then
        UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0124") .. ":" .. Language:getTextByKey(stage_cfg.map_point_name), "chapter_text")
    else
        UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0124") .. ":0-0", "chapter_text")
    end
    UIUtil.setText(obj.transform, time_str, "online_time")
    local name_text = UIUtil.setText(obj.transform, Language:getTextByKey(data.name), "name_text")
	UIUtil.setTextByLanKey(obj.transform, "remove_black_btn/remove_black_btn_text", "friend_str_0014")
    local remove_black_btn = UIUtil.findButton(obj.transform,"btns/remove_black_btn")
    if remove_black_btn then
        remove_black_btn.interactable = true
    end
    UIUtil.setObjectVisible(obj.transform, false, "add_btn")
    UIUtil.setObjectVisible(obj.transform, false, "remove_btn")
    UIUtil.setObjectVisible(obj.transform, true, "remove_black_btn")

    local power_text_1 = UIUtil.findText(obj.transform,"power_text_1")
    local title_id = data.title
    if title_id and title_id ~= 0 then
        name_text.transform.anchoredPosition = Vector3.New(141,0,0)
        power_text.transform.anchoredPosition = Vector3.New(-110,-30,0)
        power_text_1.transform.anchoredPosition = Vector3.New(-198,-30,0)
    else
        name_text.transform.anchoredPosition = Vector3.New(141,17,0)
        power_text.transform.anchoredPosition = Vector3.New(-110,-20,0)
        power_text_1.transform.anchoredPosition = Vector3.New(-198,-20,0)
    end
end

function M:cellBtnHandle(name, itag)
    if name == "remove_black_btn" then
    	if self.m_model.m_friend_tab_index == 3 then
    		self:updateMsg("send_apply_friend", itag)
		elseif self.m_model.m_friend_tab_index == 4 then
			self:updateMsg("remove_black", itag)
		end
    end
end

function M:onButtonClick(obj, name)
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
    if name == "find_btn" then
        self:updateMsg("find_btn")
    end
end

return M