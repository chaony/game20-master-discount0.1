local M = class("ShareLvPopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareLvPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn = "sort_1_toggle", name = "sort_1_text", language = "shareLv_str_0023",},
	{btn = "sort_2_toggle", name = "sort_2_text", language = "shareLv_str_0024",},
}

function M:onEnter()
	self.sort_toggle_bg = self:findGameObject("sort_toggle_bg")
	self.sort_toggle_bg:SetActive(true)
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		self:setTextByLanKey(v.name, v.language)
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("sort_btn",data)
				self:setTextByLanKey("race_toggle_btn_text", __TAB_BTN_NODE[data].language)
			end
		end, i, self.m_uiName)
	end
	self.sort_toggle_bg:SetActive(false)
	self.m_sort_toggle_flag = false
	
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 7})
	self:setTextByLanKey("close_title_text", "new_str_0155")
	self:setTextByLanKey("sy_text", "share_sydj_text")
	self.bottom_panel = self:findGameObject("bottom_panel")
	self.lv_btn = self:findGameObject("lv_btn")
	self.open_lv_btn = self:findButton("open_lv_btn")
	self.exp_btn = self:findButton("exp_btn")
	self.tips_text_bg_img = self:findGameObject("tips_text_bg_img")
	self.lv_slider = self:findSlider("lv_slider")
	--self.hero_lv_bg = self:findGameObject("hero_lv_bg")
	self.cur_hero_icon = self:findGameObject("cur_hero_icon")
	self.UI_ShareLvPop_glow = self:findGameObject("UI_ShareLvPop_glow")
	self:setTextByLanKey("tips_text", Language:getTextByKey("shareLv_str_0010"))
	self:setTextByLanKey("share_btn_text", "shareLv_str_0018")
	self:setTextByLanKey("hero_list_title_text", "shareLv_str_0018")
	self.top_hero_nodes = {}
	for i=1, 5 do
		self.top_hero_nodes[i] = self:findGameObject("hero_node_" .. i)
	end
	self.m_down_time = {}
	self.open_btn = self:findGameObject("open_btn")
	self:refreshUI()
	self:initDownTime()
	self.changAn_btn = self.exp_btn:GetComponent("ChangAn")
	if self.changAn_btn then
		local long_click = false
		local function m_levelupclick()-- 长按循环
			self:updateMsg("lv_up")
        end
        local function m_levelupclickup() -- 长按放开
			self:updateMsg("lv_btn")
        end
		if self.changAn_btn then
			self.changAn_btn:RegistButtonClick(m_levelupclickup, m_levelupclick)
		end
	end
	
end

