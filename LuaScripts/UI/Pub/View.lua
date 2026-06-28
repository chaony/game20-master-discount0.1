local M = class("PubPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/Pub"
M.m_size_type = 1
M.m_iphoneXAdapter = true

--local race_img_tab = {[3] = "a_ck_kachi_longting", [4] = "a_ck_kachi_caomang", [5] = "a_ck_kachi_shizu", [6] = "a_ck_kachi_linshi"}
--local race_img_tab = {[3] = "pub_tex/a_jykz_yeqian_renwu02", [4] = "pub_tex/a_jykz_yeqian_renwu06", [5] = "pub_tex/a_jykz_yeqian_renwu04", [6] = "pub_tex/a_jykz_yeqian_renwu05"}
local __get_tips_tab = {"Pub_str_0009","Pub_str_0010","Pub_str_0011"}
local __left_get_tips_tab = {"left_youqing","left_yuanbao","left_shili"}
local __right_get_tips_tab = {"right_youqing","right_yuanbao","right_shili"}
local __gacha_list_cell_bgs = {"a_jykz_yeqian_shili", "a_jykz_yeqian_gaoji", "a_jykz_yeqian_youqing", "a_jykz_yeqian_weikaiqi01", "a_jykz_yeqian_weikaiqi"}
local __gacha_bgs = {"pub_tex/a_jykz_quan","pub_tex/a_jykz_quan_2","pub_tex/a_jykz_quan_1"}

function M:onEnter()
	--是否可以领取英雄
	self.canLingHero = false;
	self.vedio = self:findGameObject("vedio")
	self.hui = self:findImage("hui")
	local video_control = self.vedio:GetComponent("VideoControl")
	local full_path,file_type = io.fileFullPath("mp4/xh_05.mp4")
	if full_path then
		video_control:VideoPlay(file_type,"mp4/xh_05.mp4",true,0);
	end
	local race_hero_cell1 = self:findGameObject("race_hero_cell1")
	local race_hero_cell2 = self:findGameObject("race_hero_cell2")
	local race_hero_cell3 = self:findGameObject("race_hero_cell3")
	self.cellView = {
		[1] = {
			name = "race_hero_cell1",
			obj = race_hero_cell1,
		},
		[2] = {
			name = "race_hero_cell2",
			obj = race_hero_cell2,
		},
		[3] = {
			name = "race_hero_cell3",
			obj = race_hero_cell3,
		},
	}
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 5})
	UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
	-- self.m_attr_node:setTitle(Language:getTextByKey(v.text_key))
	self.detatils_image = self:findImage("detatils_image")
	-- self.list_rect = self:findGameObject("list_rect")
	self.picker_btn = self:findGameObject("picker_btn")
	self.gift_show_panel = self:findGameObject("gift_show_panel")
	self.gift_num_tips_panel = self:findGameObject("gift_num_tips_panel")
	self.close_gift_btn = self:findGameObject("close_gift_btn")
	self.card_btn = self:findGameObject("card_btn")
	self.gacha_slider = self:findSlider("gacha_slider")
	self.one_gacha_btn = self:findGameObject("one_gacha_btn")
	self.ten_gacha_btn = self:findGameObject("ten_gacha_btn")
	self.time_image = self:findGameObject("time_image")
	self.gacha_times_text = self:findGameObject("gacha_times_text")
	self:setText("close_title_text", Language:getTextByKey("new_str_0400"))
	self:setTextByLanKey("one_gacha_btn_text", "Pub_str_0026")
	self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
	self.one_gacha_btn_effect = self:findGameObject("one_gacha_btn_effect")
	self.ten_gacha_btn_effect = self:findGameObject("ten_gacha_btn_effect")
	self:setObjectVisible("wish_btn", true)
	self:setTextByLanKey("shop_btn_text", "union_str_0054")
	self:setTextByLanKey("skip_anim_select_text", "new_str_0936")

	self.mast_hero_cell1 = self:findGameObject("mast_hero_cell1")
	--祝福侠客
	self:initHeroCell("mast_hero_cell1")

	--心愿单侠客
	self:initHeroCell("race_hero_cell1")
	self:initHeroCell("race_hero_cell2")
	self:initHeroCell("race_hero_cell3")

	self.m_gacha_1 = self:findGameObject("gacha_1")
	self.m_gacha_2 = self:findGameObject("gacha_2")
	self.m_gacha_3 = self:findGameObject("gacha_3")
	self.m_gacha_4 = self:findGameObject("gacha_4")
	self.m_gacha_fade_dotween_1 = self.m_gacha_1:GetComponent(typeof(U3DUtil:Get_DOTweenAnimation()))
	self.m_gacha_fade_dotween_2 = self.m_gacha_2:GetComponent(typeof(U3DUtil:Get_DOTweenAnimation()))
	self.m_gacha_fade_dotween_3 = self.m_gacha_3:GetComponent(typeof(U3DUtil:Get_DOTweenAnimation()))
	self.m_gacha_fade_dotween_4 = self.m_gacha_4:GetComponent(typeof(U3DUtil:Get_DOTweenAnimation()))

	self.m_gift = {}
	self.gift_btn = self:findGameObject("gift_btn")
	--for i=1,5 do
	--	local btn = self:findGameObject(string.format("gift_%d_btn", i))
	--	self.m_gift[i] = btn
	--	UIUtil.setButtonClick(btn.transform, function (trans, data)
	--		self:updateMsg("gift_btn", data)
	--	end, i)
	--end
	local name_tab = {"Pub_str_0017","Pub_str_0018","Pub_str_0019"}
	for i,v in ipairs(name_tab) do
		self:setTextByLanKey("gacha_title_" .. i, v)
	end
	self:setTextByLanKey("time_text", "Pub_str_0004")

	local figer_sp = self:findGameObject("figer_sp")
	local map_id = UserDataManager:getCurStage()
	if map_id > 6 and next(self.m_model.m_data.hero_wish_list) == nil then
		figer_sp:SetActive(true)
	else
		figer_sp:SetActive(false)
	end
	if BtnOpenUtil:isBtnOpen(57) then
		self:setObjectVisible("wish_btn", true)
	else
		self:setObjectVisible("wish_btn", false)
	end
	--进度
	self.sliderbg = self:findImage("sliderbg")
	self.zhufu_text = self:findText("zhufu_text")
	self:setObjectVisible("next_bi_text", false)
	self:setObjectVisible("get_mast_hero_btn", false)
	self:setTextByLanKey("next_bi_text", "new_str_0655")
	self:setTextByLanKey("get_mast_hero_btn_text", "new_str_0056")
	--self:setParticleRenderOrder(self.content_node)
	--local canvas = self.content_node:GetComponent("Canvas")
	--canvas.sortingOrder = self.m_sortOrder + 2
	-- self:initSpine()

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
	self.toggle4_time_text = self:findText("toggle4_time_text")
	--if UserDataManager.m_gacha_predestined_end > 0 then
	local open_flag, tips_str = BtnOpenUtil:isBtnOpen(36) --前缘招募开启
	if UserDataManager.m_gacha_predestined_end > 0 and open_flag == true then
		self:setObjectVisible("toggle4", true)
	else
		self:setObjectVisible("toggle4", false)
	end

	self.m_is_update = true

	self:initDownTime()
	self:createList()
	self:changeGacha(0)
	self:freshGiftTipsText()
	self:closeGift()
	self:refreshUI()
