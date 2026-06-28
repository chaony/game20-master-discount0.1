local M = class("NewYearGiftView",LikeOO.OOPopBase)

M.m_uiName = "GiftBag/CelebrateNewYear/NewYearGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})

	local open_data = self.m_model:getActiveCfgByOpenId(263)
	if open_data and open_data.name then
		self:setTextByLanKey("close_title_text", (Language:getTextByKey(open_data.name)))
	end
	self.m_node_cache = {}
	self:refreshUI()
	local zhulin = self:findRectTransform("new_year_sk")
    local bg_scale_w = self.m_view_width/GlobalConfig.BG_UI_DESIGN_WIDTH
    local bg_scale_h = self.m_view_height/GlobalConfig.BG_UI_DESIGN_HEIGHT
    local new_rate = math.max(bg_scale_w , bg_scale_h)
    UIUtil.setLocalScale(zhulin, new_rate, new_rate)

	self:setObjectVisible("hero_info", true)
	self:setObjectVisible("look_hero_info", true)
end

function M:everyDayRefreshEvent()
	self:updateMsg("refresh_index")
end

--刷新UI
function M:refreshUI()
	local attr_mode = 1
	if self.m_model.is_tokens == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	self:createGiftLoopScroll()
	--self:updateBagNode()
	self:setHeroInfo()
end

function M:createGiftLoopScroll()
	--self.m_gift_tab = {}
	self.m_node_cache = {}
	local show_data = self.m_model:getShowData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("gift_loopscroll")
		local params ={
			show_data = show_data,
			loop_scroll_object = loopscroll,
			one_line_count = 2,
			update_cell =function(index, cell_obj, cell_data)
				--self.m_gift_tab[index] = cell_obj
				self:updateGiftCell(cell_obj, cell_data, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("buy_btn", cell_data)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
		self.m_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
	else
		self.m_scroll_view:reloadData(show_data, true)
	end
	self:updateJianTou()
end


function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:updateGiftCell(obj, cell_data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local bg_img = luaBehaviour:FindGameObject("bg_img")
	local btn_buy = luaBehaviour:FindButton("buy_btn_1")
	if cell_data == nil or cell_data.times and cell_data.time_limit and cell_data.times >= cell_data.time_limit then --购买次数已满，或者数据非法时，锁住购买按钮
		GameUtil:updateResourcesImg(bg_img, "Texture/evil_shadow/a_mycs_yilinqulibaochendi")
		btn_buy.enabled = false
	else
		GameUtil:updateResourcesImg(bg_img, "Texture/evil_shadow/a_mycs_libaochendi")
		btn_buy.enabled = true
	end
	if cell_data then
		local limit_time = 0
		if cell_data.time_limit and cell_data.times and cell_data.time_limit - cell_data.times > 0 then
			limit_time = cell_data.time_limit - cell_data.times
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gift_title_text", "evil_shadow_str_012", limit_time)
		local price_str = Language:getTextByKey("new_str_0278")
		if cell_data.price ~= nil and cell_data.price ~= 0 then
			price_str = Language:getTextByKey("gf_str_0029", tonumber(cell_data.price) )
		end
             
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_text", price_str)
		self:updateRewardLoopscroll(index, cell_data.reward, luaBehaviour)
	end
	self:updateJianTou()
end

function M:updateRewardLoopscroll(node_index, reward_datas, luaBehaviour)
	if self.m_node_cache[node_index] == nil then
		local loopscroll = luaBehaviour:FindGameObject("loopscroll")
		local params = {
			show_data = reward_datas,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local reward_data = RewardUtil:getProcessRewardData(cell_data)
				local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
				ui_element.red_point_img:SetActive(false)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			end,
			ui_name = self.m_uiName
		}
		self.m_node_cache[node_index] = LoopScrollViewUtil.new(params)
	else
		self.m_node_cache[node_index]:reloadData(reward_datas)
	end
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time, 999)
		self:setTextByLanKey("text_timer", text)
	--else
	--	self:updateMsg(99999)
	end
end

--显示Spine
function M:showSpineReward( obj, reward, txtName )
	local item_data = RewardUtil:getProcessRewardData(reward)
	if item_data ~= nil and item_data.item_cfg ~= nil then
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(item_data.item_cfg.hero)
		self:setTextByLanKey("hero_name2", hero_cfg.class);
		self:setTextByLanKey("hero_name", hero_cfg.name);
		local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
		self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")

		GameUtil:updateSpineLoadSet(obj, "RoleSpine/"..item_data.item_cfg.hero_spine, "idle", 0, true)
	end
end

function M:setHeroInfo()
	local skin_tab = self.m_model:getSkins()
	local play_img = self:findGameObject("hero_spine")
	self:showSpineReward(play_img, skin_tab.reward[1], "right_hero_txt")
end

function M:updateJianTou()
    local loop_view = self.m_scroll_view
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
		local show_data = self.m_model:getShowData()
		if #show_data < 5 then
			self:setObjectVisible("jiantou_bottom_img", true)
		else
			self:setObjectVisible("jiantou_bottom_img", false)
		end
        self:setObjectVisible("jiantou_top_img", false)  
    end
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