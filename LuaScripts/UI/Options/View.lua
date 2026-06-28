local M = class("OptionsPopView",LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {"main_toggle","set_toggle"}
local __TAB_BTN_TEXT = {"main_toggle_text","set_toggle_text"}
function M:onEnter()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		local tog_btn_text = __TAB_BTN_TEXT[i]
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("tab_btn",data)
				self:setTextColor(tog_btn_text, GlobalConfig.COMMON_COLLOR.COMMON_25)
			else
				self:setTextColor(tog_btn_text, GlobalConfig.COMMON_COLLOR.COMMON_24)
			end 
		end, i, self.m_uiName)
	end
	self.m_hui_img = self:findImage("hui_img")
	self.m_exp_slider = self:findImage("slider_img")
	-- local user = UserDataManager.user_data.user_status
 --    local head_node = self:findGameObject("HeadNode")
	-- GameUtil:setUserAvatar(head_node, user)
	self.main_panel = self:findGameObject("main_panel")
	self.set_panel = self:findGameObject("set_panel")
	self.head_info = self:findGameObject("head_info") -- 称号头像相关节点
	self.head_info_red_point = self:findGameObject("head_info_red_point_img")
	local options_heros = self:findGameObject("options_heros")
	options_heros.transform.parent = self.m_rootView.transform
	options_heros.transform.localScale = Vector3.one
	local music_slider = self:findSlider("music_slider")
	music_slider.value = audio.music_volume
	local effic_slider = self:findSlider("effic_slider")
	effic_slider.value = audio.effect_volume
	local voice_slider = self:findSlider("voice_slider")
	voice_slider.value = audio.cv_volume
	self:setTextByLanKey("union_text", "union_str_0001")
	self:setTextByLanKey("title_text3", "options_str_0024")
	self:setTextByLanKey("title_text2", "options_str_0025")
	self:setMusicValue()
	self:setEffectValue()
	self:setVoiceValue()

	self:setTextByLanKey("common_title_text", "options_str_0013")
	self:setTextByLanKey("player_icon_btn_text", "options_str_0009")
	--self:setTextByLanKey("title_text_1", "options_str_0010")
	self:setTextByLanKey("cdkey_btn_text", "options_str_0005")
	self:setTextByLanKey("hide_btn_text", "new_str_1037")
	self:setTextByLanKey("user_btn_text", "new_str_1040")
	self:setTextByLanKey("customerService_btn_text", "options_str_0033") --客服
	self:setTextByLanKey("set_toggle_text", "options_str_0011")
	self:setTextByLanKey("main_toggle_text", "options_str_0012")
	self:setTextByLanKey("music_text", "options_str_0014")
	self:setTextByLanKey("effic_text", "options_str_0015")
	self:setTextByLanKey("click_effect_text", "options_str_0016")
	self:setTextByLanKey("quality_text", "options_str_0017")
	self:setTextByLanKey("low_text", "options_str_0018")
	self:setTextByLanKey("height_text", "options_str_0019")
	self:setTextByLanKey("signature_text", "new_str_0464")
	self:setTextByLanKey("uid_text", "new_str_0933")
	self:setTextByLanKey("text_flower", "flower_text_0056")
	self:setTextByLanKey("m_lv", "new_str_0436")
	self:setTextByLanKey("power_s_text", "new_str_0490")
	self:setTextByLanKey("stage_name", "new_str_0501")
	self:setTextByLanKey("server_name", "UnionWar_str_015")
	self:setTextByLanKey("setting_btn_text", "options_str_0011")
	self:setTextByLanKey("tokens_btn_text", "gf_str_0127")


	
	self:refreshUI()
	self:showServerTime()
	self:sliderEvent()
	--local tokens_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
	--local cur_stage = UserDataManager:getCurStage()
	--if tokens_data and tokens_data.user_num > 0 and cur_stage >= 101 then
	--	self:setObjectVisible("tokens_btn", true)
	--else
	--	self:setObjectVisible("tokens_btn", false)
	--end
	if SDKUtil.is_gmsdk then  --判断渠道显示客服按钮
		self:setObjectVisible("customerService_btn", false)
		local application_Id = SDKUtil.sdk_params.applicationId  
		if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
			self:setObjectVisible("customerService_btn", true)
		end
	end
	self:setObjectVisible("customerService_btn", false)
	-- ios提审环境隐藏兑换码
	if GameVersionConfig.CLIENT_VERSION == UserDataManager.server_data.review_vsn then
		self:setObjectVisible("cdkey_btn", false)
	end
end

function M:sliderEvent()
	local function musicSlider(value)
		self:updateMsg("music_value", value)
	end 
	self:addSliderListener("music_slider", musicSlider)

	local function efficSlider(value)
		self:updateMsg("effic_value", value)
	end
	self:addSliderListener("effic_slider", efficSlider)

	local function efficSlider(value)
		self:updateMsg("voice_value", value)
	end
	self:addSliderListener("voice_slider", efficSlider)
end

