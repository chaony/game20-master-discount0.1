local M = class("AdvancedPopView",LikeOO.OOPopBase)

M.m_uiName = "Advanced/AdvancedPop"
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
local attrs = {"combat", "maxLv", "hp", "atk", "def"}
function M:onEnter()
	self.RaceToggle = self:findGameObject("race_toggle_bg")
	self.RaceToggle:SetActive(true)
	self:setTextByLanKey("one_key_btn_text", "advanced_str_0016")
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local item = self:findGameObject(v.btn)
		local lan_text = "a_ui_all"
		if i > 1 then
			-- lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
			lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].big_race_icon
		end
		local img= UIUtil.findImage(item.transform,"Background")
		-- self:setTextByLanKey(v.name, lan_text)
		UIUtil.setImg(img, lan_text, ResourceUtil:getLanAtlas())
		UIUtil.setObjectVisible(item.transform, self.m_model.m_index == i,"UI_ShareLv_Xuanze_01")
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("tab_btn",data)
				local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
				self:setTextByLanKey("race_toggle_btn_text", lan_text)
				UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
			end 
		end, i, self.m_uiName)
	end
	--self.RaceToggle:SetActive(false)
	self.m_race_toggle_flag = false
	
	self.attrs_text = {}
	for i,v in ipairs(attrs) do
		self.attrs_text[v] = self:findText(v .. "_value_text")

		local name = ""
		if v == "maxLv" then
			name = Language:getTextByKey("advanced_str_0002") .. ":"
		elseif v == "combat" then
			name = Language:getTextByKey("advanced_str_0005") .. ":"
		else
			name = GameUtil:getAttrsName(v) .. ":"
		end
		self:setText(v .. "_text", name)
	end
	self:setTextByLanKey("close_title_text", "advanced_str_0013")
	self:setTextByLanKey("list_tips_text", "advanced_str_0012")
	self:setTextByLanKey("advanced_btn_text", "advanced_str_0008")
	self:setTextByLanKey("empty_text", "advanced_txt_no_hero")
	self:setObjectVisible("empty_text", false)
	
	-- self.quality_text = self:findText("quality_text")
	self.quality_image = self:findImage("quality_image")
	self.quality_link_image = self:findImage("quality_image_link")
	self.select_panel = self:findGameObject("select_panel")
	self.top_panel = self:findGameObject("top_panel")
	self.no_img = self:findGameObject("no_img")
	self.one_key_btn = self:findGameObject("one_key_btn")
	self.hero_sk = self:findGameObject("hero_sk")
	self.link_hero_sk = self:findGameObject("link_hero_sk")
	self.advanced_btn = self:findGameObject("advanced_btn")
	self.no_advanced_btn = self:findGameObject("no_advanced_btn")
	self.play_effect = self:findGameObject("UI_Advanced_GaoS01")
	self.no_tips_img = self:findGameObject("no_tips_img")
	self.content_node = self:findGameObject("content_node")
	self.UI_Advanced_ComMon_001 = self:findGameObject("UI_Advanced_ComMon_001")
	--self:setParticleRenderOrder(self.content_node)
	self:setObjectVisible("quality_image_link", false)
	self.m_point_1 = self:findGameObject("s01").transform.localPosition
	self.m_point_2 = self:findGameObject("s02").transform.localPosition
	self.m_point_3 = self:findGameObject("s03").transform.localPosition
	self:refreshUI()
	self:setSpine()
end

function M:refreshUI()
	self:setObjectVisible("link_obj", false)
	self:setObjectVisible("animation", true)
	self:refreshAdvanced()
	self:refreshRedPoint()
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