function M:refreshUI()
	self.bottom_panel:SetActive(self.m_model.m_unlock == 2)
	self.lv_btn:SetActive(self.m_model.m_up_lv and self.m_model.m_unlock == 2)
	self:setObjectVisible("top_tips_text",self.m_model.m_unlock == 2)
	--self.tips_text_bg_img:SetActive(not self.m_model.m_up_lv)
	self.open_lv_btn.gameObject:SetActive(self.m_model.m_unlock == 1)
	--self.hero_lv_bg:SetActive(self.m_model.m_unlock == 0)
	self:setObjectVisible("Image _zp3", self.m_model.m_unlock == 0)
	self:setObjectVisible("Image _zp2", self.m_model.m_unlock == 2)
	local min_lv_hero = self.m_model:getMinLvHero()
	if min_lv_hero then
		--self:setText("hero_lv_text", Language:getTextByKey("shareLv_str_0019") .. min_lv_hero.lv)
		--CommonUIUtil:updateHeroElement(self.cur_hero_icon, {RewardUtil.REWARD_TYPE_KEYS.HEROS,min_lv_hero.id,1,min_lv_hero.oid})
	end
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	if self.m_model.m_unlock > 1 then
		local crystal = crystal_upgrade[self.m_model.m_data.clv]
		--local cfg = crystal[self.m_model.m_data.crystal_energy + 1]
		local user_data = UserDataManager.user_data
		local coin = user_data:getUserStatusDataByKey("coin")
		local coin_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 1})
		self:setImg(coin_img.icon_name, coin_img.atlas_name or "item_icon", "coin_img")
		if coin < crystal.coin then
			self:setText("coin_text", "<color=#AE5441>" .. GameUtil:formatValueToString(coin) .. "</color>/" .. GameUtil:formatValueToString(crystal.coin))
		else
			self:setText("coin_text", GameUtil:formatValueToString(coin) .. "/" .. GameUtil:formatValueToString(crystal.coin))
		end
		local hero_exp = user_data:getUserStatusDataByKey("hero_exp")
		local exp_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 1})
		self:setImg(exp_img.icon_name, exp_img.atlas_name or "item_icon", "hero_exp_img")
		if hero_exp < crystal.exp then
			self:setText("hero_exp_text", "<color=#AE5441>" .. GameUtil:formatValueToString(hero_exp) .. "</color>/" .. GameUtil:formatValueToString(crystal.exp))
		else
			self:setText("hero_exp_text", GameUtil:formatValueToString(hero_exp) .. "/" .. GameUtil:formatValueToString(crystal.exp))
		end
		local dust = user_data:getUserStatusDataByKey("dust")
		local dust_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 1})
		self:setImg(dust_img.icon_name, dust_img.atlas_name or "item_icon", "dust_img")
		if dust < crystal.special_num then
			self:setText("dust_text", "<color=#AE5441>" .. GameUtil:formatValueToString(dust) .. "</color>/" .. GameUtil:formatValueToString(crystal.special_num))
		else
			self:setText("dust_text", GameUtil:formatValueToString(dust) .. "/" .. GameUtil:formatValueToString(crystal.special_num))
		end
		self:setObjectVisible("dust_panel", crystal.special_num > 0)
		self:setText("lv_value_text", string.format("%d/%d", crystal.display_level or 0, self.m_model.m_data.clv_limit))
		local full_combat = self.m_model:getCombat()
		self:setText("power_text", GameUtil:formatValueToString(full_combat))
		
		if self.m_model.m_unlock == 1 then
			self.open_lv_btn.interactable = true
			--UIUtil.setLocalPosition(self.tips_text.transform, 0, 114, 0)
			self:setText("tips_text", string.format(Language:getTextByKey("shareLv_str_0017"), self.m_model.m_open_lv))
		else
			if crystal and crystal.display_level and crystal.display_level >= 400 then
				self:setTextByLanKey("top_tips_text", "tid#ChuanGongDianDes_2")
			elseif crystal and crystal.display_level and crystal.display_level >= 300 then
				self:setTextByLanKey("top_tips_text", "tid#ChuanGongDianDes_1")
			else
				self:setTextByLanKey("top_tips_text", "")
			end
			local total_times = crystal.pull_energy
			local lv = self.m_model.m_data.clv + 1
			local next_crystal = crystal_upgrade[lv]
			while(crystal.display_level == next_crystal.display_level)
			do
				total_times = next_crystal.pull_energy
				lv = lv + 1
				next_crystal = crystal_upgrade[lv]
			end

			for i=1, 9 do
				local lv_point = self:findGameObject("lv_point_" .. i)
				if not IsNull(lv_point) then
					if i > total_times-1 then
						lv_point:SetActive(false)	
					else
						lv_point:SetActive(i < crystal.pull_energy)
						--self:setImg(i < crystal.pull_energy and "a_lgf_zhuangshi_liangdian" or "a_lgf_zhuangshi_kongdian", "common_ui", "lv_point_" .. i)
					end
				end
			end
			--Logger.log(crystal.pull_energy,"crystal.pull_energy =======")
			local value = (crystal.pull_energy - 2)/(total_times-1)
			--Logger.log(value,"value =======")
			self.lv_slider.value = value
			if crystal.pull_energy == total_times then
				self.exp_btn.gameObject:SetActive(false)
				if self.changAn_btn then
					self.changAn_btn:StopClick(false)
				end
				self.lv_btn.gameObject:SetActive(true)
			else
				self.exp_btn.gameObject:SetActive(true)
				self.lv_btn.gameObject:SetActive(false)
			end
		end
	else
		if min_lv_hero then
			self:setText("lv_value_text",  min_lv_hero.lv..Language:getTextByKey("new_str_0428"))
		end
	end
	self:findGameObject("lv_text"):GetComponent("ContentSizeFitter"):SetLayoutHorizontal()
	self:findGameObject("lv_value_text"):GetComponent("ContentSizeFitter"):SetLayoutHorizontal()

	self:refreshTopHero()
	self:refreshHero()
	self:refreshRedPoint()

	--快速导航
	self:setObjectVisible("guide_btn", true)
	self:setObjectVisible("rank_btn", false) --去掉排行
	--self:setObjectVisible("rank_btn", self.m_model:showRank() == true)
