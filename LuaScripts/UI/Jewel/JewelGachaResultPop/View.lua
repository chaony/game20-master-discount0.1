local M = class("JewelGachaResultPopView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/JewelGachaResultPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "jewel_text_002")
	self:setTextByLanKey("close_btn2_text", "new_str_0006")
	self:setTextByLanKey("gacha_btn_text", "jewel_text_013", #self.m_model.m_cards)
	self:setTextByLanKey("oneKey_btn_text", "Pub_str_0024")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {item_id = self.m_model.m_cost[2]})
	self.oneKey_btn = self:findGameObject("oneKey_btn")
	self:refresh()
end

function M:refresh()
	self.cards_node = {}
	local count = #self.m_model.m_cards
	if count == 1 then
		self:setObjectVisible("card_one", true)
		self:setObjectVisible("cards_panel", false)
		self.cards_node[1] = self:findGameObject("card_one")
		self:refreshCard(self.cards_node[1], self.m_model.m_cards[1])
	else
		self:setObjectVisible("card_one", false)
		self:setObjectVisible("cards_panel", true)
		for i = 1, count do
			self.cards_node[i] = self:findGameObject("card" .. i)
			self:refreshCard(self.cards_node[i], self.m_model.m_cards[i])
		end
	end
	local gacha_btn = self:findGameObject("gacha_btn")
	local cost = self.m_model.m_cost
	local itemData = RewardUtil:getProcessRewardData(cost)
	UIUtil.setImg(gacha_btn.transform, itemData.icon_name, "item_icon", "item_img")
	if itemData.user_num >= itemData.data_num then
		UIUtil.setText(gacha_btn.transform, itemData.data_num, "item_num")
	else
		UIUtil.setText(gacha_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "item_num")
	end
	self.oneKey_btn:SetActive(true)
	self:setObjectVisible("btn_node", false)
	self:lockTouch()
	self.m_control:setOnceTimer(0.5, function()
		self:unlockTouch()
	end)
end

function M:refreshCard(obj, reward)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_top_img", true)
	if reward.jewel and reward.jewel > 0 then --宝物
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_img", false)
		local cfg = UserDataManager.jewel_data:getDetailCfg(reward.jewel)
		local quality = cfg.quality
		if quality > 8 then
			quality = 8
		end
		LuaBehaviourUtil.setImg(luaBehaviour, "card_bg_img", "card_quality" .. quality, "jewel_ui")
		LuaBehaviourUtil.setImg(luaBehaviour, "card_top_img", "gacha_back_quality" .. quality, "jewel_ui")
		local icon_img = luaBehaviour:FindGameObject("icon_img")
		GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/" .. cfg.icon)
		--LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cfg.icon, "jewel_ui")
		local name_text = LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(cfg.name))
		local quality_cfg = GameUtil:getHeroQualityData(quality)
		name_text.color = quality_cfg.RGBA
		if cfg.hero_id and cfg.hero_id > 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"hero_icon", true)
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
			LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", hero_cfg.icon, "hero_head_ui")
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"hero_icon", false)
		end
		--宝物分解后道具
		local item_id, item_num = self.m_model:getItem(reward)
		if item_id then
			self:refreshItem(luaBehaviour, item_id, item_num)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"new_img", false) --有碎片说明分解了
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"new_img", true)
		end
	else --纯道具
		local item_id, item_num = self.m_model:getItem(reward)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_img", true)
		self:refreshItem(luaBehaviour, item_id, item_num)
	end
end

function M:refreshItem(luaBehaviour, item_id, item_num)
	local itemData = RewardUtil:getProcessRewardData({103, item_id, item_num})
	local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", itemData.icon_name, "item_icon")
	item_img.enabled = true
	local sort = itemData.item_cfg.sort
	if sort == 4 or sort == 28 then
		item_img.enabled = false
		local mystic_piece_icon = GameUtil:createPrefab("Common/MysticPieceIcon", item_img.transform)
		local mystic_lua_behaviour = UIUtil.findLuaBehaviour(mystic_piece_icon)
		LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img", itemData.icon_name, itemData.atlas_name or "item_icon")
		local mystic_quality_item = GlobalConfig.MYSTIC_ICON_COMMON_SETTING[itemData.quality]
		if mystic_quality_item then
			LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img_mask", mystic_quality_item.mask_img, "item_icon")
			LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img_di", mystic_quality_item.icon_img_di, "item_icon")
		end
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"item_num_text", itemData.name .. "x" .. itemData.data_num)
	--local quality = itemData.quality
	--if quality > 8 then
	--	quality = 8
	--end
	--LuaBehaviourUtil.setImg(luaBehaviour, "card_bg_img", "card_quality" .. quality, "jewel_ui")
	--LuaBehaviourUtil.setImg(luaBehaviour, "card_top_img", "gacha_back_quality" .. quality, "jewel_ui")
end

function M:openCard(index)
	if self.cards_node == nil then
		return
	end
	local obj = self.cards_node[index]
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_node", true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_top_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", true)
	local reward = self.m_model.m_cards[index]
	local card_btn = luaBehaviour:FindButton("card_btn")
	card_btn.interactable = false
	local card_node = luaBehaviour:FindGameObject("card_node")
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(card_node.transform:DOScale(Vector3(0, 1, 1), 0.1))
	sequence:Append(card_node.transform:DOScale(Vector3(1, 1, 1), 0.1))
	sequence:AppendInterval(0.8)
	local is_chip = self.m_model:isJewelChip(reward)
	if is_chip == false then
		return
	end
	sequence:Append(card_node.transform:DOScale(Vector3(0, 1, 1), 0.1))
	sequence:Append(card_node.transform:DOScale(Vector3(1, 1, 1), 0.1))
	--[[local function endCallFunc()
		local is_chip = self.m_model:isJewelChip(reward)
		if is_chip == true then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_img", true)
		else
				self:updateMsg("show_new")
		end
	end]]--
	local function endCallFunc()
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_img", true)
	end
	sequence:OnComplete(endCallFunc)
end

function M:openAllCard()
	for i = 1, #self.m_model.m_cards do
		if self.m_model:cardIsOpen(i) ~= true then
			self:openCard(i)
			self.m_model:openCard(i)
		end
	end
	self.oneKey_btn:SetActive(false)
	self:setObjectVisible("btn_node", true)
end

function M:setAllCardBtn(flag)
	if self.cards_node then
		for i,v in ipairs(self.cards_node) do
			local luaBehaviour = v:GetComponent("LuaBehaviour")
			local card_btn = luaBehaviour:FindButton("card_btn")
			card_btn.interactable = flag or true
		end
	end
end

function M:showZiCardEffect(index)
	if self.cards_node then
		--local luaBehaviour = self.cards_node[index]:GetComponent("LuaBehaviour")
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_ChouKa_Card_003", true)
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