local M = class("UnionMainPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionMainPop"

M.m_size_type = 2 -- 1隐藏下层ui，2不隐藏

function M:onEnter()
	self:setTextByLanKey("common_title_text", "union_str_0001")
	self:setTextByLanKey("common_title_text2", "union_str_0051")
	self:setTextByLanKey("president_text", "union_str_0009")
	self:setTextByLanKey("uid_text", "union_str_1018")
	self:setTextByLanKey("member_text", "union_str_0010")
	self:setTextByLanKey("activation_text", "union_str_1019")
	self:setTextByLanKey("manor_text", "union_str_1020")
	self:setTextByLanKey("union_text", "union_str_0044")
	self:setTextByLanKey("notice_title_text", "union_str_0045")
	self:setTextByLanKey("shenlu_btn_text", "union_str_1040")

	self:setTextByLanKey("impeach_btn_text", "union_str_0059")
	self:setTextByLanKey("applyes_btn_text", "union_str_0030")
	self:setTextByLanKey("notice_set_btn_text", "union_str_0031")
	self:setTextByLanKey("info_set_btn_text", "union_str_0032")
	self:setTextByLanKey("mail_btn_text", "union_str_0033")
	self:setTextByLanKey("find_union_btn_text", "union_str_0034")
	self:setTextByLanKey("exit_union_btn_text", "union_str_0035")

	self:setTextByLanKey("give_btn_text", "union_str_0011")
	self:setTextByLanKey("management_btn_text", "union_str_0053")
	self:setTextByLanKey("shop_btn_text", "union_str_0054")
	self:setTextByLanKey("log_btn_text", "union_str_0055")
	self:setTextByLanKey("member_btn_text", "union_str_0010")
	self:setTextByLanKey("unionwar_btn_text", "tid#GuildWar_2")
	self:setTextByLanKey("union_tips_text", "tid#SystemCaution_1")
	
	self.applyes_btn = self:findGameObject("applyes_btn")
	self.notice_set_btn = self:findGameObject("notice_set_btn")
	self.info_set_btn = self:findGameObject("info_set_btn")
	self.mail_btn = self:findGameObject("mail_btn")
	self.impeach_btn = self:findGameObject("impeach_btn")
	self.management_close_btn = self:findGameObject("management_close_btn")
	self.score_slider = self:findSlider("score_slider")
	self.notice_btn = self:findButton("notice_btn")
	self.gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
	local guild_data,cfg = self.m_model:getUnionData()

	-- Logger.log(guild_data,"guild_data ====")
	self:setText("union_name_text", guild_data.name)
	self:setText("union_lv_text", string.format(Language:getTextByKey("new_str_0075"), guild_data.level))
	self:setText("member_num_text", tostring(#self.m_model.m_list_data) .. "/" .. cfg.number)
	self:setText("union_number_text", guild_data.id)
	self:setText("activation_value_text", guild_data.exp)
	self:setText("manor_value_text", guild_data.id)
	self:setText("slider_text", tostring(guild_data.exp) .. "/" .. cfg.exp)
	local des = guild_data.desc
	if des == nil or des == "" then
		des = Language:getTextByKey("union_str_1050")
	end
	des = GameUtil:formatInputText(des)
	self:setText("notice_text", des)
	self.score_slider.value = guild_data.exp/cfg.exp
	local self_union_data = self.m_model:getSelfUnionData()
	--self.upgrade_union_btn:SetActive(self_union_data.position < 3)
	self.impeach_btn:SetActive(self.m_model:isShowImpeachBtn())
	self.applyes_btn:SetActive(self_union_data.position < 3)
	self.notice_set_btn:SetActive(self_union_data.position < 3)
	self.info_set_btn:SetActive(self_union_data.position < 3)
	self.mail_btn:SetActive(self_union_data.position < 3)
	self.notice_btn.interactable = self_union_data.position < 3
	local president = self.m_model:getPresidentData()
	if president and president.name then
		self:setText("president_name_text", president.name)
	else
		self:setText("president_name_text", "---")
	end
	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[guild_data.flag]
	if flag_cfg then
		--self:setImg(flag_cfg.icon, "maze_stage_ui", "emblem_img")
		local emblem_img = self:findImage("emblem_img")
		GameUtil:updateResourcesImg(emblem_img, "Texture/union_emblem/" .. flag_cfg.icon)
	end
	self:setObjectVisible("new_img", self.m_model.m_data.new_desc == true)
	--self:updateListScroll()
	local give_btn_img = self:findImage("give_btn")
	if self.m_model.m_data.guild_sign == 0 then
		give_btn_img.material = nil
	else
		give_btn_img.material = self.gray_img.material
	end
	self:refreshRedPoint()
end

function M:refreshRedPoint()
	local red_flag = RedPointUtil:hasRedPointById(127)
	local red_flag2 = RedPointUtil:hasRedPointById(34)
	local war_red_bl = RedPointUtil:hasRedPointById(133)
	local sl_red_bl = RedPointUtil:hasRedPointById(12001)
	local red_flag3 = RedPointUtil:hasRedPointById(168) --弹劾红点
	self:setObjectVisible("give_btn_red_point_img", red_flag == true)
	self:setObjectVisible("management_btn_red_point_img", red_flag2 or red_flag3)
	self:setObjectVisible("applyes_btn_red_point", red_flag2 == true)
	self:setObjectVisible("unionwar_btn_red_point_img", war_red_bl == true)
	self:setObjectVisible("shenlu_btn_red_point_img", sl_red_bl == true)
	self:setObjectVisible("impeach_btn_red_point_img", red_flag3 == true)
end

function M:updateListScroll()
	local data = self.m_model.UNION_FUNCTION_BUTTON
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local lv_text = luaBehaviour:FindText("lv_text")
	local time_text = luaBehaviour:FindText("time_text")
	local score_text = luaBehaviour:FindText("score_text")
	local npc_img = luaBehaviour:FindGameObject("npc_img")
	local president_img = luaBehaviour:FindGameObject("president_img")

	GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 1})
	if data.name == "" then
		name_text.text = Language:getTextByKey("new_str_0141")
	else
		name_text.text = data.name
	end
	president_img:SetActive(data.position<3)
	if data.position == 1 then
		LuaBehaviourUtil.setImg(luaBehaviour, "president_img",  "h_bh_huizhang_icon", "maze_stage_ui")
	elseif data.position == 2 then
		LuaBehaviourUtil.setImg(luaBehaviour, "president_img",  "h_bh_zhanglao_icon", "maze_stage_ui")
	end
	npc_img:SetActive(self.m_model:getIsNPC(data.uid))
	lv_text.text = Language:getTextByKey("union_str_0004") .. data.level
	score_text.text = data.active_point


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
        time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
    else
        time_str = Language:getTextByKey("mail_str_0006")
        time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
    end
    time_text.text = time_str
end

function M:managementBtnHandle(isShow)
	local screen_shot_rawimg = self:findGameObject("screen_shot_rawimg")
	if isShow then
		self.management_close_btn:SetActive(true)
		if not IsNull(screen_shot_rawimg) then
			local screen_shot = screen_shot_rawimg:GetComponent("ScreenShot")
			screen_shot:HideObject()
			screen_shot:ShotScreen()
		end
	else
		if not IsNull(screen_shot_rawimg) then
			local screen_shot = screen_shot_rawimg:GetComponent("ScreenShot")
			screen_shot:ClearnTexture()
		end
		self.management_close_btn:SetActive(false)
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M