end

function M:refreshTopHero()
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local first_last_index = 0
	for i, v in ipairs(self.top_hero_nodes) do
		local pos
		local rotation
		local scale
		if self.m_model.m_unlock == 2 then
			local node = self:findGameObject("second_pos_" .. i)
			pos = node.transform.localPosition
			rotation = node.transform.rotation
			scale = node.transform.localScale
		else
			local node = self:findGameObject("first_pos_" .. i)
			pos = node.transform.localPosition
			rotation = node.transform.rotation
			scale = node.transform.localScale
		end
		--v.transform.localPosition = pos
		--v.transform.rotation = rotation
		--v.transform.localScale = scale
		local data = self.m_model.m_show_hero[i]
		if data and data ~= "" and not(self.m_model.m_data.clv_unlock) then
			v:SetActive(true)
			if i == 1 then
				self:setObjectVisible("mid_guang_img", true)
			end
			first_last_index = i
			local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(data)
			--Logger.log(hero_data,"hero_data ====")
			local luaBehaviour = UIUtil.findLuaBehaviour(v)
			local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
			--if race_data then
				--LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", "a_ui_currency_qinglong", "common_ui")
				-- LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.big_race_icon, "common_ui")
			--end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_img", false)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img", hero_cfg.is_sp > 1)
			GameUtil:updateSpByData(luaBehaviour,hero_cfg)
			local type_data = GlobalConfig.TYPE_HERO_PROPERTY[hero_cfg.type]
			--if type_data then
			--	LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "common_ui")
			--end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
			local icon_name = "h_"..hero_cfg.icon.."_l"
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fate_icon_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
			local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_data.evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
			local big_quality_data= GlobalConfig.QUALITY_FRAME[hero_data.evo] or GlobalConfig.QUALITY_FRAME[1]
			local lv = hero_data.clv > 0 and hero_data.clv or hero_data.lv
			local upgrade_cfg = hero_upgrade[lv]
			local show_lv = "Lv.".. upgrade_cfg.display_level
			local lv_text = LuaBehaviourUtil.setText(luaBehaviour,"lv_text", show_lv)
			local name = LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(hero_cfg.name))
			GameUtil:updateHeroStarsByQuality(v, hero_data.evo)
			-- LuaBehaviourUtil.setTexture(luaBehaviour, "hero_img", "HeroIcon/"..icon_name, "heroicon_"..icon_name)
			-- LuaBehaviourUtil.setTexture(luaBehaviour, "hero_bg", "HeroIcon/"..big_quality_data.card_frame_name, "heroicon_"..big_quality_data.card_frame_name)
			local hero_img = luaBehaviour:FindGameObject("hero_img")
			local hero_bg = luaBehaviour:FindGameObject("hero_bg")
			GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. icon_name)
			GameUtil:updateResourcesImg(hero_bg, "Texture/HeroIcon/" .. big_quality_data.card_frame_name)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", quality_item.is_add)
			if quality_item.is_add and big_quality_data.big_frame_add_name then
				LuaBehaviourUtil.setImg(luaBehaviour, "kuang", big_quality_data.big_frame_add_name, "hero_head_ui")
			end
			local red_point_img = luaBehaviour:FindGameObject("red_point_img")
			red_point_img:SetActive(false)
			local is_fate = UserDataManager:getHeroIsFates(hero_data.oid)
			if is_fate then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fate_icon_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
			end
		else
			v:SetActive(false)
			if i == 1 then
				self:setObjectVisible("mid_guang_img", false)
			end
		end
	end

	if self.m_model.m_unlock == 2 then
		self.UI_ShareLvPop_glow:SetActive(false)
	else
		local node = self:findGameObject("first_pos_" .. first_last_index)
		if node then
			self.UI_ShareLvPop_glow:SetActive(true)
			local pos = node.transform.localPosition
			self.UI_ShareLvPop_glow.transform.localPosition = pos
			self.UI_ShareLvPop_glow.transform.localScale = node.transform.localScale
		else
			self.UI_ShareLvPop_glow:SetActive(false)
		end
	end
	self.UI_ShareLvPop_glow:SetActive(false) --旧特效暂时隐藏 3-13日
