---@class CoachPopView:OOPopBase
---@field m_model CoachPopModel
local M = class("CoachPopView",LikeOO.OOPopBase)

M.m_uiName = "Coach/CoachPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn = "martial_all_toggle", name = "martial_all_text",},
	{btn = "martial_1_toggle", name = "martial_1_text",},
	{btn = "martial_4_toggle", name = "martial_4_text",},
	{btn = "martial_2_toggle", name = "martial_2_text",},
	{btn = "martial_3_toggle", name = "martial_3_text",},
	{btn = "martial_6_toggle", name = "martial_6_text",},
	{btn = "martial_5_toggle", name = "martial_5_text",},
	{btn = "martial_7_toggle", name = "martial_7_text",},
}
local __TAB_BTN = {"tab_back_btn", "tab_delete_btn", "tab_reset_btn", "tab_role_reset_btn"}
local __TAB_BTN_TEXT = {"tab_back_btn_text", "delete_btn_text", "tab_reset_btn_text","tab_role_reset_btn_text"}
function M:onEnter()
	self.RaceToggle = self:findGameObject("race_toggle_bg")
	self.RaceToggle:SetActive(true)
	self:setTextByLanKey("hero_list_title_text", "new_str_0012")
	self:setTextByLanKey("tab_role_reset_btn_text", "hero_role_upgrade_text5")
	self:setTextByLanKey("role_reset_btn_text", "new_str_0432")
	self:setTextByLanKey("back_res_text", "coach_zyfh_text")
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local lan_text = "new_str_0065"
		if i > 1 then
			lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
		end
		self:setTextByLanKey(v.name, lan_text)
		UIUtil.setObjectVisible(tog_btn.transform, self.m_model.m_martial_index == i,"UI_ShareLv_Xuanze_01")
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data)
				UIUtil.setObjectVisible(tog_btn.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(tog_btn.transform, false,"UI_ShareLv_Xuanze_01")
			end 
		end, i, self.m_uiName)
	end
	self.RaceToggle:SetActive(false)
	self.m_race_toggle_flag = false
	
	self:setObjectVisible("hero_sk", false)
	self.tab_parent_panel = self:findGameObject("tab_parent_panel")
	self.btn_parent_panel = self:findGameObject("btn_parent_panel")
	self.des_parent_panel = self:findGameObject("des_parent_panel")
	self.select_reset_parent_panel = self:findGameObject("select_reset_parent_panel")
	self.select_delete_panel = self:findGameObject("select_delete_panel")

	self.delete_toggle = self:findGameObject("delete_toggle")
	self.reset_btn_panel = self:findGameObject("reset_btn_panel")
	self.reset_btn = self:findButton("reset_btn")
	self.role_reset_btn = self:findButton("role_reset_btn")
	self.hero_back_btn = self:findButton("hero_back_btn")
	self.back_btn_panel = self:findGameObject("back_btn_panel")
	self.one_key_select_btn = self:findButton("one_key_select_btn")
	self.delete_btn = self:findButton("delete_btn")
	--self.select_reset_hero_image = self:findGameObject("select_reset_hero_image")
	self.msg_text = self:findGameObject("msg_text")
	self.no_hero_tips_text = self:findGameObject("no_hero_tips_text")
	local tog_btn = self:findToggle("delete_toggle")
	UIUtil.addToggleListener(tog_btn, function(is_on) 
		self:updateMsg("gacha_delete", is_on) 
		local image = UIUtil.findImage(tog_btn.transform, "Background")
		image.enabled = not is_on
	end, nil, self.m_uiName)

	self:setTextByLanKey("close_title_text", "coach_str_0016")
	self:setTextByLanKey("tab_back_btn_text", "coach_str_0005")
	self:setTextByLanKey("tab_reset_btn_text", "coach_str_0004")
	self:setTextByLanKey("hero_back_btn_text", "coach_str_0022")
	self:setTextByLanKey("reset_btn_text", "coach_str_0021")
	-- self:setText("msg_text", Language:getTextByKey("coach_str_0006"))
	-- UIUtil.setTextByLanKey(self.tab_parent_panel.transform, "tab_back_btn/Text", "coach_str_0005")
	-- UIUtil.setTextByLanKey(self.tab_parent_panel.transform, "tab_delete_btn/Text", "coach_str_0003")
	-- UIUtil.setTextByLanKey(self.tab_parent_panel.transform, "tab_reset_btn/Text", "coach_str_0004")
	local reset_cost = ConfigManager:getCommonValueById(21,99999)
	self:setText("reset_cost_text", reset_cost)
	local back_cost = ConfigManager:getCommonValueById(59, 99999)
	self:setText("back_cost_text", back_cost)
	self.hero_sk = self:findGameObject("hero_sk")
	local des_sp = self:findGameObject("des_sp")
	GameUtil:updateSpineLoadSet(des_sp, "RoleSpine/hero_0208_SkeletonData", "idle", 0, true)
	self:refreshUI()