end


function M:updateZhuFuValue( value )
	self:setTextByLanKey("bless_times_text", "budo_str_005", self.m_model.m_bless_data.max_bless_times - self.m_model.m_bless_data.cur_bless_times)
	self.targetSliderValue = value
	self.sliderbg.fillAmount = self.targetSliderValue / self.m_model.maxValue
	self.zhufu_text.text = Language:getTextByKey("new_str_0924",self.targetSliderValue, self.m_model.maxValue)
	if self.targetSliderValue >= self.m_model.maxValue and self.m_model.m_bless_data.cur_bless_times < self.m_model.m_bless_data.max_bless_times then
		--local isBless = self.m_model:hasBless(self.m_model.m_bless_data.bless_hero)
		--self:setObjectVisible("next_bi_text", isBless == false)
		self:setObjectVisible("next_bi_text", false)
		self:setObjectVisible("get_mast_hero_btn", true)
	else
		self:setObjectVisible("next_bi_text", false)
		self:setObjectVisible("get_mast_hero_btn", false)
	end
end


function M:initHeroCell( cell_name )
	local cell_object = self:findGameObject(cell_name)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	local stars = luaBehaviour:FindGameObject("stars")
	local have_panel = luaBehaviour:FindGameObject("have_panel")
	local no_panel = luaBehaviour:FindGameObject("no_panel")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
	have_panel:SetActive(false)
	stars:SetActive(false)
	no_panel:SetActive(true)
end


function M:initSpine()
	local spine = {"hero_0038_SkeletonData", "hero_0029_SkeletonData", "hero_0052_SkeletonData"}
	for i,v in ipairs(spine) do
		local hero_spine = self:findGameObject("gacha_spine_" .. i)
		local sg = hero_spine:GetComponent("SkeletonGraphic")
		local sk = ResourceUtil:GetSk(v, "rolespine_"..string.lower(v))
		sg.skeletonDataAsset = sk
		sg:Initialize(true)
		sg.AnimationState:SetAnimation(0, "pose", true)
	end
end

function M:createList()
	self.m_list_cell = {}
	-- self.m_list_scroll = CarouselUtil.new()
	-- self.m_list_scroll:create(self.m_control,self:findGameObject("list_rect"))
	-- self.m_list_scroll:setDrag(false)
	-- self:InitListCell()
	-- self.m_list_scroll:addDragHandler(handler(self,self.listScrollHandler))
	-- self.m_list_scroll:addOnIndexChange(handler(self,self.onIndexChange))
	-- self.m_list_scroll:moveToIndex(self.m_model.m_index)
end

