--- 英雄
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/MailPanel"

function M:onCreate()
    
end

function M:onEnter()
    self.rewards_image = self:findGameObject("rewards_image")
    self.get_btn = self:findGameObject("get_btn")
    self.get_img = self:findGameObject("get_img")
    self.no_text = self:findGameObject("no_text")
    self.detail_panel = self:findGameObject("detail_panel")
    self:setTextByLanKey("get_btn_text", "new_str_0056")
    self:setTextByLanKey("no_text", "mail_str_0014")
    self:setTextByLanKey("common_no_have_text", "mail_str_0014")
    self:setTextByLanKey("common_title_text", "mail_str_0015")
    self:setTextByLanKey("fast_remove_text", "mail_str_0018")
    self:setTextByLanKey("fast_get_text", "mail_str_0017")
    self.detail_title_text = self:findGameObject("detail_title_text")
    self.text_scroll = self:findGameObject("text_scroll")
    self.m_model:setSelectIndex(0)
    self.m_select_cell_index = 1
end

function M:onButtonClick(obj, name)
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
    if name == "fast_get_btn" then
        if #self.m_model.m_mail_list_data == 0 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0591"), delay_close = 2})
            return
        end
        self.m_control:receiveAllMail()
    elseif name == "fast_remove_btn" then
        if #self.m_model.m_mail_list_data == 0 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0591"), delay_close = 2})
            return
        end
        local params =
        {
            on_ok_call = function(msg)
                self.m_control:deleteAllMail()
            end,
            on_cancel_call = function (msg)

            end,
            no_close_btn = false,
            text = Language:getTextByKey("mail_str_0008")
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif name == "get_reward_btn" then
        local data = self.m_model:getMailByIndex(self.m_model.m_mail_select_index)
        local need_rebot, need_jump, url_str = self:checkPlatformAndVersion(data)
        if need_jump then
            SDKUtil:openUrl(url_str)
        elseif need_rebot then
            GameMain.reStart()
        elseif data.is_received == false then
            self.m_control:receiveMail(data.id)
        end
    end
end

function M:cellBtnHandle(name, itag)
    if name == "open" then
        self.m_model:setSelectIndex(itag)
        self:updateListScroll()
    end
end

function M:refreshUI()
    self:updateListScroll()
    self:setObjectVisible("CommonTipsNode",#self.m_model.m_mail_list_data == 0)
    self:setObjectVisible("left_count",not(#self.m_model.m_mail_list_data == 0))
end

function M:updateListScroll()
    local data = self.m_model.m_mail_list_data
    self.m_model:setSelectIndex(self.m_select_cell_index)
    self:updateRightCount(self.m_select_cell_index)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", self.m_select_cell_index == index)
            end,
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
                self:updateMsg("load_mail")

            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self.m_select_cell_index = index
                self:cellBtnHandle("open", self.m_select_cell_index)

            end,
            ui_name = self.m_uiName,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
        if self.m_control.m_mail_load == true then
            self:pullRefreshListOffset()
        end
    end
end

function M:pullRefreshListOffset()
    self.now_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
    --local position = self.m_list_scroll:getVerticalNormalizedPosition()
    local position = (self.last_offsety - self.now_offsety) / self.m_list_scroll.m_scroll_rect.content.rect.height
    self.m_list_scroll:setVerticalNormalizedPosition(position)
    self.m_control.m_mail_load = false
end

function M:listHandle(obj,id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
    local title_text = luaBehaviour:FindText("title_text")
    local received_img = luaBehaviour:FindGameObject("received_img")
    local select_img = luaBehaviour:FindGameObject("select_img")
    select_img:SetActive(id == self.m_model.m_mail_select_index)
    local data = self.m_model:getMailByIndex(id)
    local key, content
    for k,v in pairs(data.content) do
        if k == "text_content" or k == "language_content" or k == "format_content" then
            key = k
            content = v
        end
    end
    if key == "text_content" then
        title_text.text = content.mail_title
    elseif key == "language_content" then
        title_text.text = Language:getTextByKey(content.mail_title)
    elseif key == "format_content" then
        local mail_cfg = ConfigManager:getCfgByName("mail")
        local cfg = mail_cfg[content.config_id]
        if cfg then
            title_text.text = Language:getTextByKey(cfg.title)
        end
    end
    local time = UserDataManager:getServerTime() - data.create_ts
    local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
    if day > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0002"),day), "time_text")
    elseif hour > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0003"),hour), "time_text")
    elseif min > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0004"),min), "time_text")
    else
        UIUtil.setText(obj.transform, Language:getTextByKey("mail_str_0005"), "time_text")
    end

    time = data.expire_ts - UserDataManager:getServerTime()
    day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
    if day > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0009"),day), "rem_time_text")
    elseif hour > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0010"),hour), "rem_time_text")
    elseif min > 0 then
        UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0011"),min), "rem_time_text")
    else
        UIUtil.setText(obj.transform, Language:getTextByKey("mail_str_0012"), "rem_time_text")
    end
    if data.status == 0 then
        if #data.gift > 0 then
            UIUtil.setImg(obj.transform, "a_yx_icon_jiangli", "common_ui", "icon_image")
        else
            UIUtil.setImg(obj.transform, "a_yx_weikaiqi", "common_ui", "icon_image")
        end
    else
        UIUtil.setImg(obj.transform, "a_yx_kaiqi", "common_ui", "icon_image")
    end

    local reward_content = luaBehaviour:FindGameObject("reward_content")
    UIUtil.destroyAllChild(reward_content.transform)
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    if #data.gift > 0 then
        red_point_img:SetActive(data.is_received == false)
        received_img:SetActive(data.is_received == true)
        for i,v in ipairs(data.gift) do
            if v[4] then
                v.quality = v[4]
                v[4] = nil
            end
        end
        GameUtil:createRewards(reward_content.transform, data.gift, true, true, nil, 1)
    else 
        red_point_img:SetActive(data.status == 0)
        received_img:SetActive(data.status ~= 0)
    end
end

function M:updateRightCount(index)
    if  #self.m_model.m_mail_list_data == 0 or self.m_model.m_mail_select_index == 0 then
        self:setObjectVisible("right_count", false)
        return
    end
    self:setObjectVisible("right_count", true)
    local index = self.m_model.m_mail_select_index or 1
    local data = self.m_model:getMailByIndex(index)
    local key, content
    if data == nil then
        return
    end
    for k,v in pairs(data.content) do
        if k == "text_content" or k == "language_content" or k == "format_content" then
            key = k
            content = v
        end
    end
    if data.status == 0 then
        self.m_control:openMail(index)
    end
    local need_rebot, need_jump, url_str = self:checkPlatformAndVersion(data)
	if key == "text_content" then
		self:setText("mail_title", content.mail_title or "")
		self:setText("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
			self:setObjectVisible("send_text", false)
		else
            self:setObjectVisible("send_text", true)
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. content.mail_from)
		end
	elseif key == "language_content" then
		self:setTextByLanKey("mail_title", content.mail_title or "")
		self:setTextByLanKey("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
			self:setObjectVisible("send_text", false)
		else
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(content.mail_from))
		end
	elseif key == "format_content" then
		local mail_cfg = ConfigManager:getCfgByName("mail")
		local cfg = mail_cfg[content.config_id]
		if cfg then
			self:setText("mail_title", Language:getTextByKey(cfg.title))
			if cfg.sender == nil or cfg.sender == "" then
				self:setText("send_text", "")
				self:setObjectVisible("send_text", false)
			else
				self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(cfg.sender))
			end
			
			local newText = GameUtil:formatTextString(Language:getTextByKey(cfg.content), content.params)
			self:setText("des_text", newText)
		end
	end
	local des_text = self:findText("des_text")
	des_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
    --
    local time_str = os.date(Language:getTextByKey("mail_str_0019"), data.create_ts)
    self:setText("mail_time", time_str)

    if #data.gift > 0 then
        
    else    
    end
    local reward_content = self:findGameObject("mail_reward_content")
    UIUtil.destroyAllChild(reward_content.transform)
    if #data.gift > 0 then
        for i,v in ipairs(data.gift) do
            if v[4] then
                v.quality = v[4]
                v[4] = nil
            end
        end
        local final_data = {}
        RewardUtil:mergeCfgReward(final_data,data.gift)
        GameUtil:createRewards(reward_content.transform, final_data, true, true, nil, 1)
        if need_jump then
            self:setTextByLanKey("get_reward_btn_text", "new_str_0952")
            self:setImg("a_ui_currency_btn_middle_2", "common_ui", "get_reward_btn")
        elseif need_rebot then
            self:setTextByLanKey("get_reward_btn_text", "new_str_0953")
            self:setImg("a_ui_currency_btn_middle_2", "common_ui", "get_reward_btn")
        elseif data.is_received == true then
            self:setTextByLanKey("get_reward_btn_text", "new_str_0080")
            self:setImg("a_ui_currency_btn_middle_3", "common_ui", "get_reward_btn")
        else
            self:setTextByLanKey("get_reward_btn_text", "new_str_0056")
            self:setImg("a_ui_currency_btn_middle_2", "common_ui", "get_reward_btn")
        end
        self:setObjectVisible("get_reward_btn", true)
    else
        self:setObjectVisible("get_reward_btn", false)
    end
end

function M:checkPlatformAndVersion(mail_content)
    local url_str = "" --强更地址
    local need_jump = false --是否跳转到强更地址
    local need_rebot = false --是否重启游戏
    local content = mail_content
    if content and ((content.cli_ver and content.cli_ver ~= "") or (content.ios_cli_ver and content.ios_cli_ver ~= "")) then
        local platform = GameUtil:getpPlatform()
        local b_version = GameVersionConfig.BYTE_DANCE_SERVER_VERSION
        local r_version = GameVersionConfig.GAME_RESOURCES_VERION
        local ori_b_version, ori_r_version = "", "" --服务器字节版本号， 服务器资源版本号
        if platform == "Ios" then
            ori_b_version = content.ios_cli_ver
            ori_r_version = content.ios_r_ver
            url_str = content.ios_url
        elseif platform == "Android" or platform == "Windows" then
            ori_b_version = content.cli_ver
            ori_r_version = content.r_ver
            url_str = content.url
        end
        if self:compareResourceVersion(b_version, ori_b_version) then -- 当前版本大于等于服务器版本
        else
            need_jump = true
        end
        if self:compareResourceVersion(r_version, ori_r_version) then -- 当前资源版本大于等于服务器资源版本
        else
            need_rebot = true
        end
    end
    return need_rebot, need_jump, url_str
end

-- 对比版本号
function M:compareResourceVersion(ver1, ver2)
    local ver1_tab = string.split(ver1, ".")
    local first_version1 = tonumber(string.sub(ver1_tab[1], 2)) or 0
    local second_version1 = tonumber(ver1_tab[2]) or 0
    local third_version1 = tonumber(ver1_tab[3]) or 0
    local ver2_tab = string.split(ver2, ".")
    local first_version2 = tonumber(string.sub(ver2_tab[1], 2)) or 0
    local second_version2 = tonumber(ver2_tab[2]) or 0
    local third_version2 = tonumber(ver2_tab[3]) or 0
    if first_version1 == first_version2 then
        if second_version1 == second_version2 then
            return third_version1 >= third_version2
        else
            return second_version1 > second_version2
        end
    else
        return first_version1 > first_version2
    end
end

return M