end

function M:refreshRedPoint()
	local share_red_point_img = self:findGameObject("share_red_point_img")
	local red_point = RedPointUtil:hasRedPointById(6)
	share_red_point_img:SetActive(red_point == true)
	local red_flag = RedPointUtil:hasRedPointById(6001)
	self:setObjectVisible("open_btn_red_point_img", red_flag == true)
	self:refreshLvupRedpoint()
end

--client:纯前端升级
function M:showLvEffect(client)
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[self.m_model.m_data.clv]
	if crystal.pull_energy == 1 then
		self.lv_slider.value = 1
		self:setObjectVisible("UI_ShareLv_Baofa_001", true)
		for i,v in ipairs(self.itemSolt) do
			self:creatLiuGuangEffect(v)
		end
		self.m_control:setOnceTimer(0.5, function()
			self:setObjectVisible("UI_ShareLv_Baofa_001", false)
			if client == nil or client == false then -- client 纯前端升级不刷新英雄信息
				self:refreshUI()
			else
				self:refreshClientUI()	
			end
		end)
	else
		local point = crystal.pull_energy - 1
		local lv_point_bg = self:findGameObject("lv_point_bg_" .. point)
		local luaBehaviour = lv_point_bg:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_ShareLv_Xiaobaodian_001", false)
		self:creatDianliangEffect(lv_point_bg)
		if client == nil or client == false then -- client 纯前端升级不刷新英雄信息
			self:refreshUI()
		else
			self:refreshClientUI()	
		end
	end
end

--纯前端升级刷新UI
function M:refreshClientUI()
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[self.m_model.m_data.clv]
	local user_data = self.m_model.temp_user_data
	local coin = user_data:getUserStatusDataByKey("coin")
	local coin_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 1})
	self:setImg(coin_img.icon_name, coin_img.atlas_name or "item_icon", "coin_img")
	if coin < crystal.coin then
		self:setText("coin_text", "<color=#AE5441>" .. GameUtil:formatValueToString(coin) .. "</color>/" .. GameUtil:formatValueToString(crystal.coin))
	else
		self:setText("coin_text", GameUtil:formatValueToString(coin) .. "/" .. GameUtil:formatValueToString(crystal.coin))
	end
	local hero_exp = user_data:getUserStatusDataByKey("hero_exp")
	local exp_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 1})
	self:setImg(exp_img.icon_name, exp_img.atlas_name or "item_icon", "hero_exp_img")
	if hero_exp < crystal.exp then
		self:setText("hero_exp_text", "<color=#AE5441>" .. GameUtil:formatValueToString(hero_exp) .. "</color>/" .. GameUtil:formatValueToString(crystal.exp))
	else
		self:setText("hero_exp_text", GameUtil:formatValueToString(hero_exp) .. "/" .. GameUtil:formatValueToString(crystal.exp))
	end
	local dust = user_data:getUserStatusDataByKey("dust")
	local dust_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 1})
	self:setImg(dust_img.icon_name, dust_img.atlas_name or "item_icon", "dust_img")
	if dust < crystal.special_num then
		self:setText("dust_text", "<color=#AE5441>" .. GameUtil:formatValueToString(dust) .. "</color>/" .. GameUtil:formatValueToString(crystal.special_num))
	else
		self:setText("dust_text", GameUtil:formatValueToString(dust) .. "/" .. GameUtil:formatValueToString(crystal.special_num))
	end
	self:setObjectVisible("dust_panel", crystal.special_num > 0)
	self:setText("lv_value_text", string.format("%d/%d", crystal.display_level or 0, self.m_model.m_data.clv_limit))

	if self.m_model.m_unlock == 1 then
		self.open_lv_btn.interactable = true
		self:setText("tips_text", string.format(Language:getTextByKey("shareLv_str_0017"), self.m_model.m_open_lv))
	else
		local total_times = crystal.pull_energy
		local lv = self.m_model.m_data.clv + 1
		local next_crystal = crystal_upgrade[lv]
		while(crystal.display_level == next_crystal.display_level)
		do
			total_times = next_crystal.pull_energy
			lv = lv + 1
			next_crystal = crystal_upgrade[lv]
		end

		for i=1, 9 do
			local lv_point = self:findGameObject("lv_point_" .. i)
			if not IsNull(lv_point) then
				if i > total_times-1 then
					lv_point:SetActive(false)	
				else
					lv_point:SetActive(i < crystal.pull_energy)
				end
			end
		end
		local value = (crystal.pull_energy - 2)/(total_times-1)
		self.lv_slider.value = value
		if crystal.pull_energy == total_times then
			self.exp_btn.gameObject:SetActive(false)
			self.m_control:requestUpgrade(false)
			if self.changAn_btn then
				self.changAn_btn:StopClick(false)
			end
			self.lv_btn.gameObject:SetActive(true)
		else
			self.exp_btn.gameObject:SetActive(true)
			self.lv_btn.gameObject:SetActive(false)
		end
	end

