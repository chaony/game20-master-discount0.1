--- 个人信息
local M = class("PlayerInfoNode",LikeOO.OOUIbase)

M.m_uiName = "Pops/PlayerInfo/PlayerInfoNode"

function M:onEnter()
	self:setTextByLanKey("name_title_text", "new_str_0489")
	self:setTextByLanKey("lv_title_text", "new_str_0436")
	self:setTextByLanKey("power_title_text", "new_str_0490")
	self:setTextByLanKey("id_title_text", "new_str_0933")
	self:setTextByLanKey("guild_title_text", "new_str_0086")
	self:setTextByLanKey("position_title_text", "new_str_0087")
	self:setTextByLanKey("lan_title_text", "new_str_0088")
	self:setTextByLanKey("server_title_text", "new_str_0089")
	self:setTextByLanKey("chapter_title_text", "new_str_0090")
	self:setTextByLanKey("formation_title_text", "new_str_0091")
	self:setTextByLanKey("add_blacklist_btn_text", "new_str_0376")
	self:setTextByLanKey("add_firend_btn_text", "new_str_0377")
	self:setTextByLanKey("rem_firend_btn_text", "new_str_0378")
	self:setTextByLanKey("send_msg_btn_text", "new_str_0379")
	self:setTextByLanKey("level_text", "master_apprentice_str_0017")
	self:setTextByLanKey("title_text2", "options_str_0024")
	local curPlayerId = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local isCurPlayer = self.m_model.m_data.user.uid == curPlayerId
	self:setTextByLanKey("text_flower", isCurPlayer and "flower_text_0056" or "flower_text_0057")
	self:setTextByLanKey("title_text", "options_str_0025")
	self:setTextByLanKey("report_btn_text", "report_str_0006")
	self:setTextByLanKey("sever_title_text", "UnionWar_str_015")
	self.m_team_node = self:findGameObject("team_node")
    self:refreshUI()	-- 花花数量
	self:showFlowerNode()
end

function M:showFlowerNode()
	-- 送花活动
	local activityData = UserDataManager:getActivesDataByOpenId(291)
	if not activityData then
		self:setObjectVisible("flowerNode", false)
		--GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("flower_text_0060"), delay_close = 2})
		return
	end
	local curTimer = UserDataManager:getServerTime()
	local startTimer =activityData.start_ts
	local endTimer = activityData.show_start_ts
	local isShowFlowerNode = curTimer > startTimer and curTimer < endTimer
	self:setObjectVisible("flowerNode", isShowFlowerNode)
	if isShowFlowerNode then
		self:setTextByLanKey("text_flowerCount", self.m_model.m_data.user.flower)
	end
end

