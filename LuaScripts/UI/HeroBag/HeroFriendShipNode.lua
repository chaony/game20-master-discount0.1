local M = class("HeroFriendShipNode", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroFriendShipNode"

function M:onEnter()
    self.m_gray_image = self:findImage("a_gray_img")
	self.allGiftBtnImg = self:findImage("btn_sendAllBtn")
	self.grayImage = self:findImage("grayImage")
	self.giftBtnImg = self:findImage("send_gift_btn")
	self.eftParent = self:findGameObject("eftNode")
	self.maxLevel = self.m_model:getMaxFriendShipLvBySeason()
	self.m_select_index = 1
	self.send_num = 0
    local function m_levelupclick()
		self:sendGift()
	end
	local function m_levelupclickup()
		self:sendGiftNet()
	end
	self:setTextByLanKey("send_gift_text", "semd_gift_text")
	self:setTextByLanKey("send_all_gift_text","bag_text_0002")
	
	self:addActionChangAn("send_gift_btn", m_levelupclickup, m_levelupclick)
	self.m_model:updateSetFettersItems()
    self:refreshUI()
end

function M:getMaxLevel()
	local max_level = ConfigManager:getCommonValueById(533, 999)
	local cur_season = UserDataManager:getCurSeason()
	local friend_ship_cfg = ConfigManager:getCommonValueById(636, {})
	local min_season, max_season = 0
	if #friend_ship_cfg > 0 then
		max_season = friend_ship_cfg[#friend_ship_cfg][1]
		min_season = friend_ship_cfg[1][1]
	else
		return max_level
	end
	if cur_season < min_season then
		return max_level
	elseif cur_season >= max_season then
		return friend_ship_cfg[#friend_ship_cfg][3]
	end
	for i = 1, #friend_ship_cfg do
		local friend_ship_tab = friend_ship_cfg[i]
		local need_season = friend_ship_tab[1]
		if cur_season == need_season then
			max_level = friend_ship_tab[3]
			break
		end
	end
	return max_level
end

function M:sendGift()
	local fetter_tab = self.m_model.fetters_items or {}
	local fetter_data = self.m_model:getFettersData()
	if fetter_tab[self.m_select_index] == nil then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_6"), delay_close = 2})	
		return
	end
	if #fetter_tab > 0 and fetter_tab[self.m_select_index] then
		local item_id = fetter_tab[self.m_select_index]
		local item_data, item_cfg = UserDataManager.item_data:getItemDataById(item_id)
		if item_data then
			if item_data.num > 0 and item_data.num > self.m_model.send_friend_item_num then
				if item_data.num > 100 and fetter_data.lv >= 3 then
					self.m_model.send_friend_item_num = self.m_model.send_friend_item_num + 5
				else
					self.m_model.send_friend_item_num = self.m_model.send_friend_item_num + 1
				end			
				self:givingGifts(item_id)
			else
				self:sendGiftNet()
			end
		end
	end
end

-- 前端赠送好感道具
function M:givingGifts(item_id)
    local item_data, item_cfg = UserDataManager.item_data:getItemDataById(item_id)
	if item_data.num <= self.m_model.send_friend_item_num then
		self.m_model.send_friend_item_num = item_data.num
		self:sendGiftNet()
	else
		self:flyFriendEft()
		self:refreshUI()
	end
end

function M:showFriendLevelUpEft()
	--self:showItemGiftEft()
	self:flyFriendEft()
end

--发送送礼消息
function M:sendGiftNet()
	local item_id = self.m_model.fetters_items[self.m_select_index]
	if item_id == nil then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_6"), delay_close = 2})	
		return
	end
	local item_data, item_cfg = UserDataManager.item_data:getItemDataById(item_id)
	if item_data.num > 0 then
		if self.m_model.send_friend_item_num == 0 then
			self.m_model.send_friend_item_num = 1
		end
		-- isNormalBtn普通升级按钮
		self.m_control:sendGivingGiftsNet({datas = {{item_id = item_id, num = self.m_model.send_friend_item_num}},isNormalBtn = true})
		self.m_model.send_friend_item_num = 0
	else
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_6"), delay_close = 2})	
		return	
	end
end

function M:refreshUI()
	if self.m_model:checkOpenFriendShip() == false then
		return
	end
	local fetter_tab = self.m_model.fetters_items or {}
	local fetter_data = self.m_model:getFettersData()
	self.title_index = {}
	self:updateScroll(fetter_tab,fetter_data.lv)
	if fetter_data.lv >= 10 then
		local num_1 = math.floor(fetter_data.lv/10)
		local num_2 = fetter_data.lv-(num_1*10)
		self:setImg(num_1,"active_ui","youqing_lv_img_1")
		self:setImg(num_2,"active_ui","youqing_lv_img_2")
		self:setObjectVisible("youqing_lv_img_2", true)
		self:setObjectVisible("youqing_lv_img_1", true)
		self:setObjectVisible("youqing_lv_img", false)
	else
		self:setObjectVisible("youqing_lv_img_2", false)
		self:setObjectVisible("youqing_lv_img_1", false) --
		self:setObjectVisible("youqing_lv_img", true)
		self:setImg(fetter_data.lv,"active_ui","youqing_lv_img")
	end

	local lv_cfg = self.m_model:getFetterEqpMaxNum()
	local cur_cfg = self.m_model:getFetterEqp()
	self:setTextByLanKey("slider_num", fetter_data.point.."/"..lv_cfg.upgrade)
	local slider = self:findSlider("slider_obj")
	slider.value = (fetter_data.point/lv_cfg.upgrade)
	local quality_tab = ConfigManager:getCommonValueById(496, {})
	local cur_quality = 0
	for k,v in pairs(quality_tab) do
		if v[1] == fetter_data.lv then
			cur_quality = v[2]
		end
	end
	local isMaxLevel = (fetter_data.lv >= self.maxLevel)
	self:setObjectVisible("content_text", (not isMaxLevel))
	if not isMaxLevel then
		if cur_quality > 0 then
			local cur_qualit = GlobalConfig.QUALITY_COMMON_SETTING[cur_quality]
			if cur_qualit then
				self:setTextByLanKey("content_text", "hero_ui_str_0033", Language:getTextByKey(cur_qualit.name))
				self:setObjectVisible("content_text", true)
			else
				self:setObjectVisible("content_text", false)
			end
		else
			self:setObjectVisible("content_text", false)
		end
	end
	
	local c_quality = 0
	self:refreshTempFetterLv()
	if self.m_model:checkFriendMaxLv() == true then
		self:setTextByLanKey("slider_num", "new_str_0067")
		local slider = self:findSlider("slider_obj")
		slider.value = 1
		self:setObjectVisible("content_text", false)
		self:setObjectVisible("bottom_tips", false)
		self:setObjectVisible("send_gift_btn", false)
		self:setObjectVisible("CommonTipsNode", false)
		self:setObjectVisible("max_bg_img", true)
		self:setTextByLanKey("max_des_text", "new_str_1081")
	else
		if cur_quality > 0 and (not isMaxLevel) then
			self:setObjectVisible("content_text", true)
		end
		self:setObjectVisible("max_bg_img", false)
		self:setObjectVisible("bottom_tips", true)
		self:setObjectVisible("send_gift_btn", true)
	end
	self:setTextByLanKey("bottom_tips", self.m_model:getHeroLickTypeStr())

	-- 按钮置灰
	local allGiftData, needExp, isCanLevelUp = self.m_model:getAllGiftData()
	local isAllGiftGray = needExp > 0
	if isAllGiftGray then
		isAllGiftGray = (#allGiftData <= 0)
	end
	self.allGiftBtnImg.material = isAllGiftGray and self.grayImage.material or nil

	local item_id = self.m_model.fetters_items[self.m_select_index]
	local isGiftGray = false
	if item_id then
		local item_data, item_cfg = UserDataManager.item_data:getItemDataById(item_id)
		isGiftGray = item_data.num <= 0
	end
	self.giftBtnImg.material = isAllGiftGray and self.grayImage.material or nil

	local isMaxLevel = (fetter_data.lv >= self.maxLevel)
	self:setObjectVisible("send_gift_btn", (not isMaxLevel))
	self:setObjectVisible("btn_sendAllBtn", (not isMaxLevel))
end

function M:showFriendEft()
	--- 特效闪一下
	self.m_control:setOnceTimer(1,function()
		-- 隐藏特效
		self.m_control:showFriendEft()
	end)
end

function M:refreshTempFetterLv()
	if self.m_model.send_friend_item_num and self.m_model.send_friend_item_num > 0 then
		local item_id =  self.m_model.fetters_items[self.m_select_index] or 0
		local fetter_data = self.m_model:getFettersData()
		local lv_cfg = self.m_model:getFetterEqpMaxNum()
		local item_data, item_cfg = UserDataManager.item_data:getItemDataById(item_id)
		local add_num = 0
		for k,v in pairs(item_cfg.effect) do
			if v[1] == fetter_data.lv then
				add_num = v[2]
			end
		end
		local cur_all_num = fetter_data.point + (add_num*self.m_model.send_friend_item_num)
		self:setTextByLanKey("slider_num", cur_all_num.."/"..lv_cfg.upgrade)
		local slider = self:findSlider("slider_obj")
		slider.value = (cur_all_num/lv_cfg.upgrade)
		if cur_all_num >= lv_cfg.upgrade then
			self:sendGiftNet()
		end
	end
end

function M:updateSelectHero()
	self.m_model:updateSetFettersItems()
	if self.m_model.send_friend_item_num > 0 then
		self:sendGiftNet()
	end

end

function M:refreshFettersItem()
	if self.m_list_scroll then
		self.m_list_scroll:moveToCellIndex(1)
	end
end

function M:refreshScroll()
	local fetter_tab = self.m_model.fetters_items or {}
	local fetter_data = self.m_model:getFettersData()
	self:updateScroll(fetter_tab, fetter_data.lv)
end


function M:updateScroll(data, friendLevel)
	data = data or {}
	local isMaxLevel = (friendLevel >= self.maxLevel)
	data = isMaxLevel and self.m_model.oneLevelGiftData or data
	if #data == 0 then
		self:setObjectVisible("CommonTipsNode", true)
		self:setTextByLanKey("common_no_have_text", "tid#haogandutips_2")
	else
		self:setObjectVisible("CommonTipsNode", false)
	end
	if self.m_select_index > #data then
		self.m_select_index = #data
	end
	if self.m_select_index == 0 and #data > 0 then
		self.m_select_index = 1
	end

	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("scroll_list")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
            loop_scroll_object = list_scroll,
			one_line_count = 3, -- 行或列的数量
			update_cell = function(index, cell_object, cell_data)
				self:updateItem(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
				if index ~= self.m_select_index then
					self.m_select_index = index
					self.selectItemObj = cell_object
					self:refreshScroll()
				end
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
	self:setObjectVisible("jiantou_img", #data > 9)
end

function M:updateJianTou()
	if self.m_list_scroll and self.m_list_scroll.m_line_count > 3 then
		if self.m_list_scroll:getVerticalNormalizedPosition() < 0.1 then
			self:setObjectVisible("jiantou_img", false)
		else
			self:setObjectVisible("jiantou_img", true)
		end
	else
		self:setObjectVisible("jiantou_img", false)
	end
end

function M:updateItem(index, obj, data)
	if self.m_select_index == index then
		self.selectItemObj = obj
	end
	local fetter_data = self.m_model:getFettersData()
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local itemNode = luaBehaviour:FindGameObject("ItemNode")
		local item_data, item_cfg = UserDataManager.item_data:getItemDataById(data)
		local cell_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", item_cfg.name)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", index == self.m_select_index)	
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_click", index ~= self.m_select_index)	
		local num = item_data.num or 0
		if self.m_model.send_friend_item_num and self.m_model.send_friend_item_num > 0 then
			local item_id = self.m_model.fetters_items[self.m_select_index] or 0
			if data == item_id then
				num = item_data.num - self.m_model.send_friend_item_num
			end
		end
		local add_num = 0
		local init_num = self:getMinLv(item_cfg.effect)
		for k,v in pairs(item_cfg.effect) do
			if v[1] == fetter_data.lv then
				add_num = v[2]
			end
		end
		
		local isMaxLevel = (fetter_data.lv >= self.maxLevel)
		GameUtil:updateItemElement(itemNode, {RewardUtil.REWARD_TYPE_KEYS.ITEM,data,num}, (not isMaxLevel), index == self.m_select_index)
		local item_img = luaBehaviour:FindImage("item_img")
		local quality_img = luaBehaviour:FindImage("quality_img")
		if isMaxLevel then
			item_img.material = self.m_gray_image.material
			quality_img.material = self.m_gray_image.material
		else
			if num == 0 then
				item_img.material = self.m_gray_image.material
				quality_img.material = self.m_gray_image.material
			else
				item_img.material = nil
				quality_img.material = nil
			end
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "debuff_img", false)
		local add_text = nil
		if add_num and add_num > 0 and num > 0 then
			add_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_num", "+"..add_num)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_num", true)
			local temp_color = GlobalConfig.QUALITY_FRIEND_ITEM[item_cfg.quality].RGBA
			add_text.color = temp_color
			UIUtil.setOutlineExEffectColor(add_text, nil, GlobalConfig.QUALITY_FRIEND_ITEM[item_cfg.quality].outLineColor, 2)
			if init_num > add_num then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "debuff_img", true)
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_num", false)
		end
		self:updateJianTou()
	end
end

-- 道具框特效
function M:showItemGiftEft()
	--if IsNull(self.selectItemObj) then
	--	return
	--end
	--local item_obj = ResourceUtil:LoadUIGameObject("HeroBag/UI_HeroBag_BianK_001", Vector3.zero, self.selectItemObj)
	--item_obj.transform.localPosition = Vector3(0,8,0)
	--item_obj.transform:SetParent(self.eftParent.transform,true)
	--self.m_control:setOnceTimer(1,function()
	--	UIUtil.destroyObject(item_obj)
	--	local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
	--	if not isPlayOverFriendLevelUpEft then
	--		return
	--	end
	--	self:flyFriendEft(flyitem_obj)
	--end)
end

-- 道具飞向侠客的特效
function M:flyFriendEft()
	if IsNull(self.selectItemObj) then
		return
	end
	local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
	if not isPlayOverFriendLevelUpEft then
		return
	end
	local item_obj = ResourceUtil:LoadUIGameObject("HeroBag/UI_HeroBag_BianK_001", Vector3.zero, self.selectItemObj)
	item_obj.transform.localPosition = Vector3(0,8,0)
	local flyitem_obj = ResourceUtil:LoadUIGameObject("HeroBag/UI_HeroBag_GuiJi_001", Vector3.zero, self.selectItemObj)
	if IsNull(self.selectItemObj) or IsNull(flyitem_obj) or IsNull(item_obj) then
		return
	end
	self.m_control:setOnceTimer(0.6,function()
		UIUtil.destroyObject(item_obj)
	end)
	local target = self:findGameObject("eftTargetPos")
	flyitem_obj.transform.localPosition = Vector3.zero
	self:flyMove(flyitem_obj, 0.5, target)
end

function M:flyMove( obj, delay, target )
	if IsNull(obj) then
		return
	end
	if IsNull(target) then
		return
	end
	obj.transform:SetParent(self.eftParent.transform, true)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(obj.transform:DOLocalMove(target.transform.localPosition, 0.4))
	sequence:OnComplete(function()
		self.m_control:setOnceTimer(0.6,function()
			UIUtil.destroyObject(obj)
		end)
		
		local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
		if not isPlayOverFriendLevelUpEft then
			return
		end
		-- self.m_control:showFriendEft()
	end)
	--李珺>>好感度的那个特效调整：从道具飞过去的特效，它飞它的，桃心冒桃心的，分别播放；
	self.m_control:showFriendEft()
end

function M:getMinLv(effect)
	local tab = {}
	for k,v in pairs(effect) do
		table.insert(tab, {lv = v[1], num =v[2]})
	end
	local init_num = tab[1].num or 0
	return init_num
end

function M:onButtonClick(obj, name)
	--if name == "youqing_btn" then
	--	local h_data, h_cfg = self.m_model:getSelectHeroData()
	--	local fetter_data = self.m_model:getFettersData()
	--	if fetter_data.lv > 0 and h_cfg then
	--		GameUtil:lookGoodFeelInfoTips(self.m_control, {hero_id = h_cfg.id})
	--	else
	--		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_1"), delay_close = 2})
	--	end
	--else  
    if name == "youqing_hint_btn" then  
		local params = {}
		params.content = Language:getTextByKey("tid#haogandutips_4") 
        params.title = Language:getTextByKey("new_str_0338")
        self:openView("Pops.CommonHelpPop", params)
	else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
	if self.m_model.send_friend_item_num > 0 then
		self:sendGiftNet()
	end
	M.super.destroy(self)
end


return M
