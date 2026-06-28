local M = class("LimitPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/LimitPop"
M.m_size_type = 2

function M:onEnter()
	audio:SendEvtUI("UI_Popup_N3")
	self.m_model.currentActiveMode = tonumber(self.m_model:getCurrentActiveMode()) --当前活动模式 1.特殊模式， 0.普通模式
	self:setObjectVisible("ordinary_limit",self.m_model.currentActiveMode == 0)
	self:setObjectVisible("active_limit",self.m_model.currentActiveMode == 1)
	if self.m_model.currentActiveMode == 1 then --是特殊活动礼包
		self:setPopInfo()
		self.reward_grid = self:findGameObject("active_reward_node")
	else --正常活动
		self:setSpine()
		self.reward_grid = self:findGameObject("reward_node")
	end
    self.m_gray_image = self:findImage("gary_img")
	self:createLoopScroll()
	self:updateTogLight()
	self:refreshUI()
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
    self.m_tag_tab = {}
	local data = self.m_model.m_tag_table
	local loopscroll_name = self.m_model.currentActiveMode == 0 and "tab_loopscroll" or "active_tab_loopscroll"
	local one_line_count_num = self.m_model.currentActiveMode == 0 and 1 or 1
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject(loopscroll_name)
        local params = {
            show_data = data,
			one_line_count = one_line_count_num,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[index] = {data = cell_data, obj = cell_obj}
                self:update_tag(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("change_tag", index)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local tag_name = self.m_model.currentActiveMode == 1 and "new_str_1085" or "gf_str_0007"
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text_dark", tag_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text_light", tag_name)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_dark", self.m_model.m_select_index == index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_light", self.m_model.m_select_index ~= index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_select_index == index)
		if self.m_model.currentActiveMode == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_dark", self.m_model.m_select_index ~= index)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_light", self.m_model.m_select_index == index)
			if self.light_btn_img ~= nil then
				LuaBehaviourUtil.setImg(luaBehaviour,"light",self.light_btn_img,"active_ui")
			end
			if self.no_light_btn_img ~= nil then
				LuaBehaviourUtil.setImg(luaBehaviour,"bg",self.no_light_btn_img,"active_ui")
			end
		end
	end
end

function M:updateTogLight()
    -- for k, v in pairs(self.m_tag_tab) do
    --     local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
    --     if luaBehaviour then
    --         LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_dark", self.m_model.m_select_index == k)
	-- 		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_light", self.m_model.m_select_index ~= k)
	-- 		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_select_index == k)
    --     end
    -- end
end

function M:refreshUI()
	self:setTextByLanKey("common_pop_des", self.m_model.m_gift_cfg.des)
	self:setTextByLanKey("active_common_pop_des", self.m_model.m_gift_cfg.des)
	self:setTextByLanKey("num","gf_str_0033", self.m_model.m_gift_cfg.return_per)
	local show_btn = GameUtil:getMoneyTypeNum(self.m_model.m_gift_cfg.price)
	self:setTextByLanKey("get_reward_text", show_btn)
	self:setTextByLanKey("get_reward_active_text", show_btn)
	local num = #self.m_model.m_rewards
	UIUtil.destroyAllChild(self.reward_grid.transform)
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
	end
	local return_per = tonumber(self.m_model.m_gift_cfg.return_per) * 100
	if return_per >= 1000 then
		self:setObjectVisible("num3", false)
		self:setObjectVisible("num3_ordinary", false)
		self:setObjectVisible("num4", true)
		self:setObjectVisible("num4_ordinary", true)
		local thousand_num = math.floor(return_per/1000)
		local hundred_num = math.floor((return_per - thousand_num*1000)/100)
		self:setImg( "a_xslb_num_"..thousand_num, "active_ui", "fanli_num_4_1")
		self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_4_2")
		self:setImg( "a_xslb_num_"..thousand_num, "active_ui", "fanli_num_4_1_ordinary")
		self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_4_2_ordinary")
	else
		self:setObjectVisible("num3", true)
		self:setObjectVisible("num3_ordinary", true)
		self:setObjectVisible("num4", false)
		self:setObjectVisible("num4_ordinary", false)
		local hundred_num =  math.floor(return_per/100)
		local ten_num = math.floor((return_per - hundred_num*100)/10)
		self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_3_1")
		self:setImg( "a_xslb_num_"..ten_num, "active_ui", "fanli_num_3_2")
		self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_3_1_ordinary")
		self:setImg( "a_xslb_num_"..ten_num, "active_ui", "fanli_num_3_2_ordinary")
	end
	self:updateTime()
end

function M:updateTime()
	local end_time = self.m_model:getGiftPushTim()
	if end_time then
		local down_time = end_time - UserDataManager:getServerTime()
		local show_text = GameUtil:formatTimeBySecond(down_time,999)..Language:getTextByKey("gf_str_0104")
		self:setTextByLanKey("bottom_des", show_text)
		self:setTextByLanKey("active_bottom_des", show_text)
		if down_time <= 0 then
			self:updateMsg(99999)
		end
	end
end

function M:setSpine()
	local hero_id = self.m_model:getHeroInReward()
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = hero_id})
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	if shin_data_cfg and next(shin_data_cfg) ~= nil then
		local icon = shin_data_cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	elseif cfg then
		local icon = cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	else
		self.cacheSpineName = "hero_0505_SkeletonData"
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	end
end

--设置特殊模式活动页面
function M:setPopInfo()
	local data_info = self.m_model:getActiveInfo()
	--设置spine
	if data_info[1] ~= nil then
		local play_img = self:findGameObject("active_hero_spine")
		local spine_name = self.m_model:getSpineName(data_info[1])
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..spine_name, "idle", 0, true)
	end
	--设置背景
	if data_info[2] ~= nil then
		local active_bg = self:findGameObject("active_bg")
		GameUtil:updateResourcesImg(active_bg,"Texture/"..data_info[2])
	end
	--设置领取按钮
	if data_info[3] ~= nil then
		self:setImg(data_info[3],"active_ui","get_reward_active")
	end
	--设置选中按钮图片
	self.light_btn_img = data_info[4]
	self.no_light_btn_img = data_info[5]
end

return M