function M:refreshUI()
	if self.m_model.m_index == 4 then
		--self:setObjectVisible("bottom", false)
		--self:setObjectVisible("gacha4", true)
		return
	end
	--self:setObjectVisible("bottom", true)
	--self:setObjectVisible("gacha4", false)
	self:updateSkipAnimStatus() -- 刷新跳过动画是否展示
	self:setObjectVisible("gift_panel", false)
	-- self:setImg(__get_tips_tab[self.m_model.m_index], "pub_ui", "get_tips_img")
	--self:setTextByLanKey("get_tips_title_text", __get_tips_tab[self.m_model.m_index])
	--local today_times = self.m_model.m_data.today_times_dict[tostring(self.m_model.m_index)] or 0
	-- Logger.log(today_times,"today_times ====")
	if self.m_model.m_index == 3 then
		self:setObjectVisible("race_img_bg", false)
		local race_data = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_race - 2]
		self:setImg(race_data.race_icon,  ResourceUtil:getLanAtlas(), "gacha_race_img")
		--local martial_tab = ConfigManager:getCommonValueById(34)
		for i=1,4 do
			local race = i + 2
			--local race = martial_tab[i]
			local race_btn = self:findGameObject("race_btn_" .. i)
			local luaBehaviour = race_btn:GetComponent("LuaBehaviour")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_ShareLv_Xuanze_01", self.m_model.m_race == race)
		end
	else
		self:setObjectVisible("race_img_bg", false)
	end
	--local gacha_spine_3 = self:findImage("gacha_spine_3")
	--GameUtil:updateResourcesImg(gacha_spine_3, "Texture/" .. race_img_tab[self.m_model.m_race])
	--gacha_spine_3:SetNativeSize()
	--local pub_circular_img = self:findGameObject("pub_circular_img")
	--GameUtil:updateResourcesImg(pub_circular_img, "Texture/" .. __gacha_bgs[self.m_model.m_index])
	
	--self.picker_btn:SetActive(self.m_model.m_index == 3)
	self.picker_btn:SetActive(false)
	--local guarantee_chest = ConfigManager:getCfgByName("guarantee_chest")
	--local cur_chest_rank = self.m_model.m_data.cur_chest_rank[tostring(self.m_model.m_index)]
	--local cur_chest_id = self.m_model.m_data.cur_chest_id[tostring(self.m_model.m_index)]
	--local slider_value = 0
	--if guarantee_chest[self.m_model.m_index] then
	--	if self.m_model:canReceiveRewards() then
	--		self:setObjectVisible("UI_Main_ShanGuang_001", true)
	--		self:setObjectVisible("gift_btn_red_point_img", true)
	--		local chest_reward = self.m_model.m_data.chest_rewards[tostring(self.m_model.m_index)][1]
	--		cur_chest_rank = chest_reward[1]
	--		cur_chest_id = chest_reward[2]
	--		local cur_chest_rank_cfg = guarantee_chest[self.m_model.m_index][cur_chest_rank]
	--		local cfg = cur_chest_rank_cfg.config[cur_chest_id]
	--		self.max_condition = cfg.condition
	--		self.cur_chest_times = cfg.condition
	--	else
	--		self:setObjectVisible("UI_Main_ShanGuang_001", false)
	--		self:setObjectVisible("gift_btn_red_point_img", false)
	--		local cur_chest_rank_cfg = guarantee_chest[self.m_model.m_index][cur_chest_rank]
	--		local cfg = cur_chest_rank_cfg.config[cur_chest_id]
	--		self.max_condition = cfg.condition
	--		self.cur_chest_times = self.m_model.m_data.cur_chest_times[tostring(self.m_model.m_index)] or 0
	--	end
	--	
	--	slider_value = self.cur_chest_times/self.max_condition
	--end
	
	--self:setText("gacha_num", self.m_model.m_last_chest_times)
	
	--self.card_btn:SetActive(false)
	--UIUtil.setText(self.card_btn.transform, item_data.num, "Text")
	
	--self.gacha_slider.value = self.m_model.m_last_chest_times/self.max_condition
	--self.gacha_slider.value = slider_value
	--self:setText("gacha_slider_value", string.format("%d/%d",self.cur_chest_times or 0,self.max_condition or 0))

	--local item_data = UserDataManager.item_data:getItemDataById(ConfigManager:getCommonValueById(44)[1])
	self.card_btn:SetActive(false)
	local one_red_point_img = self:findGameObject("one_red_point_img")
	local ten_red_point_img = self:findGameObject("ten_red_point_img")
	one_red_point_img:SetActive(false)
	ten_red_point_img:SetActive(false)
	local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_pool_id]
	local subscribe = UserDataManager:hasGachaSubscribe()
	if subscribe then
		self:setTextByLanKey("privilege_btn_text", "new_str_0822")
		self:findImage("privilege_btn").material = nil
	else
		self:setTextByLanKey("privilege_btn_text", "bounty_str_0018")
	end
	self:setObjectVisible("one_subscribe_img", false)
	self:setObjectVisible("ten_subscribe_img", false)
	self:setObjectVisible("privilege_btn", self.m_model.m_index == 2)
	self.one_gacha_times = 0
	local cost = subscribe and gacha.special_cost or gacha.cost
	for i,v in ipairs(cost or {}) do
		local itemData = RewardUtil:getProcessRewardData(v)
		if itemData.user_num >= itemData.data_num then
			UIUtil.setImg(self.one_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
			UIUtil.setText(self.one_gacha_btn.transform, itemData.data_num, "Image/Text")
			if itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				self:setObjectVisible("one_subscribe_img", subscribe and self.m_model.m_index == 2)
			end
			self.one_gacha_btn_effect:SetActive(true)
			self.one_gacha_times = 1
			break
		else
			if i == #cost then
				UIUtil.setImg(self.one_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
				UIUtil.setText(self.one_gacha_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "Image/Text")
				self.one_gacha_btn_effect:SetActive(false)
				self:setObjectVisible("one_subscribe_img", subscribe and self.m_model.m_index == 2)
			end
		end
	end
	
	self.gacha_times = 0
	local ten_cost = subscribe and gacha.special_ten_cost or gacha.ten_cost
	for i,v in ipairs(ten_cost or {}) do
		local itemData = RewardUtil:getProcessRewardData(v)
		if itemData.user_num >= itemData.data_num then
			UIUtil.setImg(self.ten_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
			UIUtil.setText(self.ten_gacha_btn.transform, itemData.data_num, "Image/Text")
			if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				ten_red_point_img:SetActive(true)
			else
				self:setObjectVisible("ten_subscribe_img", subscribe and self.m_model.m_index == 2)
			end
			self.ten_gacha_btn_effect:SetActive(true)
			self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
			self.gacha_times = 10
			break
		else
			if self.m_model.m_index == 1 then
				local min_count = gacha.limit or 10
				local once_cost = gacha.cost_item[1][3]
				if itemData.user_num >= min_count*once_cost and itemData.user_num > 0 then
					local times = math.floor(itemData.user_num/once_cost)
					UIUtil.setImg(self.ten_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.ten_gacha_btn.transform, math.floor(times*once_cost), "Image/Text")
					self.ten_gacha_btn_effect:SetActive(true)
					ten_red_point_img:SetActive(true)
					self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", times)
					self.gacha_times = times
					break
				end
			elseif self.m_model.m_index == 2 and itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				local min_count = gacha.limit or 10
				if itemData.user_num >= min_count and itemData.user_num > 0 then
					UIUtil.setImg(self.ten_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.ten_gacha_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "Image/Text")
					self.ten_gacha_btn_effect:SetActive(true)
					--ten_red_point_img:SetActive(true)
					self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
					self.gacha_times = itemData.user_num
					--self:setObjectVisible("ten_subscribe_img", subscribe and self.m_model.m_index == 2)
					break
				end
			elseif self.m_model.m_index == 3 then
				local min_count = gacha.limit or 10
				if itemData.user_num >= min_count and itemData.user_num > 0 then
					UIUtil.setImg(self.ten_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.ten_gacha_btn.transform, "<color=#F33535>".. itemData.data_num .. "</color>", "Image/Text")
					self.ten_gacha_btn_effect:SetActive(true)
					ten_red_point_img:SetActive(true)
					self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", itemData.user_num)
					self.gacha_times = itemData.user_num
					break
				end
			end
			if i == #ten_cost then
				UIUtil.setImg(self.ten_gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
				UIUtil.setText(self.ten_gacha_btn.transform, "<color=#F33535>".. itemData.data_num .. "</color>", "Image/Text")
				self.ten_gacha_btn_effect:SetActive(false)
				self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
				self:setObjectVisible("ten_subscribe_img", subscribe and self.m_model.m_index == 2)
			end
		end
	end
	--self.time_image:SetActive(self.m_model.m_index == 3)
	self.time_image:SetActive(false)

	--超过今日最大抽卡次数，红点不显示
	local today_times = self.m_model.m_data.today_times_dict[tostring(self.m_model.m_index)] or 0
	local max_times = self.m_model:getGachaLimitNums() or 0
	if today_times >= max_times then
		ten_red_point_img:SetActive(false)
	end
	--for i=1, 3 do
	--	self:setImg( i == self.m_model.m_index and "a_ui_currency_fanye_1" or "a_ui_currency_fanye_2", "common_ui", "pool_img_" .. i)
	--end

	--[[
	self:clearLeft()
	local left_index = self.m_model.m_index - 1 < 1 and 3 or self.m_model.m_index - 1
	--self:setTextByLanKey("left_btn_text", __get_tips_tab[left_index])
	self:setObjectVisible(__left_get_tips_tab[left_index], true)
	--local left_gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_list_data[left_index] or 1]
	--self:setImg(left_gacha.entrance, "hero_head_ui", "left_btn_img")
	local left_red = self.m_model:redPointCheck(left_index)
	self:setObjectVisible("left_red_point_img", left_red)

	self:clearRight()
	local right_index = self.m_model.m_index + 1 > 3 and 1 or self.m_model.m_index + 1
	--self:setTextByLanKey("right_btn_text", __get_tips_tab[right_index])
	self:setObjectVisible(__right_get_tips_tab[right_index], true)
	--local right_gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_list_data[right_index] or 1]
	--self:setImg(right_gacha.entrance, "hero_head_ui", "right_btn_img")
	local right_red = self.m_model:redPointCheck(right_index)
	self:setObjectVisible("right_red_point_img", right_red)
	]]--
	
	--self:updateGachaLoopScroll()
	self:refreshRedPoint()

	--更新
	self:refreshZhuFu()
	self:refreshXinYuan()
	self:updateZhuFuValue(self.m_model.m_bless_data.bless_value)
	self:UpdateXinYuanDanByIndex()
	self:refreshLimitTimes()
	self:refreshScore()
	
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshScore()
	self:setTextByLanKey("score_text", Language:getTextByKey("Pub_str_0047") .. self.m_model.m_score .. "/" .. self.m_model.m_score_consume)
	self:setTextByLanKey("score_title_text", "Pub_str_0053")
end

function M:refreshLimitTimes()
	self:setObjectVisible("gacha_times_text", self.m_model.m_index ~= 1)
	self:setObjectVisible("gacha_times_img", self.m_model.m_index ~= 1)
	local today_times = self.m_model.m_data.today_times_dict[tostring(self.m_model.m_index)] or 0
	local max_times = self.m_model:getGachaLimitNums() or 0
	today_times = math.min(today_times, max_times)
	self:setText("gacha_times_text", Language:getTextByKey("Pub_str_0005") .. today_times .. "/" .. max_times)
end
function M:clearLeft()
	self:setObjectVisible("left_shili", false)
	self:setObjectVisible("left_yuanbao", false)
	self:setObjectVisible("left_youqing", false)
end

function M:clearRight()
	self:setObjectVisible("right_shili", false)
	self:setObjectVisible("right_yuanbao", false)
	self:setObjectVisible("right_youqing", false)
end


function M:UpdateXinYuanDanByIndex()
	if self.m_model.m_bless_data.normal_times > 10 then
		self:setObjectVisible("gacha_title_bg_2_new", false)
		self:setObjectVisible("gacha_title_bg_2", true)
	else
		self:setObjectVisible("gacha_title_bg_2_new", true)
		self:setObjectVisible("gacha_title_bg_2", false)
	end
	local yinyang_success_index, success_index = self.m_model:getBlessTimes()
	local stage = UserDataManager:getCurStage()
	local stage_com = ConfigManager:getCommonValueById(430)
	local zhufu_time = 0
	local yinyang_zhufu_times = self.m_model:getYinYangTimes()
	for i, v in pairs(stage_com) do
		if stage > v then
			zhufu_time = zhufu_time + 1
		end
	end
	self:setObjectVisible("must_hero_cell", self.m_model.m_index == 3)
	self:setObjectVisible("score_panel",self.m_model.m_index == 2 and self.m_model.m_score_consume > 0)
	--已经使用了最大次数
	local unlock_normal_time = ConfigManager:getCommonValueById(427)
	if self.m_model.m_bless_data.normal_times < unlock_normal_time then
		--未解锁
		self:setObjectVisible("race_hero_cell", false)
		--self:setObjectVisible("must_hero_cell",false)
		--self:setObjectVisible("score_panel",false)
		self:setObjectVisible("open_race_hero_text", self.m_model.m_index == 2 or self.m_model.m_index == 3)
		self:setTextByLanKey("open_race_hero_text", "Pub_str_0045", unlock_normal_time - self.m_model.m_bless_data.normal_times)
		--local luaBehaviour = UIUtil.findLuaBehaviour(self.mast_hero_cell1.transform)
		--local item_img = luaBehaviour:FindImage("item_img")
		--item_img.material = self.hui.material
		self.canLingHero = false
	else
		--已解锁
		self:setObjectVisible("race_hero_cell", self.m_model.m_index == 2 or self.m_model.m_index == 3)
		--self:setObjectVisible("must_hero_cell", self.m_model.m_index == 3)
		--self:setObjectVisible("score_panel",self.m_model.m_index == 2)
		self:setObjectVisible("open_race_hero_text", false)
		--是否可以领取
		if self.m_model.m_bless_data.bless_value >= self.m_model.maxValue then
			self.canLingHero = true
			if (self.m_model.m_is_yinyang and yinyang_success_index == yinyang_zhufu_times)
					or (success_index == zhufu_time and not(self.m_model.m_is_yinyang )) then
				self.canLingHero = false
			end
		end

		if self.m_model.m_index == 3 then
			if self.m_model.m_bless_data.bless_value >= self.m_model.maxValue then
				local isBless = self.m_model:hasBless(self.m_model.m_bless_data.bless_hero)
				self:setObjectVisible("next_bi_text", isBless == false)
				self:setObjectVisible("get_mast_hero_btn", true)
				self:setObjectVisible("get_mast_hero_btn_spine",true)
				--达到最大次数
				if (self.m_model.m_is_yinyang and yinyang_success_index == yinyang_zhufu_times) 
						or (success_index == zhufu_time and not(self.m_model.m_is_yinyang )) then
					self:setObjectVisible("next_bi_text", false)
					local btn_img = self:findImage("get_mast_hero_btn")
					self:setObjectVisible("get_mast_hero_btn_spine",false)
					btn_img.material = self.hui.material
					--item置灰
					local luaBehaviour = UIUtil.findLuaBehaviour(self.mast_hero_cell1.transform)
					local item_img = luaBehaviour:FindImage("item_img")
					item_img.material = nil
				end
			else
				self:setObjectVisible("next_bi_text", false)
				self:setObjectVisible("get_mast_hero_btn", false)
				self:setObjectVisible("get_mast_hero_btn_spine", false)
				local luaBehaviour = UIUtil.findLuaBehaviour(self.mast_hero_cell1.transform)
				local item_img = luaBehaviour:FindImage("item_img")
				item_img.material = self.hui.material
			end
		elseif self.m_model.m_index == 2 then

		else
			self:setObjectVisible("next_bi_text", false)
			self:setObjectVisible("get_mast_hero_btn", false)
		end
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(self.mast_hero_cell1.transform)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
end

--刷新祝福英雄
function M:refreshZhuFu()
	--祝福英雄
	local hero_id = self.m_model.m_bless_data.bless_hero
	if hero_id > 0 then
		local itemData = self.m_model:getHeroData(hero_id)
		--设置头像到槽位上
		GameUtil:updateItemElementByData(self.mast_hero_cell1, itemData)
		self:setObjectVisible("figer_sp", false)
	else
		local unlock_normal_time = ConfigManager:getCommonValueById(427)
		if self.m_model.m_bless_data.normal_times >= unlock_normal_time then
			self:setObjectVisible("figer_sp", true)
		end
	end
end

--刷新心愿英雄
function M:refreshXinYuan()
	--槽位上的英雄
	local solt_players = self.m_model:getSendSlot()
	for i, v in pairs(solt_players) do
		--槽位数据
		if v.hero_id > 0 then
			local playerid = v.hero_id
			local cell_veiw = self.cellView[i].obj
			--找到槽位
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_veiw.transform)
			local have_panel = luaBehaviour:FindGameObject("have_panel")
			have_panel:SetActive(true)
			--获取道具人物头像数据
			local itemData = self.m_model:getHeroData(playerid)
			--设置头像到槽位上
			GameUtil:updateItemElementByData(cell_veiw, itemData)
			--如果已经完成
			if v.finish == 1 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish", "yishixian_tex")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
			end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lv_bg_img", false)
		else
			local cell_name = self.cellView[i].name
			self:initHeroCell(cell_name)
		end
	end
end

function M:InitListCell()
	self.m_list_cell = {}
	local data = self.m_control.m_model.m_list_data
	local img_tab = {"ck_linshitu_B1", "ck_linshitu_B2", "ck_linshitu_B3"}
	local name_tab = {"Pub_str_0017","Pub_str_0018","Pub_str_0019"}
	for i=1, #data do
		local item = ResourceUtil:LoadUIGameObject("Pub/PubListCell", Vector3.zero,nil)
		self.m_list_scroll:AddChild(item.transform)
		local luaBehaviour = item:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setImg(luaBehaviour, "bg_img", img_tab[i], "pub_ui")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", name_tab[i])
		local function clickCallback(obj,index)
			-- Logger.log(index,"index ===")
			-- local curIndex = self.m_list_scroll:currentIndex()
			-- Logger.log(curIndex,"curIndex ===")
			self.m_list_scroll:moveToIndex(index)
		end
		UIUtil.setButtonClick(item,clickCallback,i)
		self.m_list_cell[i] = item
	end
	self:onIndexChange(self.m_model.m_index - 1)
end

function M:listScrollHandler(a1, a2, a3)
	if a1 == 1 then
	    self.begin_pos = Vector2.New(a2, a3)
	elseif a1 == 2 then

		
	elseif a1 == 3 then
		local curIndex = self.m_list_scroll:currentIndex()
		local end_pos = Vector2.New(a2, a3)
		if self.begin_pos.x < end_pos.x then
			self.m_list_scroll:moveToIndex(curIndex - 1)
		else
			self.m_list_scroll:moveToIndex(curIndex + 1)
		end
	end
end

function M:onIndexChange(index)
	self:updateMsg("index_change",index + 1)
	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_list_cell[self.m_model.m_index])
	luaBehaviour:FindGameObject("slete_image"):SetActive(false)
	luaBehaviour = UIUtil.findLuaBehaviour(self.m_list_cell[index + 1])
	luaBehaviour:FindGameObject("slete_image"):SetActive(true)