end

-------------------------------------------------

function M:refreshHero()
	self:updateListScroll()
	local user_data = UserDataManager.user_data
	local num = 0
	for i,v in ipairs(self.m_model.m_data.crystal_slot) do
		if v.hid and v.hid ~= "" then
			num = num + 1
		end
	end
	self:setText("num_text", num .. "/" .. #self.m_model.m_data.crystal_slot)
	self.open_btn:SetActive(#self.m_model.m_data.crystal_slot < self.m_model.m_data.max_slot_num)
end

function M:updateListScroll()
	local data = self.m_model.m_list
	self.itemSolt = {}
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("hero_scroll")
        local params = {
        	ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
				local data = cell_data
				self.itemSolt[index] = cell_object
                self:listHandle(cell_object, index)
                if index == 1 then
                	self.m_guide_cell = cell_object
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                -- self:cellBtnHandle(click_name, index)
            end,
			ui_name = self.m_uiName
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:listHandle(obj, id)
	-- UIUtil.setScale(obj.transform,0.8)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local add_node = luaBehaviour:FindGameObject("add_node")
	local time_node = luaBehaviour:FindGameObject("time_node")
	local MainHeroNodeCell = luaBehaviour:FindGameObject("MainHeroNodeCell")
	local remove_btn = luaBehaviour:FindGameObject("remove_btn")
	MainHeroNodeCell:SetActive(false)
	add_node:SetActive(false)
	time_node:SetActive(false)
	remove_btn:SetActive(false)
	local lock_node = luaBehaviour:FindGameObject("lock_node")
	lock_node:SetActive(false)
	local down_time_text = luaBehaviour:FindText("down_time_text")
	down_time_text.gameObject:SetActive(false)
	self.m_down_time[down_time_text] = nil
	local data = self.m_model:getSoltDataByIndex(id)
	-- local red_point_img = luaBehaviour:FindGameObject("red_point_img")--红点
	-- red_point_img:SetActive(false)
	local add_panel = luaBehaviour:FindGameObject("add_panel")
	-- UIUtil.destroyAllChild(add_panel.transform)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_red_point_img", false)
	if data then
		if data.hid and data.hid ~= "" then
			local oid = data.hid
			local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
			local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
			local evolution = hero_evolution[cfg.max_evo or 8]
	        local function clickCall()
	            self:updateMsg("remove_hero", {id, oid})
	        end 
	        MainHeroNodeCell:SetActive(true)
	        remove_btn:SetActive(true)
	        if cfg then
	        	GameUtil:updateHeroContentByData(obj,data,cfg)
	        	--CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid})
	        	UIUtil.setButtonClick(obj.transform, clickCall, nil, "remove_btn")
	        end
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			local tips_img = luaBehaviour:FindGameObject("tips_text")
			local tips_text = luaBehaviour:FindText("tips_text")
			if data.clv == evolution.level_max and data.clv ~= self.m_model.m_data.clv then
				tips_img:SetActive(true)
				tips_text.text = Language:getTextByKey("shareLv_str_0021")
			else
				tips_img:SetActive(false)
			end
			--local lv_text = luaBehaviour:FindGameObject("lv_text")
			--lv_text:SetActive(true)
			--lv_text:GetComponent("Text").text = "Lv" .. data.clv
			-- local mask_img = luaBehaviour:FindGameObject("mask_img")
			-- mask_img:SetActive(false)
			-- add_panel:SetActive(true)
			-- ResourceUtil:LoadUIGameObject("ShareLv/ShareLv_LiuGuang_001", Vector3.zero, add_panel)
		else
			local down_time = data.etime - UserDataManager:getServerTime()
			if down_time > 0 then
				local function callback(obj, data)
					self:updateMsg("remove_time", data)
				end
				MainHeroNodeCell:SetActive(false)
				add_node:SetActive(false)
				lock_node:SetActive(false)
				time_node:SetActive(true)
				remove_btn:SetActive(false)
				--CommonUIUtil:updateHeroElementAdd(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS)
				UIUtil.setButtonClick(obj.transform, callback, id, "time_node/removeTime_btn")
				local luaBehaviour = obj:GetComponent("LuaBehaviour")
				local tips_img = luaBehaviour:FindGameObject("tips_text")
				tips_img:SetActive(true)
				-- local chuangong_img = luaBehaviour:FindGameObject("chuangong_img")
				-- chuangong_img:SetActive(false)
				local tips_text = luaBehaviour:FindText("tips_text")
				tips_text.text = Language:getTextByKey("shareLv_str_0011")
				local down_time_text = luaBehaviour:FindText("down_time_text")
				down_time_text.gameObject:SetActive(true)
				self.m_down_time[down_time_text] = id
				local mask_img = luaBehaviour:FindGameObject("mask_img")
				mask_img:SetActive(false)
			else
				local function callback(obj, data)
					self:updateMsg("add_hero", data)
				end
				MainHeroNodeCell:SetActive(false)
				lock_node:SetActive(false)
				time_node:SetActive(false)
				add_node:SetActive(true)
				remove_btn:SetActive(false)
				--CommonUIUtil:updateHeroElementAdd(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS)
				UIUtil.setButtonClick(obj.transform, callback, id, "add_node/add_btn")

				local luaBehaviour = obj:GetComponent("LuaBehaviour")
				local tips_img = luaBehaviour:FindGameObject("tips_text")
				tips_img:SetActive(false)
				-- local chuangong_img = luaBehaviour:FindGameObject("chuangong_img") -- k可使用
				-- chuangong_img:SetActive(true)
				-- red_point_img:SetActive(true)
				-- local mask_img = luaBehaviour:FindGameObject("mask_img")
				-- mask_img:SetActive(false)
			end
			
		end
	else
		if id == #self.m_model.m_data.crystal_slot + 1 then
			local function callback(obj, data)
				self:updateMsg("open_slot", data)
			end
			MainHeroNodeCell:SetActive(false)
			lock_node:SetActive(true)
			time_node:SetActive(false)
			add_node:SetActive(false)
			remove_btn:SetActive(false)
			--CommonUIUtil:updateHeroElementAdd(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS)
			UIUtil.setButtonClick(obj.transform, callback, id, "lock_node/suo_btn")
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			-- local lock_img = luaBehaviour:FindGameObject("lock_img")
			-- -- UIUtil.findImage(lock_img.transform).enabled = false
			-- lock_img:SetActive(true)
			local tips_img = luaBehaviour:FindGameObject("tips_text")
			tips_img:SetActive(false)
			-- local mask_img = luaBehaviour:FindGameObject("mask_img")
			-- mask_img:SetActive(false)
			local red_flag = RedPointUtil:hasRedPointById(6001)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_red_point_img", red_flag)
		else
			local function callback(obj, data)
				--GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("shareLv_str_0001"), delay_close = 2})
				self:updateMsg("open_slot", data)
			end
			--CommonUIUtil:updateHeroElementAdd(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS)
			UIUtil.setButtonClick(obj.transform, callback, nil, "lock_node/suo_btn")
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			add_node:SetActive(false)
			lock_node:SetActive(true)
			remove_btn:SetActive(false)
			-- local lock_img = luaBehaviour:FindGameObject("lock_img")
			-- -- UIUtil.findImage(lock_img.transform).enabled = false
			-- lock_img:SetActive(true)
			local tips_img = luaBehaviour:FindGameObject("tips_text")
			tips_img:SetActive(true)
			local tips_text = luaBehaviour:FindText("tips_text")
			tips_text.text = ""
			-- local mask_img = luaBehaviour:FindGameObject("mask_img")
			-- mask_img:SetActive(true)
			-- local mask_text = luaBehaviour:FindGameObject("mask_text")
			-- mask_text:SetActive(false)
		end
	end
