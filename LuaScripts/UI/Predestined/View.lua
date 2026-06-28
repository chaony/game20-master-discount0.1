local M = class("PredestinedView",LikeOO.OOPopBase)

M.m_uiName = "Predestined/Predestined"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local paopao_tab = {"a_qyq_qipao_grey","a_qyq_qipao_green","a_qyq_qipao_blue","a_qyq_qipao_purple","a_qyq_qipao_red","a_qyq_qipao_golden"}
local paopao_effect_tab = {"UI_Predestined_Pao_grey","UI_Predestined_Pao_green","UI_Predestined_Pao_blue","UI_Predestined_Pao_purple","UI_Predestined_Pao_red","UI_Predestined_Pao_golden"}
function M:onEnter()
	local red_flag = RedPointUtil:hasRedPointById(114)
	UserDataManager:removeRedDotByKey("gacha7_once")
	if self.m_model.m_is_sp then
		self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 51})
		self:setTextByLanKey("times_top_text", "predestined_str_022")
	else
		self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 11})
		self:setTextByLanKey("times_top_text", "predestined_str_005")
	end
	self:setTextByLanKey("tips_text", "predestined_str_002")
	self:setTextByLanKey("times_des_text", "predestined_str_003")
	self:setTextByLanKey("probability_btn_text", "predestined_str_004")
	self:setTextByLanKey("wish_help_btn_text", "predestined_str_023")
	self:refreshUI()
	self:refreshHeroSpine()
	self:refreshItem()
	self.m_paopao_scale = {}
	for i=1,6 do
		local item_paopao = self:findGameObject("item_paopao_" .. i)
		self.m_paopao_scale[i] = item_paopao.transform.localScale
	end

	--toggle相关
	self:setTextByLanKey("toggle3_race_text", "Pub_str_0051")
	for i = 1, 4 do
		self:setObjectVisible("toggle3_race" .. i, false)
		self:setObjectVisible("race_btn_" .. i, false)
	end
	local races = UserDataManager.gacha_open_race_pools
	for i,v in ipairs(races) do
		local index = v - 2
		self:setObjectVisible("toggle3_race" .. index, true)
		self:setObjectVisible("race_btn_" .. index, true)
	end
	if UserDataManager.m_gacha_predestined_end > 0 then
		--self:setObjectVisible("toggle4", true)
		self.toggle4_time_text = self:findText("toggle4_time_text")
	else
		--self:setObjectVisible("toggle4", false)
	end

	self.time_text = self:findText("time_text")

	self.m_is_update = true
end

function M:palyGachaAnimCallback(response)
	--sp抽卡只是简单的特效
	if self.m_model.m_is_sp then
		self:setObjectVisible("UI_Predestined_xinjieyuan", false)
		self:setObjectVisible("UI_Predestined_xinjieyuan", true)
		local function animcall(msg)
			self:unlockTouch()
			local function call_back()
				if self:checkFirstYinYangHeroFlag(response.reward_show) then
					GameUtil:openAppRating() -- 评价
				end
			end
			RewardUtil:rewardTipsByRewards(response.reward_show,call_back)
		end
		self.m_control:setOnceTimer(2, animcall)
		audio:SendEvtUI("UI_QianYuanBridge_JieYuan")
	else
		local base_panel = self:findGameObject("base_panel")
		local luaBehaviour = base_panel:GetComponent("LuaBehaviour")
		local anim = base_panel:GetComponent("Animation")
		local function animcall(msg)
			self:unlockTouch()
			local function call_back()
				if self:checkFirstYinYangHeroFlag(response.reward_show) then
					GameUtil:openAppRating() -- 评价
				end
			end
			RewardUtil:rewardTipsByRewards(response.reward_show,call_back)
			self.m_control:setOnceTimer(0.1, function()
				for i,v in ipairs(self.m_paopao_scale or {}) do
					local item_paopao = self:findGameObject("item_paopao_" .. i)
					item_paopao.transform.localScale = v
				end
			end)
		end
		anim:Play()
		self.m_control:setOnceTimer(1, animcall)
		LuaBehaviourUtil.addAnimEvent(luaBehaviour,nil)
		audio:SendEvtUI("UI_QianYuanBridge_JieYuan")
	end
end