end

function M:showGift(gift_id)
	self.close_gift_btn:SetActive(true)
	self.gift_show_panel:SetActive(true)
	UIUtil.destroyAllChild(self.gift_show_panel.transform)
	local rectTrans = UIUtil.findRectTransform(self.gift_show_panel.transform)
	local gift_rectTrans = UIUtil.findRectTransform(self.gift_btn.transform)
	local pos = UIUtil.worldToScreenPoint(gift_rectTrans.position) + Vector3.New(0,40,0)
	rectTrans.position = UIUtil.screenToWorldPoint(pos)
	local guarantee_chest = ConfigManager:getCfgByName("guarantee_chest")
	local cur_chest_rank = self.m_model.m_data.cur_chest_rank[tostring(self.m_model.m_index)]
	local cur_chest_id = self.m_model.m_data.cur_chest_id[tostring(self.m_model.m_index)]
	local cfg = guarantee_chest[self.m_model.m_index][cur_chest_rank].config[cur_chest_id]
	GameUtil:createRewards(self.gift_show_panel.transform, cfg.reward, true, true)
end

function M:showGiftTips()
	self.gift_num_tips_panel:SetActive(true)
	self.close_gift_btn:SetActive(true)
	self:freshGiftTipsText()
end

function M:freshGiftTipsText()
	--local guarantee_chest = ConfigManager:getCfgByName("guarantee_chest")
	--local chest_rank = self.m_model.m_data.cur_chest_rank[tostring(self.m_model.m_index)]
	----local chest_id = self.m_model.m_data.cur_chest_id[tostring(self.m_model.m_index)]
	--local cfg = guarantee_chest[self.m_model.m_index][chest_rank]
	--local total_times = self.m_model.m_data.total_chest_times[self.m_index] or 0
	--local text = string.format(Language:getTextByKey("Pub_str_0003"), cfg.rank_condition,total_times,cfg.rank_condition)
	--UIUtil.setText(self.gift_num_tips_panel.transform, text, "gift_num_tips_text")
	if self.m_model.m_index == 2 then
		self:setTextByLanKey("gift_num_tips_text", "itd#gacha_box1")
	elseif self.m_model.m_index == 3 then
		self:setTextByLanKey("gift_num_tips_text", "itd#gacha_box2")
	end
	local gift_num_tips_text = self:findGameObject("gift_num_tips_text")
	gift_num_tips_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
