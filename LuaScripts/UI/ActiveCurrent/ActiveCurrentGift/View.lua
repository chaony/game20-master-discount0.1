local M = class("ActiveCurrentGiftView",LikeOO.OOPopBase)

M.m_uiName = "ActiveCurrent/ActiveCurrentGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	local attr_mode = 1
	if self.m_model.is_tokens == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	if self.m_model.m_active_data ~= nil then
		self:setTextByLanKey("close_title_text", self.m_model.m_active_data.cell_data.cfg.name)
		local bg_img = self:findGameObject("bg_img")
		GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..self.m_model.m_background) --设置背景
	end
	self.hui = self:findImage("hui")
	self.m_buy_hero_btn_img = self:findImage("buy_hero_btn")
	self.m_buy_hero_btn = self:findButton("buy_hero_btn")
	self.m_node_cache = {}
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowGift")
	self:setObjectVisible("timerImg_down",false)
	self:setTextByLanKey("text_timer_title","Pub_str_0004")
	self:setTextByLanKey("text_timer_title","Pub_str_0004")
end

function M:everyDayRefreshEvent()
	self:updateMsg("refresh_index")
end

--刷新UI
function M:refreshUI()
	self:updateBagNode()
	self:setHeroInfo()
	self:refreshPriceInfo()
end

function M:refreshPriceInfo()
	local off_str = self.m_model:getHeroPriceCfg("return_per") or ""
	self:setTextByLanKey("right_cut_text", off_str)
	local price_new = self.m_model:getHeroPriceCfg("price_new") or 9999
	local price_old = self.m_model:getHeroPriceCfg("price_old") or 9999
	self:setTextByLanKey("right_btn_text", GameUtil:getMoneyTypeNum(price_new))
	self:setTextByLanKey("right_btn_text2", GameUtil:getMoneyTypeNum(price_old))
	--self:setObjectVisible("buy_hero_gray_img",self.m_model.m_hero_gift_times > 0)
	if self.m_model.m_hero_gift_times > 0 then
		self.m_buy_hero_btn_img.material = self.hui.material;
		self.m_buy_hero_btn.interactable = false;
		self:setTextByLanKey("right_btn_text", "flower_text_0015") 
		self:setObjectVisible("UI_SkinShop_GouMai",false)
	end
end

function M:updateBagNode()
	local data = self.m_model:getGiftShowData()
	if self.m_rightloop_scroll_view == nil then
		local loopscroll = self:findGameObject("btns_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:setRewardInfo(index,cell_object,cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("buy_btn", {index = index,cell_data = cell_data})
			end
		}
		self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rightloop_scroll_view:reloadData(data, true)
	end
	self:updateJianTou()
end

--设置礼包信息
function M:setRewardInfo(index,cell_object,cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)

	local reward = cell_data.cfg.reward or {}
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 0.8)
	local bg_img = luaBehaviour:FindGameObject("bg_img")
	local btn_buy = luaBehaviour:FindButton("buy_btn")
	--是否能购买
	if cell_data.times < cell_data.cfg.time_limit then
		GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian01")
		btn_buy.interactable = true
	else
		GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian02")
		btn_buy.interactable = false
	end
	--设置价格
	local price = cell_data.cfg.charge_id == 0 and Language:getTextByKey("new_str_0278") or GameUtil:getMoneyTypeNum(cell_data.cfg.price)
	LuaBehaviourUtil.setText(luaBehaviour, "buy_text", price)
	--设置名称
	local buy_num = cell_data.cfg.time_limit - cell_data.times >= 0 and cell_data.cfg.time_limit - cell_data.times or 0
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"title_text",Language:getTextByKey("gf_str_0050",buy_num))
	
end

function M:onValueChanged(pos)
	self:updateJianTou()
end

function M:updateActivityTimer()
	local min_unit = 60
	local hour_unit = min_unit * 60
	local time_now = UserDataManager:getServerTime()
	local time_day_end = TimeUtil.getIntTimestamp(time_now) + hour_unit * 24 * 1
	local time_left = time_day_end - time_now
	local hour_left = math.floor(time_left / (hour_unit))
	local min_left = math.floor((time_left - hour_unit * hour_left) / min_unit)
	local sec_left = math.floor(time_left - hour_unit * hour_left - min_unit * min_left)
	local timerFormat = Language:getTextByKey("evil_shadow_str_010", hour_left, min_left, sec_left)
	self:setText("text_timer", timerFormat)
end

function M:updateJianTou()
	local loop_view = self.m_rightloop_scroll_view
	local loop_view_num = 2
	if loop_view and loop_view.m_line_count > loop_view_num then
		if loop_view:getVerticalNormalizedPosition() < 0.1 then
			self:setObjectVisible("jiantou_bottom_img", false)
		else
			self:setObjectVisible("jiantou_bottom_img", true)
		end
		if loop_view:getVerticalNormalizedPosition() > 0.9 then
			self:setObjectVisible("jiantou_top_img", false)
		else
			self:setObjectVisible("jiantou_top_img", true)
		end
	else
		local show_data = self.m_model:getGiftShowData()
		if #show_data < 5 then
			self:setObjectVisible("jiantou_bottom_img", false)
		else
			self:setObjectVisible("jiantou_bottom_img", true)
		end
		self:setObjectVisible("jiantou_top_img", false)
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

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end


return M