end


function M:creatEffect(data)
	if next(data.slot) ~= nil then
		for k,v in pairs(data.slot) do
			local index = self.m_model:getIndexByOid(v.hid)
			if self.itemSolt[index] then
				local cell_obj = self:creatEffectItem(self.itemSolt[index])
				local LuaBehaviour = UIUtil.findLuaBehaviour(self.itemSolt[index])
				if LuaBehaviour then
					local lv_text = LuaBehaviour:FindGameObject("lv_text")
					local sequence = Tweening.DOTween.Sequence()
					sequence:SetDelay(0.4)
	    			sequence:Append(lv_text.transform:DOScale(1, 0.1))
	    			sequence:Append(lv_text.transform:DOScale(1.5, 0.1))
	    			sequence:Append(lv_text.transform:DOScale(1, 0.1))
					sequence:SetAutoKill(true)
				end
				self.m_control:setOnceTimer(1, function ()
					U3DUtil:Destroy(cell_obj)
				end)
			end
		end
	end
end

function M:creatEffectItem(parent)
	local item = ResourceUtil:GetUIEffectItem("Common/UI_ShareLvPop_JiHuo_01", parent)
	return item
end

--创建点亮特效
function M:creatDianliangEffect(parent)
	local item = ResourceUtil:GetUIEffectItem("ShareLvPop/UI_ShareLvPop_Chongneng_Dianliang", parent)
	item.transform:SetParent(parent.transform, false)
	self.m_control:setOnceTimer(0.4, function ()
		UIUtil.destroyObject(item)
	end)
end

--创建流光特效
function M:creatLiuGuangEffect(parent)
	local item = ResourceUtil:GetUIEffectItem("ShareLvPop/UI_ShareLvPop_Chongneng_LiuGuang", parent)
	item.transform:SetParent(parent.transform, false)
	self.m_control:setOnceTimer(0.4, function ()
		UIUtil.destroyObject(item)
	end)
end

function M:initDownTime()
	local function tick(dt)
		for k,v in pairs(self.m_down_time) do
			local data = self.m_model:getSoltDataByIndex(v)
			local down_time = data.etime - UserDataManager:getServerTime()
			if down_time >= 0 then
				k.text = GameUtil:formatTimeBySecond(down_time)
			else
				self:updateMsg("fresh_data")
			end
		end
	end
	self.m_control:setTimer(1,tick)
	tick()
end

function M:setToggleActive(flag)
	self.m_sort_toggle_flag = flag
	self.sort_toggle_bg:SetActive(flag)
end

--刷新升级红点
function M:refreshLvupRedpoint()
	self:setObjectVisible("lv_btn_red_point", self.m_model:checkCelCanLvUp() == true)
	self:setObjectVisible("exp_btn_red_point", self.m_model:checkCelCanLvUp() == true)
end


function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M