end

function M:closeGift()
	self.gift_show_panel:SetActive(false)
	self.gift_num_tips_panel:SetActive(false)
	self.close_gift_btn:SetActive(false)
end

function M:initDownTime()
	local function tick(dt)
		--if self.m_model.m_index == 3 then
			local data = self.m_model.m_data.today_end_ts
			local down_time = data - UserDataManager:getServerTime()
			if down_time >= 0 then
				local text = GameUtil:formatTimeBySecond(down_time)
				if not IsNull(self.m_limit_time_text) then
					self.m_limit_time_text.text = text
				end
				--self:setText("time_value_text", text)
			else
				self:updateMsg("time_end", nil, "Pub")
			end
		--end
	end
	self.m_control:setTimer(1,tick)
end

function M:refreshRedPoint()
	--local gacha_sort_red_map = {[1] = 7001, [2] = 7003, [3] = 7002}
	--local gacha = ConfigManager:getCfgByName("gacha")
	--for k,v in pairs(self.m_model.m_list_data) do
	--	local cell = self.m_list_cell[k]
	--	if cell then
	--		local luaBehaviour = UIUtil.findLuaBehaviour(cell)
	--		local red_point_img = luaBehaviour:FindGameObject("red_point_img")--红点
	--		local gacha_item = gacha[v] or {}
	--		local gacha_sort = gacha_item.gacha_sort or -1 -- 1 友情点 2钻石抽 3 种族抽
	--		local red_id = gacha_sort_red_map[gacha_sort]
	--		local red_flag = RedPointUtil:hasRedPointById(red_id)
	--		red_point_img:SetActive(red_flag == true)
	--	end
	--end
	--
	--for k, v in pairs({ { "gacha1_red_point", 7001 }, { "gacha2_red_point", 7003 }, { "gacha3_red_point", 7002 } }) do
	--	local red_flag = RedPointUtil:hasRedPointById(v[2])
	--	self:setObjectVisible(v[1], red_flag == true)
	--end	
	local red_flag = RedPointUtil:isFuncRedPointById(57)
	local bless_look_times = UserDataManager:getBlessNeedChange()
	self:setObjectVisible("wish_btn_red_point_img", red_flag == true and bless_look_times == 0)
