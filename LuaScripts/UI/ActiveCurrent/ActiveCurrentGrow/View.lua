local M = class("ActiveCurrentExchangeShopView",LikeOO.OOPopBase)

M.m_uiName = "ActiveCurrent/ActiveCurrentGrow"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	if self.m_model.m_active_data ~= nil then
		local bg_img = self:findGameObject("bg_img")
		GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..self.m_model.m_background) --设置背景
	end
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1, item_id = self.m_model:getCostId()})
	self:setTextByLanKey("close_title_text", "gf_str_0006")
	self:setTextByLanKey("ranking_btn_text", "new_str_0235")
	self:setTextByLanKey("reward_btn_text", "new_str_0373")
	self:refreshUI()
	--RedPointUtil:saveLocalRedPointFreshTime("EvilShadowExchange")
end

function M:refreshRedPoint()
	self:setObjectVisible("reward_btn_red_point_img", self.m_model:haveDailyRedPoint())
end

function M:refreshUI()
	self:refreshRedPoint()
	self.m_end_ts = self.m_model:getEndTs()
	self.version = self.m_model.m_gift_version
	self.hero_show, self.gift_list = self.m_model:getGrowUpCfg(self.version)
	local max_data = UserDataManager:getHeroMaxEvo(self.hero_show.hero_id)
	if max_data then
		self.max_evo = max_data.max_evo or 0
	else
		self.max_evo = 0
	end
	self:createLoopScroll(self.gift_list)
	self:setHeroInfo()
	if self.m_scroll_view then
		if self.is_update and self.is_update == true then
			local pos = self.m_scroll_view:getContentOffset()
			if pos then
				self.m_scroll_view:setContentOffset(pos)
			end
		else
			local index = self.m_model:getGrowUpCanGetReward(self.version, self.max_evo)
			self.m_scroll_view:moveToCellIndex(index)
		end
	end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll(gift_list)
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = gift_list,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self:update_Gift(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
					self:updateMsg("buy_sdk_update")
					return
				end
				local buy_free, pay_num = self.m_model:getGrowUpRewardData(self.version, cell_data.id)
				if self.max_evo >= cell_data.quality then
					if click_name == "free_btn" and buy_free == false then
						self:updateMsg("get_hero_gift", {version = self.version, id = cell_data.id })
					elseif click_name == "pay_btn" and cell_data.time - pay_num > 0 then
						self:updateMsg("buy", cell_data.charge_id)
					end
				else
					local reward_data = RewardUtil:getProcessRewardData({101, self.hero_show.hero_id,1})
					local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cell_data.quality]
					GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0100", reward_data.name, Language:getTextByKey(farm_data.name)), delay_close = 2})
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(gift_list, true)
	end
end

function M:update_Gift(index, cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local free_node = luaBehaviour:FindGameObject("free_items")
		local pay_items = luaBehaviour:FindGameObject("pay_items")
		local buy_free = false
		local buy_pay = false
		local buy_free, pay_num = self.m_model:getGrowUpRewardData(self.version, cell_data.id)
		buy_pay = pay_num >= cell_data.time and true or false
		local heroNode = luaBehaviour:FindGameObject("HeroNode")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", GameUtil:getMoneyTypeNum(cell_data.price))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", GameUtil:getMoneyTypeNum(cell_data.price))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0278")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0278")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "quota_text", "gf_str_0073", cell_data.time - pay_num)
		local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cell_data.quality]
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text", "gf_str_0074", Language:getTextByKey(farm_data.name))
		local hero_data = RewardUtil:getProcessRewardData({101,self.hero_show.hero_id,1})
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img_mask", farm_data.hero_star > 0) -- 遮罩的角
		hero_data.quality = cell_data.quality
		CommonUIUtil:updateHeroElementByData(heroNode, hero_data)
		UIUtil.destroyAllChild(free_node.transform)
		UIUtil.destroyAllChild(pay_items.transform)
		GameUtil:createRewards(free_node.transform, cell_data.free_reward, true, true)
		GameUtil:createRewards(pay_items.transform, cell_data.charge_reward, true, true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_light", buy_pay == true )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_dark", buy_pay == false )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suo_img", self.max_evo < cell_data.quality )
		if buy_free == true then
			local free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0080")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0080")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
			local free_btn = UIUtil.findButton(free_img.transform)
			free_btn.interactable = false
		else
			local free_img =  nil
			if self.max_evo < cell_data.quality then
				free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
			else
				free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_kedianji", "active_ui")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", false )
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", true )
			end
			if free_img then
				local free_btn = UIUtil.findButton(free_img.transform)
				free_btn.interactable = true
			end
		end
		if buy_pay == true then
			local pay_img = LuaBehaviourUtil.setImg(luaBehaviour, "pay_btn", "a_yxczlb_btn_bukedianj", "active_ui")
			local pay_btn = UIUtil.findButton(pay_img.transform)
			pay_btn.interactable = false
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", "new_str_0080")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", "new_str_0080")
		else
			local pay_img = LuaBehaviourUtil.setImg(luaBehaviour, "pay_btn", "a_yxczlb_btn_kedianji", "active_ui")
			local pay_btn = UIUtil.findButton(pay_img.transform)
			pay_btn.interactable = true
		end
	end
end

function M:onButtonClick(obj, name)
	if name == "grow_check_btn" then
		local reward_data = RewardUtil:getProcessRewardData({101, self.hero_show.hero_id,1})
		static_rootControl:openView("Pops.HeroLookInfo", {hero_id = self.hero_show.hero_id, is_new = false})
	else
		M.super.onButtonClick(self, obj, name)
	end
end

function M:setHeroInfo()
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_hero_skin_data.hero)
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)

	local class_str = Language:getTextByKey(hero_cfg.class)
	local name_str = Language:getTextByKey(shin_data_cfg.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
	self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero,hero_cfg.max_evo), "common_ui","hero_evo")

	local spine_name = self.m_model.m_hero_skin_data.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:updateTime()
	local time_left = self.m_model:getEndTs() -  UserDataManager:getServerTime() + 2
	if time_left > 0 then
		local ts_des = GameUtil:formatTimeBySecond(time_left, 999)
		local timerFormat = Language:getTextByKey("openServerRank_str_0007", ts_des)
		self:setText("time_down_text", timerFormat)
	else
		self:updateMsg("time_down")
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M