--传功殿刷新
function M:refreshAdvanced()
	self.loop_score_sequence = Tweening.DOTween.Sequence()
	self.sequence_time = 0
	self:setObjectVisible("detail_btn", true)
	self.one_key_btn:SetActive(false)
	if #self.m_model.m_select > 0 then
		local oid = self.m_model.m_select[1]
		local hero, cfg = UserDataManager.hero_data:getHeroDataById(oid)
		local attrs = UserDataManager:getHeroAttrsById(oid)
		local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
		attrs.combat = hero.combat
		attrs.maxLv = hero_evolution[hero.evo].level_max
		for k,v in pairs(self.attrs_text) do
			UIUtil.setText(v.transform, attrs[k], "value_text")
			if k == "maxLv" then
				v.text =  attrs[k]
			elseif k == "combat" then
				v.text =  attrs[k]
			else
				local name = GameUtil:getAttrsName(k)
				v.text = attrs[k]
			end
		end
		local evoData = GlobalConfig.QUALITY_FRAME[hero.evo]
		self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,hero.evo), "common_ui", "quality_image")
		self:updateQualityData(self.quality_image.gameObject, hero,cfg)
		UIUtil.setLocalPosition(self.quality_image.gameObject.transform,11.6)
		if hero.evo < 18 then
			self:setTextByLanKey("advanced_tips_text", "advanced_str_0021")
		else
			self:setTextByLanKey("advanced_tips_text", "advanced_str_0022")
		end
	else
		if self.m_model.m_evo_num > 0 then
			self.one_key_btn:SetActive(true)
		elseif self.m_model.m_adv_num > 0 then
			self.one_key_btn:SetActive(true)
		end
	end

	self.UI_Advanced_ComMon_001:SetActive(#self.m_model.m_select > 0 and #self.m_model.m_select == self.m_model.m_need_count) 
	--可以使用万能材料
	local universal_tab = self.m_model:checkCanUseUniversal()
	if next(universal_tab) ~= nil then
		self.advanced_btn:SetActive(self.m_model:checkHaveUniversal() == true)	
	else
		self.advanced_btn:SetActive(#self.m_model.m_select > 0 and table.nums(self.m_model.m_select) == self.m_model.m_need_count)	
	end
	self:setObjectVisible("advanced_tips_text", #self.m_model.m_select > 0)
	self:updateHerosScroll()
	self:refreshSelectHero(universal_tab)
	self.top_panel:SetActive(#self.m_model.m_select > 0)
	self.play_effect:SetActive(false)
	if self.move_sk == true then
		self.hero_sk.transform.localPosition = Vector3.New(-500, 0, 0)
		self.select_panel.transform.localPosition = Vector3.New(-225, -488, 0)
		self.hero_sk.transform:DOLocalMoveX(0, 0.5, false)
		self.select_panel.transform:DOLocalMoveY(-125, 0.6, false)
		audio:SendEvtUI("UI_Slidein")
	end
	if next(self.m_model.m_select) == nil then
		self.move_sk = true
	else
		self.move_sk = false
	end 
end

--联动英雄刷新
function M:refreshLink()
	self:updateHerosScroll()
	self.top_panel:SetActive(#self.m_model.m_select > 0)
	self:setObjectVisible("detail_btn", false)
	if next(self.m_model.m_select) == nil then
		self:setObjectVisible("link_obj", false)
		return
	end
	for i=1,2 do
		local obj = self:findGameObject(string.format("link_hero_%d", i))
		if self.m_model.m_select[i] then
			local oid = self.m_model.m_select[i]
			local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
			CommonUIUtil:updateHeroElement(obj,{RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false, function ()
					self:updateMsg("remove_hero",{oid = oid})
					audio:SendEvtUI('Play_UI_Cancel')
			end)
		else
			CommonUIUtil:updateHeroElementAdd(obj,nil,true)
			local luaBehaviour = UIUtil.findLuaBehaviour(obj)
			local quality_img = luaBehaviour:FindImage("quality_img")
			quality_img.color = Color.New(1,1,1,1)
		end
	end
	if self.m_model.m_select[1] then
		local data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_select[1])
		self:updateQualityData(self.quality_image.gameObject, data,cfg)
		self.quality_image.gameObject:SetActive(true)
		UIUtil.setLocalPosition(self.quality_image.gameObject.transform,-525)
	else
		self.quality_image.gameObject:SetActive(false)
		UIUtil.setLocalPosition(self.quality_image.gameObject.transform,11.6)
	end
	if self.m_model.m_select[2] then
		local data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_select[2])
		self:updateQualityData(self.quality_link_image.gameObject, data,cfg)
		self.quality_link_image.gameObject:SetActive(true)
	else
		self.quality_link_image.gameObject:SetActive(false)	
	end

	
	if #self.m_model.m_select >= 2 then
		local oid = self.m_model.m_select[1]
		local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
		if data.link and data.link ~= "" then
			self:setObjectVisible("link_btn", false)
			self:setObjectVisible("link_remove_btn", true)
			self:setObjectVisible("link_levelup_btn", true)
			if data.link_lv >= self.m_model.m_max_ex_hero_lv then
				self:setObjectVisible("link_levelup_btn", false)
			end
		else
			self:setObjectVisible("link_btn", true)
			self:setObjectVisible("link_remove_btn", false)
			self:setObjectVisible("link_levelup_btn", false)
		end
		
	else
		self:setObjectVisible("link_btn", false)
		self:setObjectVisible("link_remove_btn", false)
		self:setObjectVisible("link_levelup_btn", false)
	end
	self.select_panel:SetActive(true)
end

--更新标签数据
function M:updateQualityData(obj, hero_data, cfg)
	local top_race_img = UIUtil.findImage(obj.transform, "top_race_img")
	local top_race_name_text = UIUtil.findText(obj.transform, "top_race_name_text")
	local top_hero_name_text = UIUtil.findText(obj.transform, "top_hero_name_text")
	local top_daxia_img = UIUtil.findImage(obj.transform, "top_daxia_img")
	local top_star_obj = UIUtil.findTrans(obj.transform, "top_star_obj")
	local quality_image = UIUtil.findImage(obj.transform)
	local race_data = GlobalConfig.TYPE_HERO_RACE[cfg.race]
	--local evoData = GlobalConfig.QUALITY_FRAME[hero_data.evo]
	quality_image.sprite = ResourceUtil:GetSprite(GameUtil:get_lineframename(cfg.Ex_hero,hero_data.evo), "common_ui")
	top_race_img.sprite = ResourceUtil:GetSprite(race_data.race_icon, ResourceUtil:getLanAtlas())
	top_race_name_text.text = Language:getTextByKey(cfg.name) 
	top_hero_name_text.text = Language:getTextByKey(cfg.class)
	UIUtil.setObjectVisible(obj.transform, cfg.evo > 4, "top_daxia_img")
	local data = {quality = hero_data.evo }
	GameUtil:updateHeroInfo(top_star_obj.gameObject,data)
end

--进阶配方
function M:showDetailNode()
	self:setObjectVisible("detail_node",  self.m_model.m_is_show_detail)
	self:setObjectVisible("detail_close_btn",  self.m_model.m_is_show_detail)
	if self.m_model.m_is_show_detail then
		UIUtil.setObjectVisible(self:findGameObject("wuxing_btn").transform, self.m_model.m_detail_index == 1,"UI_ShareLv_Xuanze_01")
		UIUtil.setObjectVisible(self:findGameObject("yin_btn").transform, self.m_model.m_detail_index == 2,"UI_ShareLv_Xuanze_01")
		UIUtil.setObjectVisible(self:findGameObject("yang_btn").transform, self.m_model.m_detail_index == 3,"UI_ShareLv_Xuanze_01")
		UIUtil.setObjectVisible(self:findGameObject("yuan_btn").transform, self.m_model.m_detail_index == 4,"UI_ShareLv_Xuanze_01")
		self.m_show_id, self.m_show_evo_tab, self.m_show_evo_data_tab = self.m_model:getDetailShowData()
		self:updateDetailScroll()
		self.m_detail_list_scroll:moveToCellIndex(#self.m_show_evo_tab)
	end
end

function M:dealMartialData(i, j, show_evo_data_tab, show_id)
	local show_evo = show_evo_data_tab[i][j][3]
	local is_self = show_evo_data_tab[i][j][1] == 1
	local race = show_evo_data_tab[i][j][4] and show_evo_data_tab[i][j][4] or nil
	local martial_data = RewardUtil:getProcessRewardData({101, show_id, 1}, show_evo)
	if is_self then
	else
		martial_data.icon_name = "a_mjmb_wodekaungdong_touxiang_kong"
		if race then
			martial_data.race = race
		end
	end
	return martial_data
end

function M:updateMartialNode(parent_node, show_data)
	local item = CommonUIUtil:updateHeroElementByData(parent_node, show_data)
end

function M:updateDetailScroll()
	local data = self.m_show_evo_tab
	-- Logger.log(#data,"updateHerosScroll ===")
	if self.m_detail_list_scroll == nil then
		local list_scroll = self:findGameObject("detail_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:refreshDetailCell(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end,
			ui_name = self.m_uiName,
		}
		self.m_detail_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_detail_list_scroll:reloadData(data)
	end
end

function M:refreshDetailCell(obj, id)
	local show_id, show_evo_tab, show_evo_data_tab = self.m_show_id , self.m_show_evo_tab, self.m_show_evo_data_tab
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local result_node = luaBehaviour:FindGameObject("result_node")
	local hero_base_node = luaBehaviour:FindGameObject("hero_base_node")
	local hero_node1 = luaBehaviour:FindGameObject("hero_node1")
	local hero_node2 = luaBehaviour:FindGameObject("hero_node2")
	local hero_node3 = luaBehaviour:FindGameObject("hero_node3")
	local hero_node4 = luaBehaviour:FindGameObject("hero_node4")
	local hero_node5 = luaBehaviour:FindGameObject("hero_node5")
	local need_num = show_evo_data_tab[id][1][2]
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node1",#show_evo_data_tab[id] == 1 and need_num == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node2",#show_evo_data_tab[id] > 1 or need_num == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node3",#show_evo_data_tab[id] >= 2 or need_num == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node4",#show_evo_data_tab[id] > 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node5",#show_evo_data_tab[id] > 3)

	local self_data = RewardUtil:getProcessRewardData({101, show_id, 1}, show_evo_tab[id])
	local result_data = RewardUtil:getProcessRewardData({101, show_id, 1}, show_evo_tab[id] + 1)
	self:updateMartialNode(hero_base_node, self_data)
	self:updateMartialNode(result_node, result_data)
	if #show_evo_data_tab[id] == 1 and need_num == 1 then
		local martial_data = self:dealMartialData(id, 1, show_evo_data_tab, show_id)
		self:updateMartialNode(hero_node1, martial_data)
	elseif #show_evo_data_tab[id] == 1 and need_num == 2 then
		for j = 1, 2 do
			local martial_data = self:dealMartialData(id, 1, show_evo_data_tab, show_id)
			self:updateMartialNode(j == 1 and hero_node2 or hero_node3, martial_data)
		end
	elseif #show_evo_data_tab[id] == 2 then
		for j = 1, 2 do
			local martial_data = self:dealMartialData(id, j, show_evo_data_tab, show_id)
			self:updateMartialNode(j == 1 and hero_node2 or hero_node3, martial_data)
		end
	elseif #show_evo_data_tab[id] == 3 then
		for j = 1, 3 do
			local martial_data = self:dealMartialData(id, j, show_evo_data_tab, show_id)
			local hero_node = nil
			if j == 1 then
				hero_node = hero_node2
			elseif j ==2 then
				hero_node = hero_node4
			elseif j ==3 then
				hero_node = hero_node3
			end
			self:updateMartialNode(hero_node, martial_data)
		end
	elseif #show_evo_data_tab[id] == 4 then
		for j = 1, 4 do
			local martial_data = self:dealMartialData(id, j, show_evo_data_tab, show_id)
			local hero_node = nil
			if j == 1 then
				hero_node = hero_node2
			elseif j ==2 then
				hero_node = hero_node5
			elseif j ==3 then
				hero_node = hero_node4
			elseif j ==4 then
				hero_node = hero_node3
			end
			self:updateMartialNode(hero_node, martial_data)
		end
	end
end
function M:refreshRedPoint()
	local red = RedPointUtil:hasRedPointById(19)
	self:setObjectVisible("one_key_btn_red_img", red)
end

function M:updateHerosScroll()
	local data = self.m_model.m_list_data
	self:setObjectVisible("empty_text", #data==0)
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("heros_scroll")
		local params = {
			ui_name = self.m_uiName,
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
				for i=1,self.m_model.m_need_count do
					if self.m_model.m_select[i] == oid then
						self:updateMsg("remove_hero", {oid = oid})
						audio:SendEvtUI('Play_UI_Cancel')
						return
					end
				end
				audio:SendEvtUI('UI_Hero_Click')
		        self:updateMsg("select_hero", {oid = oid, cell_obj = cell_object})
			end,
			ui_name = self.m_uiName,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
		self.m_model.m_isfresh_list = false
	end
end


function M:listHandle(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	GameUtil:updateHeroContentByData(obj,data,cfg)
	self:freshOneCell(obj, id)
	if self.m_control.m_guide and self.m_control.m_guide.list_index and self.m_control.m_guide.list_index == id then
		self.m_control.m_guide.m_guide_hero = obj
	end
	if cfg.evo == 3 or cfg.is_sp > 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"daxia_img", false)
	else
		if cfg.Ex_hero == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_HeroBag_DX_01", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_HeroBag_DX_T0_01", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_HeroBag_DX_01", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_HeroBag_DX_T0_01", false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"daxia_img", true)
	end
	luaBehaviour:InjectionFunc()
end

function M:freshOneCell(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
	local duigou_img = luaBehaviour:FindGameObject("duigou_img")
	local is_select = self.m_model:isSelectedByIndex(oid)
	duigou_img:SetActive(is_select)
	local lock_image = luaBehaviour:FindGameObject("lock_img")
	lock_image:SetActive(false)
	local lock_text = luaBehaviour:FindText("lock_text")
	lock_text.text = Language:getTextByKey("advanced_str_0023")
	local tips_img = luaBehaviour:FindGameObject("tips_img")
	local tips_text = luaBehaviour:FindText("tips_text")
	tips_img:SetActive(data.evo >= cfg.max_evo)
	if data.evo >= cfg.max_evo then
		tips_text.text = Language:getTextByKey("advanced_str_0006")
	end
	local red_point_img = luaBehaviour:FindGameObject("add_panel")--红点
	UIUtil.destroyAllChild(red_point_img.transform)

	local red_flag = self.m_model:getRedPointByHeroId(oid)
	if #self.m_model.m_select > 0 then
		local is_consume = self.m_model:isConsume(oid)
		local same_consume = self.m_model:consumeCheck(oid)
		if is_select then
			lock_image:SetActive(false)
		else
			lock_image:SetActive(is_consume == false or same_consume ~= 0)
		end
		red_point_img:SetActive(red_flag == true and self.m_model.m_select[1] == oid)
		if red_flag == true and self.m_model.m_select[1] == oid then
			self:addCanSelectEffect(red_point_img, data.evo)
		end
	else
		if red_flag == true then
			self:addCanSelectEffect(red_point_img, data.evo)
		end
		red_point_img:SetActive(red_flag == true)
	end
	
end

function M:addCanSelectEffect(obj, evo)
	local prefab = "Advanced/UI_Advanced_ShanGuang0001"
	if evo > 6 then
		prefab = "Advanced/UI_Advanced_ShanGuang0003"
	elseif evo > 4 then
		prefab = "Advanced/UI_Advanced_ShanGuang0002"
	else
		prefab = "Advanced/UI_Advanced_ShanGuang0001"
	end
	local open_effect = ResourceUtil:GetUIEffectItem(prefab,obj)
	--open_effect.transform:SetParent(obj.transform, false)
end

function M:refreshSelectHero(universal_tab)
	local used_universal_num = 0
	if self.m_control.m_model.m_need_count > 0 and self.m_control.m_model.m_need_count <= 3 then
		self.select_panel:SetActive(true)
		local slot_consume = self.m_model.m_slot_consume
		self:setObjectVisible("animation", true)
		self:setObjectVisible("animation_4", false)
		self:setObjectVisible("animation_5", false)
		for i=1,3 do
			local trans = self:findGameObject(string.format("select%d_panel", i)).transform
			local xh_trans = self:findGameObject(string.format("s_xh_%d", i)).transform
			trans.gameObject:SetActive(true)
			UIUtil.destroyAllChild(trans)
			if self.m_control.m_model.m_select[i] then
				local oid = self.m_control.m_model.m_select[i]
				local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
				local icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false, function ()
					self:updateMsg("remove_hero",{oid = oid})
					audio:SendEvtUI('Play_UI_Cancel')
				end)
				local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(oid)
				if hero_skin_cfg and next(hero_skin_cfg) then
					LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")
				else
					LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", cfg.icon, "hero_head_ui")
				end
				
				xh_trans.gameObject:SetActive(i ~= 1)
				icon.transform:SetParent(trans, false)
				UIUtil.setLocalScale(icon.transform, 0.6, 0.6, 0.6)
				local luaBehaviour = icon:GetComponent("LuaBehaviour")
				local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
				if self.m_model.anim_slot == i then
					self.m_model.anim_slot = nil
				end
			else
				if  i > self.m_control.m_model.m_need_count then
					trans.gameObject:SetActive(false)
					xh_trans.gameObject:SetActive(false)
				else
					local consume = slot_consume[i-1]
					if consume[1] == 1 then
						local id = self.m_control.m_model.m_hero_id
						local function showHero()
							local icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,id,1, quality = consume[3]}, false, false)
							icon.transform:SetParent(trans, false)
							xh_trans.gameObject:SetActive(false)
							UIUtil.setLocalScale(icon.transform, 0.6, 0.6, 0.6)
							local luaBehaviour = icon:GetComponent("LuaBehaviour")
							local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
							lv_bg_img:SetActive(false)
							UIUtil.setOpacity(icon.transform, 0.6)
							local no_panel = luaBehaviour:FindGameObject("no_panel")
							no_panel:SetActive(true)
							local no_quality_img = luaBehaviour:FindGameObject("no_quality_img")
							no_quality_img:SetActive(false)
							local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
							no_quality_up_img:SetActive(false)
						end

						if universal_tab[i] then
							local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
							local universal_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM,hero_cfg.universal,universal_tab[i]})
							if universal_data.user_num - used_universal_num >= universal_data.data_num then
								used_universal_num = used_universal_num + universal_data.data_num
								local icon, ui_element = GameUtil:createItemElementByData(universal_data,true,false)
								icon.transform:SetParent(trans, false)
								xh_trans.gameObject:SetActive(false)
								UIUtil.setLocalScale(icon.transform, 0.8, 0.8, 0.8)
							else
								showHero()
							end
						else
							showHero()
						end
					else
						local icon = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,0,1}, false, false)
						icon.transform:SetParent(trans, false)
						xh_trans.gameObject:SetActive(false)
						UIUtil.setLocalScale(icon.transform, 0.6, 0.6, 0.6)
						UIUtil.setOpacity(icon.transform, 0.6)	
						local luaBehaviour = icon:GetComponent("LuaBehaviour")
						local item_img = luaBehaviour:FindGameObject("item_img")
						local no_panel = luaBehaviour:FindGameObject("no_panel")
						local quality_img = luaBehaviour:FindGameObject("quality_img")
						local add_img = luaBehaviour:FindGameObject("add_img")
						local add_panel = luaBehaviour:FindGameObject("add_panel")

						local type_bg = luaBehaviour:FindGameObject("type_bg")
						local camp_bg = luaBehaviour:FindGameObject("camp_bg")
						local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
						local lv_text = luaBehaviour:FindGameObject("lv_text")
						
						local no_quality_img = luaBehaviour:FindGameObject("no_quality_img")
						no_quality_img:SetActive(false)
						local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
						no_quality_up_img:SetActive(false)
						camp_bg:SetActive(true)
						lv_bg_img:SetActive(false)
						lv_text:SetActive(false)
						add_panel:SetActive(true)
						
						no_panel:SetActive(true)
						quality_img:SetActive(true)
						item_img:SetActive(false)
						add_img:SetActive(false)
						local evo = consume[3]
						local consume_race = self.m_model.m_need_race
						if consume[1] == 3 then
							consume_race = consume[4]
						end
						local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
						LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", quality_item.hero_item_frame, "hero_head_ui")
						local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
						no_quality_up_img:SetActive(quality_item.is_add)
						if quality_item.is_add then
							LuaBehaviourUtil.setImg(luaBehaviour,"no_quality_up_img", quality_item.add_img, "hero_head_ui")
						end
						local race_data = GlobalConfig.TYPE_HERO_RACE[consume_race]
						if race_data then
							LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
						end
					end
				end
			end
		end
	elseif self.m_control.m_model.m_need_count > 0 and self.m_control.m_model.m_need_count > 3 then	
		self:resetPosition()
		self.select_panel:SetActive(true)
		local slot_consume = self.m_model.m_slot_consume
		self:setObjectVisible("animation", false)
		self:setObjectVisible("animation_4", false)
		self:setObjectVisible("animation_5", false)
		local yuan_select_node = self:setObjectVisible("animation_"..self.m_control.m_model.m_need_count, true)
		if IsNull(yuan_select_node) then
			return
		end
		for k = 1, 5 do
			local head_node = UIUtil.setObjectVisible(yuan_select_node.transform, self.m_control.m_model.m_need_count >= k, "yuan0"..k)
			if not IsNull(head_node) then
				local luaBehaviour = UIUtil.findLuaBehaviour(head_node)
				local hero_node = luaBehaviour:FindGameObject("HeroNode")
				local ItemNode = luaBehaviour:FindGameObject("ItemNode")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeroNode", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ItemNode", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "s_xh", false)
				if self.m_control.m_model.m_select[k] then
					local oid = self.m_control.m_model.m_select[k]
					local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
					local ui_element = CommonUIUtil:updateHeroElement(hero_node,{RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false, function ()
						self:updateMsg("remove_hero",{oid = oid})
						audio:SendEvtUI('Play_UI_Cancel')
					end)
					local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(oid)
					if hero_skin_cfg and next(hero_skin_cfg) then
						LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")
					else
						LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", cfg.icon, "hero_head_ui")
					end
					UIUtil.setOpacity(hero_node.transform, 1)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "s_xh", k~= 1)
					local no_panel = ui_element.luaBehaviour:FindGameObject("no_panel")
					no_panel:SetActive(false)
				else
					UIUtil.setOpacity(hero_node.transform, 0.6)
					local consume = slot_consume[k-1]
					if consume[1] == 1 then
						local id = self.m_control.m_model.m_hero_id
						local function showHero()
							local ui_element = CommonUIUtil:updateHeroElement(hero_node,{RewardUtil.REWARD_TYPE_KEYS.HEROS,id,1, quality = consume[3]}, false, false)
							local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
							lv_bg_img:SetActive(false)
							local no_panel = ui_element.luaBehaviour:FindGameObject("no_panel")
							no_panel:SetActive(true)
							local no_quality_img = ui_element.luaBehaviour:FindGameObject("no_quality_img")
							no_quality_img:SetActive(false)
							local no_quality_up_img = ui_element.luaBehaviour:FindGameObject("no_quality_up_img")
							no_quality_up_img:SetActive(false)
						end
						
						if universal_tab[k] then
							local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
							local universal_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM,hero_cfg.universal,universal_tab[k]})
							if universal_data.user_num - used_universal_num >= universal_data.data_num then
								used_universal_num = used_universal_num + universal_data.data_num
								LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeroNode", false)
								LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ItemNode", true)
								local icon, ui_element = GameUtil:updateItemElementByData(ItemNode,universal_data,true,false)
							else
								showHero()
							end
						else
							showHero()
						end
					else
						local ui_element = CommonUIUtil:updateHeroElement(hero_node,{RewardUtil.REWARD_TYPE_KEYS.HEROS,0,1}, false, false)
						local item_img = ui_element.luaBehaviour:FindGameObject("item_img")
						local no_panel = ui_element.luaBehaviour:FindGameObject("no_panel")
						local quality_img = ui_element.luaBehaviour:FindGameObject("quality_img")
						local add_img = ui_element.luaBehaviour:FindGameObject("add_img")
						local add_panel = ui_element.luaBehaviour:FindGameObject("add_panel")
						local type_bg = ui_element.luaBehaviour:FindGameObject("type_bg")
						local camp_bg = ui_element.luaBehaviour:FindGameObject("camp_bg")
						local lv_bg_img = ui_element.luaBehaviour:FindGameObject("lv_bg_img")
						local lv_text = ui_element.luaBehaviour:FindGameObject("lv_text")
						local no_quality_img = ui_element.luaBehaviour:FindGameObject("no_quality_img")
						no_quality_img:SetActive(false)
						local no_quality_up_img = ui_element.luaBehaviour:FindGameObject("no_quality_up_img")
						no_quality_up_img:SetActive(false)
						camp_bg:SetActive(true)
						lv_bg_img:SetActive(false)
						lv_text:SetActive(false)
						add_panel:SetActive(true)
						
						no_panel:SetActive(true)
						quality_img:SetActive(true)
						item_img:SetActive(false)
						add_img:SetActive(false)
						local evo = consume[3]
						local consume_race = self.m_model.m_need_race
						if consume[1] == 3 then
							consume_race = consume[4]
						end
						local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
						LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", quality_item.hero_item_frame, "hero_head_ui")
						local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
						no_quality_up_img:SetActive(quality_item.is_add)
						if quality_item.is_add then
							LuaBehaviourUtil.setImg(luaBehaviour,"no_quality_up_img", quality_item.add_img, "hero_head_ui")
						end
						local race_data = GlobalConfig.TYPE_HERO_RACE[consume_race]
						if race_data then
							LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
						end
					end
				end
			end
		end
	else
		 self.select_panel:SetActive(false)
		for i=1,3 do
			local trans = self:findGameObject(string.format("select%d_panel", i)).transform
			local xh_trans = self:findGameObject(string.format("s_xh_%d", i)).transform
			xh_trans.gameObject:SetActive(false)
			UIUtil.destroyAllChild(trans)
		end
	end