end

function M:sliderAction()
	local guarantee_chest = ConfigManager:getCfgByName("guarantee_chest")
	local next_chest = self.m_model.m_last_chest_times

	local gift = nil
	for i,v in ipairs(self.m_gift) do
		local cfg = guarantee_chest[self.m_model.m_last_chest_rank].config[i]
		if self.m_model.m_last_chest_times >= cfg.condition then
			cfg = guarantee_chest[self.m_model.m_last_chest_rank].config[i+1]
			if cfg then
				if self.m_model.m_last_chest_rank == self.m_model.m_data.cur_chest_rank then
					next_chest = math.min(cfg.condition, self.m_model.m_data.cur_chest_times)
					if cfg.condition <= self.m_model.m_data.cur_chest_times then
						gift = self.m_gift[i+1]
					end
				else
					next_chest = cfg.condition
					gift = self.m_gift[i+1]
				end
			end
		else
			next_chest = self.m_model.m_data.cur_chest_times
		end
	end
	
	self.gacha_slider.value = self.m_model.m_last_chest_times/self.max_condition
	local new_value = next_chest/self.max_condition
	self.m_model.m_last_chest_times = next_chest
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(DOTweenModuleUI.DOValue(self.gacha_slider, new_value, 0.5*new_value))
	sequence:OnComplete(function ()
		self:setText("gacha_num", self.m_model.m_last_chest_times)
		if self.m_model.m_last_chest_rank == self.m_model.m_data.cur_chest_rank then
			if next_chest < self.m_model.m_data.cur_chest_times then
				self:sliderAction()
			else
				-- Logger.log(self.m_model.m_show_reward,"m_show_reward ====")
				if next(self.m_model.m_show_reward) then
					RewardUtil:rewardTipsByData(self.m_model.m_show_reward)
					self.m_model.m_show_reward = {}
					self:refreshUI()
				end
			end
			if gift then
				-- UIUtil.setImg(gift.transform, "a_rw_baoxiang1", "main_ui", "box_open_img")
			end
		else
			if not gift then
				self.m_model.m_last_chest_rank = self.m_model.m_data.cur_chest_rank
				self.m_model.m_last_chest_times = 0
				self:refreshUI()
			end
			
			self:sliderAction()
		end
	end)
	sequence:SetAutoKill(true)