function M:refreshUI()
	local user = UserDataManager.user_data.user_status
    local head_node = self:findGameObject("HeadNode")
	local title_id = user.title
	--self.head_info.transform.localPosition = Vector3.zero
	--self.head_info_red_point.transform.localPosition = Vector3(22, 186, 0)
	if title_id and title_id ~= 0 then
		--self.head_info.transform.localPosition = Vector3.New(0, 22, 0)
		--self.head_info_red_point.transform.localPosition = Vector3(22, 208, 0)
	end
	GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	
	local exp = UserDataManager.user_data:getUserStatusDataByKey("exp")
    local lv_exp = self:getPlayerLevelExp()
    self.m_exp_slider.fillAmount = exp/lv_exp
	local data = self.m_model.m_data
	local name = UserDataManager.user_data:getUserStatusDataByKey("name")
	self:setText("m_name_text", name)
	local full_combat = user.full_combat
	self:setText("power_text", tostring(full_combat))
	local uid = data.user.uid
	self:setText("id_text", tostring(uid))
	local server_id = UserDataManager.server_data:getServerId()
	local server_Name = data.user.server_name--UserDataManager.server_data:getServerName()
	--self:setText("server_text", "S" .. server_id)
	self:setText("server_text",  server_Name)
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	self:setText("m_lv_num", level)
	local stage_num = UserDataManager:getCurStage()
	local stage = ConfigManager:getCfgByName("stage")
	local cur_stage_cfg = stage[stage_num]
	self:setTextByLanKey("stage_num", cur_stage_cfg.map_point_name)
	self:setTextByLanKey("like_num_text", data.user.like or 0)
	local union_name = data.user.guild_name
	if union_name == "" then
		self:setTextByLanKey("guild_text", "new_str_0092")
	else
		self:setText("guild_text", union_name)
	end

	self:setTextByLanKey("signature_text", self.m_model:getSginDesc())
	self.main_panel:SetActive(self.m_model.m_tab_index == 1)
	self.set_panel:SetActive(self.m_model.m_tab_index == 2)
	if self.m_model.m_tab_index == 1 then
		self:setTextByLanKey("titles_text", "options_str_0001")
		--self:createFormationHeros()
	else
		self:setTextByLanKey("titles_text", "options_str_0002")
		self:updateClickEffectBtn()
	end
	local cpu = LODUtil:getString()
	self:setText("cpu_text",cpu);
	self:updateListScroll()
	self:updateHeroScroll()
	self:customerServiceHasRedPoint()
	
	--设置称号升级红点
	local title_upgrade_red_flag = UserDataManager:getRedDotByKey("title_upgrade")
	self:setObjectVisible("head_info_red_point_img", title_upgrade_red_flag == 1)
	
	-- 花花数量
	self:showFlowerNode()
	self:updateMedalListScroll()
end

function M:showFlowerNode()
	-- 花朝佳节
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

--客服是否有红点
function M:customerServiceHasRedPoint()
	self.m_model.red_point = RedPointUtil:hasRedPointById(142)
	self:settingCustomerRedPoint(self.m_model.red_point)
end

--设置客服红点显示状态
function M:settingCustomerRedPoint(red_point)
	local customerService_red = self:findGameObject("customerService_red")
	customerService_red.gameObject:SetActive(red_point)
end

function M:updateMedalListScroll()
	local data = self.m_model:getMedalShowData()
	if self.m_medal_list_scroll == nil then
		local list_scroll = self:findGameObject("medal_list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				self:updateMedalItem(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				Logger.log("sfsdfsdf")
				--GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("options_str_0007"), delay_close = 2})
			end
		}
		self.m_medal_list_scroll = LoopScrollViewUtil.new(params)
		self.m_medal_list_scroll.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
	else
		self.m_medal_list_scroll:reloadData(data,true)
	end
	self:updateJianTou()
end

function M:updateJianTou()
	local loop_view = self.m_medal_list_scroll
	local loop_view_num = 15
	if loop_view and loop_view.m_line_count > loop_view_num then
		if loop_view:getHorizontalNormalizedPosition() < 0.1 then
			self:setObjectVisible("medal_left_btn", false)
		else
			self:setObjectVisible("medal_left_btn", true)
		end
		if loop_view:getHorizontalNormalizedPosition() > 0.9 then
			self:setObjectVisible("medal_right_btn", false)
		else
			self:setObjectVisible("medal_right_btn", true)
		end
	else
		self:setObjectVisible("medal_left_btn", false)
		self:setObjectVisible("medal_right_btn", false)
	end
end

function M:onValueChanged(pos)
	self:updateJianTou()
end