end

function M:setSpine()
	if self.m_model.m_select[1] == nil then
	 	self.hero_sk:SetActive(false)
	else
	 	self.hero_sk:SetActive(true)
		 self.hero_sk.transform.localScale = Vector3.New(0.6, 0.6, 0)
	 	local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_select[1])
		local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero, cfg)
	 	local spine = hero_skin_cfg.hero_spine or cfg.hero_spine
		GameUtil:updateSpineLoadSet(self.hero_sk, "RoleSpine/"..spine, "idle", 0, true)
	end
end

function M:addHeroAction(data, slot)
	local oid = data.oid
	local hero, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local icon = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
	icon.transform:SetParent(self.content_node.transform, false)
	local pos = data.cell_obj.transform.position
	local world_pos = UIUtil.worldToScreenPoint(pos)
	icon.transform.position = UIUtil.screenToWorldPoint(world_pos)

	local trans = self:findGameObject(string.format("select%d_panel", slot)).transform
	local pos = trans.parent:TransformPoint(trans.localPosition)
	local target_pos = self.content_node.transform:InverseTransformPoint(pos)
	local sequence = Tweening.DOTween.Sequence()
    sequence:Append(icon.transform:DOLocalMove(target_pos,0.3))
    sequence:OnComplete(function ( )
    	UIUtil.destroyObject(icon)
	end)
	sequence:SetAutoKill(true)