end

function M:refreshUI()
	self:refreshTabUI()
	self:updateListScroll()
	self:updateSelectDeleteScroll()
	self:refreshResetList()
	self:setSpine()
end

function M:updateListScroll()
	local data = self.m_model.m_list_data
	--Logger.log(#data,"updateListScroll ===")
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local oid = self.m_model:getHeroDataByIndex(index)
				self:updateMsg("select_hero", oid)
			end,
			ui_name = self.m_uiName
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:updateSelectDeleteScroll()
	if self.m_model.m_tab_index ~= 2 then
		return
	end
	local data = self.m_model.m_select_heros
	-- Logger.log(#data,"updateSelectDeleteScroll ===")
	if self.m_select_delete_scroll == nil then
		local list_scroll = self:findGameObject("select_delete_scroll")
		local params = {
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:deleteListHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local oid = self.m_model:getSelectHeroDataByIndex(index)
				self:updateMsg("select_hero", oid)
			end
		}
		self.m_select_delete_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_select_delete_scroll:reloadData(data)
	end
end

function M:updateSelectResetScroll()
	self.m_reset_scroll_cell = {}
	local data = self.m_model.m_reset_items
	-- Logger.log(#data,"updateSelectResetScroll ===")
	if self.m_select_reset_scroll == nil then
		local list_scroll = self:findGameObject("select_reset_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			pos_center = true,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self.m_reset_scroll_cell[index] = cell_object
				self:resetListHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			
			end
		}
		self.m_select_reset_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_select_reset_scroll:reloadData(data)
		self.m_select_reset_scroll:setPosCenterPadding()
	end
end

function M:refreshTabUI()
	local index = self.m_model.m_tab_index
	local count = self.tab_parent_panel.transform.childCount
	for i,v in ipairs(__TAB_BTN) do
		local btn = self:findGameObject(v)
		if index == i then
			-- UIUtil.setImg(btn.transform, "ui_tanchuangyeqian_A", "common_ui")
			-- UIUtil.setTextColor(btn.transform, GlobalConfig.COMMON_COLLOR.COMMON_2, "Text")
			-- UIUtil.setLocalScale(btn.transform, 1,1,1)
			-- UIUtil.setLocalPosition(btn.transform, 0,0,0)
			-- btn.transform:SetSiblingIndex(count - 1)
			btn:GetComponent("Button").interactable = false
			UIUtil.setObjectVisible(btn.transform, true, "select_img")
			self:setTextColor(__TAB_BTN_TEXT[i], GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			-- UIUtil.setImg(btn.transform, "ui_tanchuangyeqian_B", "common_ui")
			-- UIUtil.setTextColor(btn.transform, GlobalConfig.COMMON_COLLOR.COMMON_18, "Text")
			-- UIUtil.setLocalScale(btn.transform, 0.7,0.7,0.7)
			-- UIUtil.setLocalPosition(btn.transform, 40,0,0)
			btn:GetComponent("Button").interactable = true
			UIUtil.setObjectVisible(btn.transform, false, "select_img")
			self:setTextColor(__TAB_BTN_TEXT[i], GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
		if i == 4 then
			local cur_season = UserDataManager:getCurSeason() -- 当前赛季
			local season = ConfigManager:getCommonValueById(607,2) -- 图鉴按赛季开启
			if cur_season >= season then
				btn:SetActive(true)
			else
				btn:SetActive(false)
			end
		end
	end

	self:setObjectVisible("back_tips_text",false)
	if index == 1 then
		self:setText("msg_text", Language:getTextByKey("coach_str_0018"))
		self:setText("no_hero_tips_text", Language:getTextByKey("coach_str_0011"))
		-- self:setText("titles_text", Language:getTextByKey("coach_str_0005"))
		self:setText("des_text", Language:getTextByKey("tid#hero_return1"))
		local back_cost = ConfigManager:getCfgByName("common")[59].value or 0
		local has_times = self.m_model:getBackTimes()
		self.back_btn_panel:SetActive(#self.m_model.m_select_heros > 0 and back_cost > 0 and has_times <= 0)
		-- self.hero_back_btn.interactable = #self.m_model.m_select_heros > 0
		self:setObjectVisible("back_tips_text",#self.m_model.m_select_heros > 0)
		if #self.m_model.m_select_heros > 0 and has_times > 0 then
			self:setTextByLanKey("back_tips_text", "coach_str_0028",has_times)
		elseif #self.m_model.m_select_heros > 0 then
		 	local cur_times = self.m_model.getRollBackTimes()
			self:setTextByLanKey("back_tips_text",  Language:getTextByKey("tid#limit_2") ..  cur_times .. "/" .. self.m_model:getMaxTimes())
		end
	elseif index == 2 then
		self:setText("no_hero_tips_text", Language:getTextByKey("coach_str_0002"))
		-- self:setText("titles_text", Language:getTextByKey("coach_str_0003"))
		self:setText("des_text", Language:getTextByKey("tid#boat_sell1"))
	elseif index == 4 then
		self:setText("no_hero_tips_text", Language:getTextByKey("hero_role_upgrade_text7"))
		self:setText("des_text", Language:getTextByKey("tid#boat_rolereset"))
	else
		self:setText("msg_text", Language:getTextByKey("coach_str_0019"))
		self:setText("no_hero_tips_text", Language:getTextByKey("coach_str_0001"))
		-- self:setText("titles_text", Language:getTextByKey("coach_str_0004"))
		self:setText("des_text", Language:getTextByKey("tid#boat_reset1"))
		local reset_cost = ConfigManager:getCfgByName("common")[21].value or 0
		self.reset_btn_panel:SetActive(#self.m_model.m_select_heros > 0 and reset_cost > 0)
		-- self.reset_btn.interactable = #self.m_model.m_select_heros > 0
	end

	--self:setText("msg_text", Language:getTextByKey("coach_str_0017") .. #self.m_model.m_list_data .. "/" .. UserDataManager.hero_data:getHerosCount())
	self.btn_parent_panel:SetActive(#self.m_model.m_select_heros > 0)
	self:setText("num_text", tostring(#self.m_model.m_list_data) .. "/" .. UserDataManager.hero_data:getHerosCount())
	-- self.select_delete_scroll:SetActive(index == 2)
	-- self.select_reset_scroll:SetActive(index == 3)
	self.hero_back_btn.gameObject:SetActive(index == 1)
	self.reset_btn.gameObject:SetActive(index == 3)
	self.role_reset_btn.gameObject:SetActive(index == 4)
	self.one_key_select_btn.gameObject:SetActive(index == 2)
	self.delete_btn.gameObject:SetActive(index == 2)
	self.delete_toggle:SetActive(index == 2)
	-- self.msg_text:SetActive(index == 2)
	self.des_parent_panel:SetActive(#self.m_model.m_select_heros <= 0)
	self.select_delete_panel:SetActive(index == 2 and #self.m_model.m_select_heros > 0)
	self.select_reset_parent_panel:SetActive(#self.m_model.m_select_heros > 0 and (index == 1 or index == 3 or index == 4))
	self.no_hero_tips_text:SetActive(#self.m_model.m_list_data <= 0)
end

function M:listHandle(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)

    -- UIUtil.setScale(obj.transform,0.9)
	--CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
	GameUtil:updateHeroContentByData(obj, data, cfg)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local duigou_img = luaBehaviour:FindGameObject("duigou_img")
	local is_select = self.m_model:isSelect(oid)
	duigou_img:SetActive(is_select)

	--local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
	--lv_bg_img:SetActive(true)
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local upgrade_cfg = hero_upgrade[tonumber(data.lv)]
	local lv_text = luaBehaviour:FindText("lv_text")
	lv_text.text = string.format(Language:getTextByKey("new_str_0075"), data.lv)
    -- lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    lock_img:SetActive(data.lock == true)
	luaBehaviour:InjectionFunc()
end

function M:deleteListHandle(obj, id)
	local oid = self.m_model:getSelectHeroDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
    -- UIUtil.setScale(obj.transform,0.9)
	GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)

	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
	lv_bg_img:SetActive(true)
	-- lv_text:GetComponent("Text").text = "Lv" .. data.lv
end

function M:resetListHandle(obj, id)
	local data = self.m_model:getResetItemDataByIndex(id)
	-- UIUtil.setScale(obj.transform,0.9)
	local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS and data[1] ~= RewardUtil.REWARD_TYPE_KEYS.EQUIPS
	if data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS and data.quality == nil and data.hero_oid then
		data[4] = data.hero_oid
	end
	local ui_element = GameUtil:updateItemElement(obj, data, showNum, false)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	if data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
		local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
		lv_bg_img:SetActive(true)
		local lv_text = luaBehaviour:FindText("lv_text")
		lv_text.gameObject:SetActive(true)
		lv_text.text = string.format(Language:getTextByKey("new_str_0075"), 1)
		lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
		if data.hero_oid then
			local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(data.hero_oid)
			LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")
			if self.m_model.m_tab_index == 4 then -- 侠客返璞保留等级
				local hero_data = UserDataManager.hero_data:getHeroDataById(data.hero_oid)
				lv_text.text = string.format(Language:getTextByKey("new_str_0075"), hero_data.lv)
			end
		end
	end
	local add_panel = luaBehaviour:FindGameObject("add_panel")
	UIUtil.destroyAllChild(add_panel.transform)
end

function M:refreshResetList()
	if self.m_model.m_tab_index == 2 then
		return
	end
	self:updateSelectResetScroll()
	local oid = self.m_control.m_model.m_select_heros[1]
	if oid then
		local function clickCall()
			self:updateMsg("select_hero", oid)
		end
		local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
		-- local icon = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false, clickCall)
		-- UIUtil.destroyAllChild(self.select_reset_hero_image.transform)
		-- icon.transform:SetParent(self.select_reset_hero_image.transform,false)
		-- local luaBehaviour = icon:GetComponent("LuaBehaviour")
		-- local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
		-- lv_bg_img:SetActive(true)
		-- local lv_text = luaBehaviour:FindText("lv_text")
		-- lv_text.text = string.format(Language:getTextByKey("new_str_0075"), data.lv)
  --   	lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
	else
		-- UIUtil.destroyAllChild(self.select_reset_hero_image.transform)
	end
end

function M:resetToggle()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		if i == 1 then
			tog_btn.isOn = true
		else
			tog_btn.isOn = false
		end
	end
end

function M:setSpine()
	if self.m_model.m_select_heros[1] ~= nil then
		local hero_sk = self:setObjectVisible("hero_sk", true)
		local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_select_heros[1])
		local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero, cfg)
		local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
		GameUtil:updateSpineLoadSet(self.hero_sk, "RoleSpine/"..spine, "idle", 0, true)
		self:setObjectVisible("hero_sk", true)

		local pos_x = -8
		local pos_y = -8
		local play_img = self:findGameObject("hero_sk")
		local spine_pos, spine_scale = self.m_model:getSpinePos(hero,cfg)
		local pos = play_img.transform.localPosition
		pos.x = spine_pos[1] or 0
		pos.y = spine_pos[2] or 0
		play_img.transform.localPosition = pos
		play_img.transform.localScale = Vector3(spine_scale,spine_scale,1)

	else
		self:setObjectVisible("hero_sk", false)	
	end
end

function M:setToggleActive(flag)
	self.m_race_toggle_flag = flag
	self.RaceToggle:SetActive(flag)
end

function M:playIconEffect()
	for k,v in pairs(self.m_reset_scroll_cell or {}) do
		local luaBehaviour = v:GetComponent("LuaBehaviour")
		local add_panel = luaBehaviour:FindGameObject("add_panel")
		local effect =ResourceUtil:GetUIEffectItem("Coach/ChongZhi_001", add_panel)
	end
	local function timeCall()
		self:unlockTouch()
		self:refreshUI()
	end
	self:lockTouch()
	self.m_control:setOnceTimer(0.5,timeCall)
end

function M:playEffect(callBack)
	self:setObjectVisible("JUQI", true)
	local function endCall()
		self:setObjectVisible("baozha", false)
		self:unlockTouch()
		callBack()
	end
	
	local function timeCall()
		self:setObjectVisible("JUQI", false)
		self:setObjectVisible("baozha", true)
		self.m_control:setOnceTimer(0.8,endCall)
	end
	self:lockTouch()
	self.m_control:setOnceTimer(0.5,timeCall)
end

return M