-- 检查是否是第一次抽到阴阳卡
function M:checkFirstYinYangHeroFlag(reward_show)
	local flag = false
	local appRating_yinYang_hero = U3DUtil:PlayerPrefs_GetString("appRating_yinYang_hero", "")
	local hero_detail_cfg = ConfigManager:getCfgByName("hero_detail")
	if appRating_yinYang_hero == "" then
		for i, v in pairs(reward_show) do
			if v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
				local hero_cfg = hero_detail_cfg[v[2]]
				if hero_cfg.race > 4 then
					U3DUtil:PlayerPrefs_SetString("appRating_yinYang_hero", "1")
					flag = true
				end
			end
		end
	end
	return flag
end

function M:refreshUI()
	if self.m_model.m_data.aim_hero and self.m_model.m_data.aim_hero > 0 then
		self:setObjectVisible("base_panel", true)
		self:setObjectVisible("first_panel", false)
		self:setText("times_text", self.m_model.m_times)
	else
		self:setObjectVisible("base_panel", false)
		self:setObjectVisible("first_panel", true)
	end
	local max = self.m_model:getMaxTimes()
	local cur_times = math.min(self.m_model.m_data.diamond_times, max)
	local color = cur_times >= max and "<color=#F33535>" or "<color=#EECC1C>"
	self:setText("max_times_text", color .. Language:getTextByKey("tid#limit_3") ..  cur_times .. "/" .. max .. "</color>")
	--local one_btn_num = self:findText("one_btn_num")
	--local _,count = self.m_model:getItemCount(1)
	--if count >= 1 then
	--	one_btn_num.color = GlobalConfig.COMMON_COLLOR.COMMON_1
	--	local red_flag = RedPointUtil:hasRedPointById(114)
	--	self:setObjectVisible("one_red_point_img", red_flag)
	--else
	--	one_btn_num.color = GlobalConfig.COMMON_COLLOR.COMMON_11
	--	self:setObjectVisible("one_red_point_img", false)
	--end
	
	--local ten_btn_num = self:findText("ten_btn_num")
	--local _,count = self.m_model:getItemCount(10)
	--if count >= 10 then
	--	ten_btn_num.color = GlobalConfig.COMMON_COLLOR.COMMON_1
	--	self:setObjectVisible("ten_red_point_img", true)
	--else
	--	ten_btn_num.color = GlobalConfig.COMMON_COLLOR.COMMON_11
	--	self:setObjectVisible("ten_red_point_img", false)
	--end

	if self.m_model.m_gacha_id then
		local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_gacha_id]
		local cost = gacha.cost
		self:setObjectVisible("one_red_point_img", false)
		for i,v in ipairs(cost or {}) do
			local itemData = RewardUtil:getProcessRewardData(v)
			if itemData.user_num >= itemData.data_num then
				self:setImg(itemData.icon_name, itemData.atlas_name, "one_btn_item_img")
				self:setText("one_btn_num", itemData.data_num)
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					self:setObjectVisible("one_red_point_img", true)
				end
				break
			else
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					local min_count = gacha.limit or 10
					if itemData.user_num >= min_count and itemData.user_num > 0 then
						self:setImg(itemData.icon_name, itemData.atlas_name, "one_btn_item_img")
						self:setText("one_btn_num", "<color=#F33535>" .. itemData.data_num .. "</color>")
						break
					end
				end

				if i == #cost then
					self:setImg(itemData.icon_name, itemData.atlas_name, "one_btn_item_img")
					self:setText("one_btn_num", "<color=#F33535>" .. itemData.data_num .. "</color>")
				end
			end
		end

		local ten_cost = gacha.ten_cost
		self:setObjectVisible("ten_red_point_img", false)
		for i,v in ipairs(ten_cost or {}) do
			local itemData = RewardUtil:getProcessRewardData(v)
			if itemData.user_num >= itemData.data_num then
				self:setImg(itemData.icon_name, itemData.atlas_name, "ten_btn_item_img")
				self:setText("ten_btn_num", itemData.data_num)
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					self:setObjectVisible("ten_red_point_img", true)
				end
				break
			else
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					local min_count = gacha.limit or 10
					if itemData.user_num >= min_count and itemData.user_num > 0 then
						self:setImg(itemData.icon_name, itemData.atlas_name, "ten_btn_item_img")
						self:setText("ten_btn_num", "<color=#F33535>" .. itemData.data_num .. "</color>")
						break
					end
				end

				if i == #ten_cost then
					self:setImg(itemData.icon_name, itemData.atlas_name, "ten_btn_item_img")
					self:setText("ten_btn_num", "<color=#F33535>" .. itemData.data_num .. "</color>")
				end
			end
		end
	end

	--快速导航
	self:setObjectVisible("guide_btn", true)

	-- SP侠客变更背景图
	local back_image = self:findImage("back_img")
	if self.m_model.m_is_sp then
		GameUtil:updateResourcesImg( back_image, "Texture/a_qyq_sp_bg")
		self:setObjectVisible("yuanlun", true)
		self:setTextByLanKey("close_title_text", "new_str_0400")
		--self:setTextByLanKey("close_title_text", "predestined_str_017")
		self:setTextByLanKey("one_btn_text", "predestined_str_018")
		self:setTextByLanKey("ten_btn_text", "predestined_str_019")
	else
		GameUtil:updateResourcesImg( back_image, "Texture/a_qyq_sp_bg")
		--GameUtil:updateResourcesImg( back_image, "Texture/a_qyq_bg")
		self:setObjectVisible("yuanlun", false)
		self:setTextByLanKey("close_title_text", "new_str_0400")
		--self:setTextByLanKey("close_title_text", "predestined_str_001")
		self:setTextByLanKey("one_btn_text", "predestined_str_012")
		self:setTextByLanKey("ten_btn_text", "predestined_str_013")
	end