end

function M:advancedAnimation()
	local animation = nil
	local animation_name = "an_advanced_card01"
	if self.m_control.m_model.m_need_count == 5 then
		animation = self:findGameObject("animation_5")
		animation_name = "an_advanced_card04"
		UIUtil.setLocalPosition(self.play_effect.transform,-238)
	elseif self.m_control.m_model.m_need_count == 4 then
		animation = self:findGameObject("animation_4")
		animation_name = "an_advanced_card03"
		UIUtil.setLocalPosition(self.play_effect.transform,-182.3)
	else
		animation = self:findGameObject("animation")
		if #self.m_model.m_select == 3 then
			animation_name = "an_advanced_card02"
		else
			animation_name = "an_advanced_card01"
		end
		UIUtil.setLocalPosition(self.play_effect.transform,-124.2,0,0)
	end
	local animator = animation:GetComponent("Animator")
	animator:CrossFade(animation_name,0)
	self.m_control:setOnceTimer(0.5, function ()
		self.play_effect:SetActive(true)
		audio:SendEvtUI("UI_Flash")
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(2)
		sequence:Append(self.hero_sk.transform:DOLocalMove(Vector3(-800, 0, 0), 0.3))
		sequence:OnComplete(function ()
			self.hero_sk:SetActive(false)
			self.select_panel:SetActive(false)
			self.advanced_btn:SetActive(false)
			self:unlockTouch()
		end)
		sequence:SetAutoKill(true)
	end)
