local M = class("QiXiGiftBridgeView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiGiftBridge"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	local attr_mode = 1
	if self.m_model.is_tokens == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})

	self.avtive_data = self.m_model:getActiveData()
	self:setTextByLanKey("close_title_text", self.avtive_data.name)
	
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
	self:refreshPriceInfo()
	self:setHeroInfo()
end

--设置皮肤购买信息
function M:refreshPriceInfo()
	local skin_data = self.m_model.m_hero_skin_data
	local off_str = skin_data.return_per or ""
	self:setTextByLanKey("right_cut_text", off_str)
	local price_new = skin_data.price_new or 9999
	local price_old = skin_data.price_old or 9999
	self:setTextByLanKey("right_btn_text", GameUtil:getMoneyTypeNum(price_new))
	self:setTextByLanKey("right_btn_text2", GameUtil:getMoneyTypeNum(price_old))
	self:setObjectVisible("right_btn_text2",true)
	self:setObjectVisible("RawImage",true)
	if self.m_model.m_hero_gift_times > 0 then
		self.m_buy_hero_btn_img.material = self.hui.material;
		self.m_buy_hero_btn.interactable = false;
		self:setTextByLanKey("right_btn_text", "flower_text_0015") 
		self:setObjectVisible("UI_SkinShop_GouMai",false)
	end
	if self.m_model:getClothesGift() > 0 then --已经购买过
		self.m_buy_hero_btn_img.material = self.hui.material;
		self:setTextByLanKey("right_btn_text", "gf_str_0048")
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
	--设置价格
	local price = cell_data.xlsxData.charge_id == 0 and Language:getTextByKey("new_str_0278") or GameUtil:getMoneyTypeNum(cell_data.xlsxData.price)
	LuaBehaviourUtil.setText(luaBehaviour, "buy_text", price)
	local buy_times = self.m_model:setGiftTimes(cell_data.index)
	local bg_img = luaBehaviour:FindGameObject("bg_img")
	local btn_buy = luaBehaviour:FindButton("buy_btn")
	local is_buy = buy_times < cell_data.xlsxData.time_limit
	--是否能购买
	if is_buy then --可以购买
		GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian01")
		btn_buy.interactable = true
	else
		GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian02")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_text", "qi_xi_048")
		btn_buy.interactable = false
	end
	local reward = cell_data.xlsxData.reward or {}
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	local reward_list = GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 0.8)
	for i, v in pairs(reward_list) do
		local luaBhvItemFree = UIUtil.findLuaBehaviour(v)
		LuaBehaviourUtil.setObjectVisible(luaBhvItemFree, "duigoudi_img", not is_buy)
	end
	--设置名称
	local buy_num = cell_data.xlsxData.time_limit - buy_times >= 0 and cell_data.xlsxData.time_limit - buy_times or 0
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

--设置英雄属性
function M:setHeroInfo()
	local reward = self.m_model.m_hero_skin_data.reward
	local reward_data = RewardUtil:getProcessRewardData(reward[1])

	local class_str = Language:getTextByKey(reward_data.item_cfg.class)
	local name_str = Language:getTextByKey(reward_data.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	local race = GlobalConfig.TYPE_HERO_RACE[reward_data.item_cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[reward_data.item_cfg.max_evo]
	self:setImg(GameUtil:get_lineframename(reward_data.item_cfg.Ex_hero,reward_data.item_cfg.max_evo), "common_ui","hero_evo")

	local spine_name = reward_data.item_cfg.hero_spine or "hero_0001_SkeletonData"
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