function M:refreshUI()
	if self.m_model.m_data.user.is_black == 0 then
		self:setTextByLanKey("add_blacklist_btn_text", "new_str_0376")
	else
		self:setTextByLanKey("add_blacklist_btn_text", "new_str_0307")
	end
	--self:setObjectVisible("union_handle_btn", self.m_model:unionHandleBtnIsShow())
	self:setObjectVisible("union_handle_btn", false)
	local data = self.m_model:getDataByIndex(self.m_params.index)
    local head_node = self:findGameObject("head_node")
	local user = data.user or {}
	local gender_cfg_item = GlobalConfig.GENDER_CFG[user.gender]
	if gender_cfg_item then
		-- self:setTextByLanKey("gender_text", gender_cfg_item.name)
		--self:setImg(gender_cfg_item.icon, gender_cfg_item.atlas, "gender_img")
		-- self:setObjectVisible("gender_text", true)
		--self:setObjectVisible("gender_img", true)
	else
		-- self:setObjectVisible("gender_text", false)
		--self:setObjectVisible("gender_img", false)
	end
	GameUtil:setUserAvatar(head_node, user,false,false,{show_flag = true, scale = 1})
	local name = user.name or ""
	local uid = user.uid
	if name == "" then
		self:setText("player_name_text", uid)
	else
		self:setText("player_name_text", name)
	end
	self:setText("level_text", tostring(user.level))
	if user.desc == "" then
		self:setTextByLanKey("des_text", "new_str_0463")
	else
		local desc = GameUtil:formatInputText(user.desc)
		self:setText("des_text", desc)
	end
	self:setText("combat_num_text", tostring(data.view_combat))
	self:setText("power_text", tostring(data.view_combat))
	self:setText("id_text", tostring(uid))
	self:setTextByLanKey("like_num_text", data.user.like or 0)
	local guild_name = user.guild_name or ""
	if guild_name == "" then
		self:setTextByLanKey("guild_text", "new_str_0092")
	else
		self:setText("guild_text", tostring(user.guild_name))
	end

	local guild_position = user.guild_position or 0
	if guild_position > 0 then
		local pos = {"union_str_0009", "union_str_1056", "union_str_0010"}
		self:setTextByLanKey("position_text", pos[guild_position])
	else
		self:setTextByLanKey("position_text", "new_str_0092")
	end
	self:setText("lan_text", tostring(user.lang))
	local server_name = user.server_name--UserDataManager.server_data:getServerNameById(user.server)
	self:setText("server_text", server_name)
	local chapter_id, stage_id, stage_item = GameUtil:getChapterIdByStageId(user.stage)
	-- self:setText("chapter_text", string.format("%d-%d", chapter_id, stage_id))
	self:setTextByLanKey("chapter_text", stage_item.map_point_name)

	local show_heros = self.m_model:getShowHeros(data)
    local team_node = UIUtil.findRectTransform(self.m_team_node)
    local function lookHero(click_object,cell_data)
    	self:updateMsg("look_hero", {oid = cell_data.card_id, data = self.m_model:getLookHerosData(data)})
		audio:SendEvtUI('Play_UI_Popup_3')
    end
    self:createHeros(team_node, show_heros, false, false, lookHero)
    self:findGameObject("add_firend_btn"):SetActive(not user.is_friend)
    -- self:findGameObject("add_firend_btn_img"):SetActive(not user.is_friend)
	self:findGameObject("rem_firend_btn"):SetActive(user.is_friend)
	
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	self:setObjectVisible("btns_node", self_uid ~= uid and not(user.is_robot and user.is_robot == 1))
	self:setObjectVisible("send_msg_btn", not(user.is_robot and user.is_robot == 1))
	if self.m_model.m_look_model  == 4 then
		if self.m_model.m_etime then
			self:setObjectVisible("unmaster_btn2",true)
			self:setObjectVisible("unmaster_btn",false)
			local function tick(dt)
				local down_time = self.m_model:getCountDownTime()
				self:setText("count_down_text", down_time)
			end
			self.tick_id = self.m_control:setTimer(1, tick)
			local down_time = self.m_model:getCountDownTime()
			self:setText("count_down_text", down_time)
		else	
			self:setObjectVisible("unmaster_btn2",false)
			self:setObjectVisible("unmaster_btn",true)
		end
	else
		self:setObjectVisible("unmaster_btn2",false)
		self:setObjectVisible("unmaster_btn",false)	
	end
end

function M:createHeros(team_node, rewards, is_show_num, is_show_detail, callback)
    local rewards = rewards or {}
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node" .. i)
		local item_data = rewards[i]
		if item_data and _G.next(item_data) then
			-- local ui_element = CommonUIUtil:updateHeroElementByData(hero_node, item_data, callback)
			-- CommonUIUtil:updateHeroLvByData(hero_node, item_data.hero_data)
			GameUtil:updateHeroContentByData(hero_node.gameObject, item_data.hero_data, item_data.item_cfg, callback)
			local function clickCallback()
				if type(callback) == "function" then
					callback(hero_node, item_data)
				end
			end
			hero_node.gameObject:SetActive(true)
			UIUtil.setButtonClick(hero_node, clickCallback)
		else
			hero_node.gameObject:SetActive(false)
		end
	end
end

return M