end

function M:refreshItem()
	if self.m_model.m_is_sp then
		for i=1,6  do
			self:setObjectVisible("item_paopao_" .. i, false)
		end
		return
	end
	local items = self.m_model:getShowItem()
	if next(items) ~= nil then
		for i=1,6  do
			if i > #items then
				self:setObjectVisible("item_paopao_" .. i, false)
			else
				local item = items[i].reward
				if item then
					self:setObjectVisible("item_paopao_" .. i, true)
					local obj = self:findGameObject("ItemNode_" .. i)
					local data = RewardUtil:getProcessRewardData(item)
					GameUtil:updateItemElementByData(obj, data, true, true)
					local luaBehaviour = UIUtil.findLuaBehaviour(obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text_bg_img",data.data_num > 1)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text",data.data_num > 1)
					self:setImg(paopao_tab[i], "Coach_ui", "paopao_img_" .. i)
					local paopao_img = self:findGameObject("paopao_img_" .. i)
					UIUtil.destroyAllChild(paopao_img.transform)
					local effect = ResourceUtil:GetUIEffectItem("Predestined/" .. paopao_effect_tab[i], paopao_img)
				else
					self:setObjectVisible("item_paopao_" .. i, false)
				end
			end
		end
	end
end

function M:refreshHeroSpine()
	if self.m_model.m_data.aim_hero and self.m_model.m_data.aim_hero > 0 then
		self:setObjectVisible("hero_sp",true)
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_data.aim_hero)
		local hero_skin_cfg = UserDataManager.hero_data:getHeroDefaultSkinCfgByHeroCfg(cfg)
		local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
		local hero_sp = self:findGameObject("hero_sp")
		GameUtil:updateSpineLoadSet(hero_sp, "RoleSpine/"..spine, "idle", 0, true)
		self:setTextByLanKey("times_name_text", cfg.name)
		--local evoData = GlobalConfig.QUALITY_FRAME[cfg.evo]
		self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.evo), "common_ui", "quality_image")
		self:setTextByLanKey("top_race_name_text", cfg.name)
		self:setTextByLanKey("top_hero_name_text", cfg.class)
		self:setObjectVisible("top_daxia_img", cfg.evo > 4)
		self:setObjectVisible("top_sp_img", false)
		--self:setObjectVisible("top_sp_img", cfg.is_sp == 1)
		local race_data = GlobalConfig.TYPE_HERO_RACE[cfg.race]
		if race_data then
			self:setImg(race_data.race_icon, ResourceUtil:getLanAtlas(),"top_race_img")
		end
		local head_node = self:findGameObject("HeadNode")
		GameUtil:setHeroAvatar(head_node, {avatar = cfg.id}, false, false)
	else
		self:setObjectVisible("hero_sp",false)
	end
end

function M:updateTime()
	if self.m_is_update == false then
		return
	end
	local next_fresh_time = TimeUtil.getIntTimestamp(UserDataManager.m_gacha_predestined_end)
	local end_ts = next_fresh_time + 24 * 3600
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time, 1)
		self.toggle4_time_text.text = text
		self.time_text.text = Language:getTextByKey("predestined_str_024", text)
	else
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self.toggle4_time_text.text = ""
		self.time_text.text = ""
		--self:setObjectVisible("toggle4", false)
		--self:updateMsg("time_end")
		self.m_is_update = false
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	UserDataManager:removeRedDotByKey("gacha7_once")
	M.super.destroy(self)
end

return M