function M:updateMedalItem(cell_object, index, cell_data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	local cfg_id = cell_data.id
	local ui_element = GameUtil:updateMedalElement(cell_object, cfg_id, true, true)
	local medal_data = UserDataManager:getMedalDataById(cfg_id)
	if medal_data then
		ui_element.item_img.material = nil
	else
		ui_element.item_img.material = self.m_hui_img.material
	end
	self:updateJianTou()
	--GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
	--local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
	--local is_select = self.m_model:isSelect(oid)
	--duigoudi_img:SetActive(is_select)
end

function M:updateListScroll()
	local data = self.m_model.m_team
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

				Logger.log("sdsfsdf")
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:updateHeroScroll()
	local active = self:findGameObject("hero_panel").activeSelf
	if active == false then return end
	local data = self.m_model.m_heros
	if self.m_hero_scroll == nil then
		local list_scroll = self:findGameObject("hero_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:heroHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_hero", cell_data)
			end
		}
		self.m_hero_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_hero_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj,id)
	local oid = self.m_model:getTeamDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	--CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1, oid})
	--GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
	GameUtil:updateHeroContent(obj, oid)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	luaBehaviour:InjectionFunc()
end

function M:heroHandle(obj,id)
	local oid = self.m_model:getHeroDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
	local is_select = self.m_model:isSelect(oid)
	duigoudi_img:SetActive(is_select)
end

function M:showServerTime()
	local function tick(dt)
		local time = os.date("server time: %H:%M:%S",UserDataManager:getServerTime())
		self:setText("time_text", time)
	end
	self.m_updateTime = self.m_control:setTimer(0.2, tick)
end

function M:showSexBtn(flag)
	self:findGameObject("close_sex_btn"):SetActive(flag)
end

function M:showTeamPanel(flag)
	self:findGameObject("hero_panel"):SetActive(flag)
	self:findGameObject("team_save_btn"):SetActive(flag)
	self:findGameObject("team_btn"):SetActive(not flag)
	if flag then
		self:updateHeroScroll()
	end
end

function M:updateClickEffectBtn()
	local click_effect = U3DUtil:PlayerPrefs_GetString("screenClickEffect", "ok")
	if click_effect == "ok" then
		-- self:setImg("jhsb_ui_kaiguan_kai", "coach_ui", "click_effect_btn")
		self:setObjectVisible("click_effect_img", true)
	else
		-- self:setImg("jhsb_ui_kaiguan_guan", "coach_ui", "click_effect_btn")
		self:setObjectVisible("click_effect_img", false)
	end
end

-- TODO 需要改成3D模型展示
function M:createFormationHeros()
	-- local atk_team = data.team or {}
	local atk_heros = self.m_model.m_team or {}
	for i=1,5 do
		local formation_pos = self:findGameObject("formation_pos_" .. i)
		local team_node_tran = UIUtil.findRectTransform(formation_pos)
		UIUtil.destroyAllChild(team_node_tran)
		local rol = self:findGameObject("rol_" .. i)
		UIUtil.destroyAllChild(rol.transform)
		local hero_id = atk_heros[i] or ""
		if hero_id ~= "" then
			local prefab = GameUtil:createPrefab("Pops/PlayerInfo/PlayerInfoHeroItem", team_node_tran)
			local hero_data = UserDataManager.hero_data:getHeroDataById(hero_id)
			local transform = prefab.transform
			local lv = hero_data.lv
			if hero_data.clv and hero_data.clv > 0 then
				lv = hero_data.clv
			end
			UIUtil.setTextByLanKey(transform, "lv_text", "new_str_0075", lv)

			local race_img = UIUtil.findTrans(transform, "race_img")
			GameUtil:setHeroRace(race_img, hero_data.id)
	
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
			local prefab_name = hero_cfg["prefab"]
			local obj = ResourceUtil:LoadRole3d(prefab_name)
			--local helper = obj:GetComponent("LuaTransformHelper")
			--helper:SetAnimator(true);
			
			obj.transform:SetParent(rol.transform, false)
			obj.transform.localPosition = Vector3(0,0,0);
			obj.transform.localRotation = Quaternion.Euler(0,0,0);
			obj.transform.localScale = Vector3(1,1,1);
			GlobalTools:CloseShadow(obj.transform)
			
			local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_cfg.evo]
			if quality_item and quality_item.hero_3d_base then
				local evo_effect = ResourceUtil:LoadCommonEffect(quality_item.hero_3d_base, nil)
				evo_effect.transform:SetParent(rol.transform, false)
				evo_effect.transform.localScale = Vector3.New(1.5, 1.5, 1.5)
			end
		end
	end
end


function M:getPlayerLevelExp()
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	local player_level = ConfigManager:getCfgByName("player_level")
	local player_level_item = player_level[level] or {}
	local exp = player_level_item.exp or 0
	return exp > 0 and exp or 999999999
end

function M:setSignText(text)
	text = GameUtil:formatInputText(text)
	self:setTextByLanKey("signature_text", text)
end

function M:setMusicValue()
	local value = audio.music_volume or 0
	self:setTextByLanKey("music_value_text", tostring(math.floor(value*100)) .. "%")
end

function M:setVoiceValue()
	local value = audio.cv_volume or 0
	self:setTextByLanKey("voice_value_text", tostring(math.floor(value*100)) .. "%")
end

function M:setEffectValue()
	local value = audio.effect_volume or 0
	self:setTextByLanKey("effect_value_text", tostring(math.floor(value*100)) .. "%")
end

return M