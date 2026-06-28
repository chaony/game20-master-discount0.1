--- 好友
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/FriendList"

local __BTN_NODE = {
    {btn = "get_heart_btn"},
    {btn = "send_heart_btn"},
    {btn = "vs_btn"},
    {btn = "remove_black_btn"},
    {btn = "invite_btn"},
    {btn = "invite_friend_cheer_btn"},
}

function M:onCreate()
    self:setTextByLanKey("no_friend_text", "friend_str_0039")
    self:setTextByLanKey("common_no_have_text", "friend_str_0047")
    self:setTextByLanKey("num_text", "friend_str_0048")
    self:setTextByLanKey("give_btn_text", "friend_str_0049")
end

function M:onEnter()  
    self:refreshUI()
    self.m_sort_active = false
    self:setObjectVisible("give_btn", self.m_model.m_type == 0)
    self:setObjectVisible("heart_num_bg_img", self.m_model.m_type == 0)
    self:setObjectVisible("give_btn_text", self.m_model.m_type == 0)
    self:setObjectVisible("give_text", self.m_model.m_type == 0)
    if self.m_model.m_show_btn_list and next(self.m_model.m_show_btn_list) then --登仙楼 邀请好友助威
        self:setObjectVisible("share_with_world_btn",true)
        --self:setObjectVisible("one_click_share_btn",true)
    else
        self:setObjectVisible("share_with_world_btn",false)
        self:setObjectVisible("one_click_share_btn",false)
    end
end

function M:onButtonClick(obj, name)
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
    if name == "give_btn" then
        self.m_control:requestOneKeyGift()
    elseif name == "friend_manage_btn" then
        self.m_control:openView("Friend.FriendApplayPop")
    elseif name == "friend_sort_btn" then
        self.m_sort_active = not self.m_sort_active
        self:setObjectVisible("close_sort_btn", self.m_sort_active)
    elseif name == "close_sort_btn" then
        self.m_sort_active = false
        self:setObjectVisible("close_sort_btn", self.m_sort_active)
    elseif name == "sort_stage_btn" then
        self.m_sort_active = false
        self:setObjectVisible("close_sort_btn", self.m_sort_active)
        self.m_model:setFriendSort(1)
        self:refreshUI()
    elseif name == "sort_name_btn" then
        self.m_sort_active = false
        self:setObjectVisible("close_sort_btn", self.m_sort_active)
        self.m_model:setFriendSort(2)
        self:refreshUI()
    elseif name == "friend_help_btn" then
        local params = {}
        params.title = "tid#friend1"
        params.content = "tid#friend2"
        self.m_control:openView("Pops.CommonHelpPop", params)
    elseif name == "share_with_world_btn" then
        EventDispatcher:dipatchEvent("send_cheer_msg", {event = "world", data = self.m_model.m_friend_data.friends_info})
    elseif name == "one_click_share_btn" then
        EventDispatcher:dipatchEvent("send_cheer_msg", {event = "one_click", data = self.m_model.m_friend_data.friends_info})
    end
end

function M:refreshUI()
    local common = ConfigManager:getCfgByName("common")
    self:setText("friend_num_text", tostring(self.m_model.m_friend_num) .. "/" .. common[39].value)
    if self.m_model.m_friend_data == nil then
        return
    end
    self:setText("heart_num", self.m_model.m_friend_data.friend_coin)
    self:setText("give_text", Language:getTextByKey("friend_str_0004") .. self.m_model.m_friend_data.send_friend_coin_times .. "/" .. common[41].value)
    if self.m_model.m_friend_sort == 1 then
        self:findRectTransform("sort_select_image").localPosition = self:findRectTransform("sort_stage_btn").localPosition
    elseif self.m_model.m_friend_sort == 2 then
        self:findRectTransform("sort_select_image").localPosition = self:findRectTransform("sort_name_btn").localPosition
    end 
    self:updateFriendScroll()
    self:refreshRedPoint()
end

function M:updateFriendScroll()
    local data = self.m_model.m_friend_data.friends_info
    self:setObjectVisible("no_friend", #data <= 0)
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
            end,
            ui_name = self.m_uiName
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:setCellHander(obj, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = self.m_model:getFriendDataByIndex(id)
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    local online_time = luaBehaviour:FindText("online_time")
    GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 0.6})
    -- Logger.log(data,"getFriendDataByIndex ====")
    local name_text = UIUtil.setText(obj.transform, Language:getTextByKey(data.name), "name_text")
    local server_name = data.server_name
    --[[
    if tonumber(data.server) == 0 then
        server_name = UserDataManager.server_data:getServerName()
    else
        server_name = UserDataManager.server_data:getServerNameById(data.server)
    end
    ]]--
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_text_1", "new_str_0490")
    UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0089") .. server_name, "server_text")
    local power_text = UIUtil.setText(obj.transform, data.full_combat or 0, "power_text")
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
    
    local stage = ConfigManager:getCfgByName("stage")
    local stage_cfg = stage[data.stage]
    if stage_cfg then
        UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0124") .. ":" .. Language:getTextByKey(stage_cfg.map_point_name), "chapter_text")
    else
        UIUtil.setText(obj.transform, Language:getTextByKey("new_str_0124") .. ":0-0", "chapter_text")
    end

    local time_str = ""
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
        online_time.color = Color( 183/255, 65/255, 65/255)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "invite_btn", self.m_model.m_type == 1 and self.m_model.m_offline_invite == 1)
    else
        time_str = Language:getTextByKey("mail_str_0006")
        online_time.color = Color( 64/255, 118/255, 17/255)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "invite_btn", self.m_model.m_type == 1)
    end
    UIUtil.setText(obj.transform, time_str, "online_time")

    local send_heart_btn = luaBehaviour:FindButton("send_heart_btn") 
    send_heart_btn.interactable = data.send_status == 0
    
    local get_heart_btn = luaBehaviour:FindGameObject("get_heart_btn") 
    get_heart_btn:SetActive(data.receive_status ~= 0)
    get_heart_btn:GetComponent("Button").interactable = data.receive_status == 1
    local vs_btn = luaBehaviour:FindGameObject("vs_btn")
    vs_btn:SetActive(false)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"invite_friend_cheer_text","awake_system_text_0067")
    if self.m_model.m_show_btn_list and next(self.m_model.m_show_btn_list) then --登仙楼 邀请好友助威
        local temp = {}
        for k,v in ipairs(self.m_model.m_show_btn_list) do
            temp[v] = true
        end
        for k1,v1 in ipairs(__BTN_NODE) do
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,v1.btn ,temp[v1.btn])
        end
    end
end

function M:cellBtnHandle(name, itag)
    local data = self.m_model:getFriendDataByIndex(itag)
    if name == "cell_btn" then
        self.m_control:openView("Pops.PlayerInfo", {uid = data.uid, parent_view = "Friend"})
    elseif name == "vs_btn" then
        
    elseif name == "send_heart_btn" then
        self.m_control:requestSendGift(itag)
    elseif name == "get_heart_btn" then
        self.m_control:requestReceiveGift(itag)
    elseif name == "invite_btn" then
        self.m_control:requestInviteFriend(itag)
    elseif name == "invite_friend_cheer_btn" then
        self.m_control:requestInviteFriendCheer(itag)
    end
end

function M:refreshRedPoint()
    for k, v in pairs({ { "give_red_point_img", 4002 }, { "friend_red_point_img", 4001 }}) do
        local red_flag = RedPointUtil:hasRedPointById(v[2])
        self:setObjectVisible(v[1], red_flag == true)
    end
end

return M