end

function M:changeGacha(time)
	time = time or 0.3
	--self.m_model.m_lock_change = true
	local index = self.m_model.m_index
	for i=1,4 do
		--local target_pos = nil
		--local title_pos = nil
		--if i == index then
		--	target_pos = 1
		--	title_pos = Vector3.New(124,26,0)
		--elseif i == index%3 + 1 then
		--	target_pos = 2
		--	title_pos = Vector3.New(-123,41,0)
		--else
		--	target_pos = 3
		--	title_pos = Vector3.New(119,41,0)
		--end
		--local gacha_title = self:findGameObject("gacha_title_bg_" .. i)
		-- gacha_title.transform.localPosition = title_pos
		--gacha_title.transform:DOLocalMove(title_pos,time)

		local gacha_node = self:findGameObject("gacha_" .. i)
		--local gacha_img = self:findGameObject(string.format("gacha_spine_%d", i))
		--local target_node = self:findGameObject("point_" .. target_pos)
		--local pos = target_node.transform.position

		--local scale = 0.8
		--gacha_img:GetComponent("Image").color = Color(0.6,0.6,0.6,1)
		--if i == index then
		--	gacha_node.transform:SetSiblingIndex(2)
		--	scale = 1
		--	gacha_img:GetComponent("Image").color = Color(1,1,1,1)
		--end
		--local tweener = gacha_img.transform:DOScale(scale,time)
		--local sequence = Tweening.DOTween.Sequence()
		--sequence:Append(gacha_node.transform:DOMove(pos,time))
		--sequence:OnComplete(function ()
		--	if self.m_model.m_lock_change == true then
		--		self.m_model.m_lock_change = false
		--	end
		--	tweener:Kill()
		--end)
		--sequence:SetAutoKill(true)
		local toggle = self:findGameObject("Checkmark" .. i)
		
		if index == self.m_model.m_before_index then
			gacha_node:SetActive(i == index)
		else
			local canvas_group = gacha_node:GetComponent("CanvasGroup")
			local fade_dotween = nil
			local alpha = 0
			local endValueFloat = 1
			local duration = 1
			if i == index then
				fade_dotween = self["m_gacha_fade_dotween_" .. i]
				gacha_node:SetActive(true)
				toggle:SetActive(true)
				self:setToggleInfo(i, true)
			elseif i == self.m_model.m_before_index then
				fade_dotween = self["m_gacha_fade_dotween_" .. i]
				alpha = 1
				endValueFloat = 0
				duration = 0.5
				gacha_node:SetActive(true)
				toggle:SetActive(false)
				self:setToggleInfo(i, false)
			else
				gacha_node:SetActive(false)
				toggle:SetActive(false)
				self:setToggleInfo(i, false)
			end
			if fade_dotween then
				canvas_group.alpha = alpha
				fade_dotween.endValueFloat = endValueFloat
				fade_dotween.duration = duration
				fade_dotween:DOKill()
				fade_dotween:CreateTween()
				fade_dotween:DOPlay()
			end
		end
	end
	self.m_model.m_before_index = index
	--更换背景
	local back_image = self:findImage("back_img")
	if index == 1 then
		GameUtil:updateResourcesImg( back_image, "Texture/a_ck_bg_1")
		self:refreshHeroSpine(109, true, true)
		self:refreshHeroSpine(281, false)
	elseif index == 2 then
		GameUtil:updateResourcesImg( back_image, "Texture/a_ck_bg_3")
		self:refreshHeroSpine(101, true, true)
		self:refreshHeroSpine(409, false)
	elseif index == 3 then
		GameUtil:updateResourcesImg( back_image, "Texture/a_ck_bg_4")
		self:refreshHeroSpine(414, true)
		self:refreshHeroSpine(182, false)
	elseif index == 4 then
		GameUtil:updateResourcesImg( back_image, "Texture/a_qyq_sp_bg")
	end