end

function M:resetPosition()
	self:findGameObject("s02").transform.localPosition = self.m_point_2
	self:findGameObject("s03").transform.localPosition = self.m_point_3
	self:setObjectVisible("select2_panel", true)
	self:setObjectVisible("select3_panel", true)
	local animation = nil
	animation = self:findGameObject("animation")
	local animator = animation:GetComponent("Animator")
	animator:CrossFade("idle",0)

	local animation_5 = self:findGameObject("animation_5")
	local animator = animation_5:GetComponent("Animator")
	animator:CrossFade("idle",0)
	local luaBehaviour_5 = UIUtil.findLuaBehaviour(animation_5)
	for i=1,5 do
		local yuan_obj = luaBehaviour_5:FindGameObject("yuan0"..i)
		local pos_obj =luaBehaviour_5:FindGameObject("pos_"..i)
		yuan_obj.transform.localPosition = pos_obj.transform.localPosition 
	end

	local animation_4 = self:findGameObject("animation_4")
	local animator = animation_4:GetComponent("Animator")
	animator:CrossFade("idle",0)
	local luaBehaviour_4 = UIUtil.findLuaBehaviour(animation_4)
	for i=1,4 do
		local yuan_obj = luaBehaviour_4:FindGameObject("yuan0"..i)
		local pos_obj =luaBehaviour_4:FindGameObject("pos_"..i)
		yuan_obj.transform.localPosition = pos_obj.transform.localPosition 
	end
end

function M:setToggleActive(flag)
	self.m_race_toggle_flag = flag
	--self.RaceToggle:SetActive(flag)
end

return M