end

function M:refreshHeroSpine(cid, LorR, flip)
	local prefix = LorR == true and "l_" or "r_"
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = nil}, cfg)
	local spine_name = skin_cfg.hero_spine
	local play_img = self:findGameObject(prefix .. "hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
	if flip and flip == true then
		UIUtil.setScale(play_img.transform, -0.8, 0.8)
	else
		UIUtil.setScale(play_img.transform, 0.8)
	end
	--evo
	self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui", prefix .. "hero_evo")
	--name
	local class_str = Language:getTextByKey(cfg.class)
	local name_str = Language:getTextByKey(skin_cfg.name)
	self:setTextByLanKey(prefix .. "hero_name", name_str)
	self:setTextByLanKey(prefix .. "hero_name2", class_str)
	--race
	local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), prefix .. "hero_race")
end

function M:setToggleInfo(index, focus)
	if index == 3 then
		local toggle3_info = self:findGameObject("toggle3_info")
		if focus == true then
			UIUtil.setLocalPosition(toggle3_info.transform, -10,-35)
		else
			UIUtil.setLocalPosition(toggle3_info.transform, -35,-30)
		end
		return
	end
	if index == 4 then
		local toggle4_info = self:findGameObject("toggle4_info")
		if focus == true then
			UIUtil.setLocalPosition(toggle4_info.transform, 0,-30)
		else
			UIUtil.setLocalPosition(toggle4_info.transform, -35,-30)
		end
		return
	end
end

function M:closeWishFiger()
	self:setObjectVisible("figer_sp", false)
end

function M:fingerSliding(locat)
	if locat == true then
		self:updateMsg("Sliding_right")
	elseif locat == false then
		self:updateMsg("Sliding_left")
	end
end

--[[
	创建列表
--]]
function M:updateGachaLoopScroll()
	self.m_sel_cell_obj = nil
	local data = {1,1,1,1,1}
	for index = 1, 5 do
		local cell_object = self:findGameObject("gacha_list_cell_" .. index)
		local cell_data = data[index]
		if cell_data then
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			luaBehaviour:RegistButtonClick(function(click_object, click_name)
				if index < 4 then
					if self.m_sel_cell_obj then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", false)
					end
					self.m_model.m_index = index
					self.m_sel_cell_obj = cell_object
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", true)
					self:updateMsg("index_change",index)
				end
			end)
			cell_object:SetActive(true)
			self:updateScrollViewCell(index, cell_object, cell_data)
			if index == 3 then
				self.m_limit_time_text = luaBehaviour:FindText("limit_time_text")
			end
		else
			cell_object:SetActive(false)
		end
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if index == self.m_model.m_index then
		self.m_sel_cell_obj = cell_object
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", true)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", false)
	end
	-- local unlock_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_text", "new_str_0576")
	-- unlock_text.gameObject:SetActive(index > 3)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gacha_name_text", __get_tips_tab[index] or "")
	LuaBehaviourUtil.setImg(luaBehaviour, "event_cell_btn", __gacha_list_cell_bgs[index], "pub_ui")
	local limit_time_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "limit_time_text", "")
	if index == 3 then
		local data = self.m_model.m_data.today_end_ts
		local down_time = data - UserDataManager:getServerTime()
		if down_time >= 0 then
			local text = GameUtil:formatTimeBySecond(down_time)
			limit_time_text.text = text
		end
	end
	limit_time_text.gameObject:SetActive(index == 3)
	local red_flag = self.m_model:redPointCheck(index)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"gacha_" .. index .. "_redpoint", red_flag)
end

function M:updateSkipAnimStatus()
	--local unlock_normal_time = ConfigManager:getCommonValueById(427)
	--if self.m_model.m_bless_data.normal_times < unlock_normal_time then
	--	self:setObjectVisible("skip_anim_btn", false)
	--else
		self:setObjectVisible("skip_anim_btn", true)
	--end
	self:setObjectVisible("skip_anim_open_img", self.m_model.m_skip_anim_flag == true)
	self:setObjectVisible("skip_anim_close_img", self.m_model.m_skip_anim_flag == false)
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
	else
		--GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self.toggle4_time_text.text = Language:getTextByKey("gf_str_0085")
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
	M.super.destroy(self)
end

return M