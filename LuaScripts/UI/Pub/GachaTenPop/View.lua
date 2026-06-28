---@class GachaTenPopView:OOPopBase
---@field m_model GachaTenPopModel
local M = class("GachaTenPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/GachaTenPop"
M.m_size_type = 1

--local card_bei_table = {"a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei"}
function M:onEnter()
	if self.m_model.m_type_index == 1 then
		self:setTextByLanKey("close_title_text", "Pub_str_0009")
	elseif self.m_model.m_type_index == 2 then
		self:setTextByLanKey("close_title_text", "Pub_str_0010")
	elseif self.m_model.m_type_index == 3 then
		self:setTextByLanKey("close_title_text", "Pub_str_0011")
	end
	self:setTextByLanKey("close_btn2_text", "new_str_0006")
	self:setTextByLanKey("gacha_btn_text", "Pub_str_0026")
	self:setTextByLanKey("oneKey_btn_text", "Pub_str_0024")
	self.open_end = 0
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 5})
	self.cards_node = {}
	
	for i=1,10 do
		if i <= self.m_model.m_card_count then
			self.cards_node[i] = self:findGameObject("card" .. i)
			 local luabehaviour = self.cards_node[i]:GetComponent("LuaBehaviour")
			-- LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_ChouKa_Card_002", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_ChouKa_Card_003", false)
		else
			self:setObjectVisible("card" .. i, false)	
		end
	end

	self.oneKey_btn = self:findGameObject("oneKey_btn")
	self.gacha_btn = self:findGameObject("gacha_btn")
	self.close_btn2 = self:findGameObject("close_btn2")
	self.big_close_btn = self:findGameObject("big_close_btn")
	self.big_close_btn:SetActive(false)

	local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_pool_id]
	self.gacha_times = 0
	local ten_cost = gacha.ten_cost
	local subscribe = UserDataManager:hasGachaSubscribe()
	if subscribe then
		ten_cost = gacha.special_ten_cost
	end
	self:setObjectVisible("subscribe_img", false)
	for i,v in ipairs(ten_cost or {}) do
		local itemData = RewardUtil:getProcessRewardData(v)
		if itemData.user_num >= itemData.data_num then
			UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
			UIUtil.setText(self.gacha_btn.transform, itemData.data_num, "Image/Text")
			--self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
			self.gacha_times = 10
			if itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				self:setObjectVisible("subscribe_img", subscribe and self.m_model.m_type_index == 2)
			end
			break
		else
			if self.m_model.m_type_index == 1 then
				local min_count = gacha.limit or 10
				local once_cost = gacha.cost_item[1][3]
				if itemData.user_num >= min_count*once_cost and itemData.user_num > 0  then
					local times = math.floor(itemData.user_num/once_cost)
					UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.gacha_btn.transform, math.floor(times*once_cost), "Image/Text")
					--self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", times)
					self.gacha_times = times
					break
				end
			elseif self.m_model.m_type_index == 2 and itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				local min_count = gacha.limit or 10
				if itemData.user_num >= min_count and itemData.user_num > 0  then
					UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.gacha_btn.transform, "<color=#F33535>" .. itemData.user_num .. "</color>", "Image/Text")
					--self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
					self.gacha_times = itemData.user_num
					break
				end
			elseif self.m_model.m_type_index == 3 then
				local min_count = gacha.limit or 10
				if itemData.user_num >= min_count and itemData.user_num > 0  then
					UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
					UIUtil.setText(self.gacha_btn.transform, "<color=#F33535>" .. itemData.user_num .. "</color>", "Image/Text")
					--self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", itemData.user_num)
					self.gacha_times = itemData.user_num
					break
				end
			end
			if i == #gacha.cost then
				UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
				UIUtil.setText(self.gacha_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "Image/Text")
				--self:setTextByLanKey("ten_gacha_btn_text", "Pub_str_0027", 10)
				self:setObjectVisible("subscribe_img", subscribe and self.m_model.m_type_index == 2)
			end
		end
	end

    --local cards_panel = self:findGameObject("cards_panel")
    --local rect = self.content_node:GetComponent("RectTransform").rect
    --local scale = math.min(rect.width/1280, rect.height/720)
    --UIUtil.setLocalScale(cards_panel.transform, scale, scale, scale)

 --    

	self:initUI()
	self.oneKey_btn:SetActive(false)
	self.gacha_btn:SetActive(false)
	self.close_btn2:SetActive(false)
	--local function delayTime()
		self:updateUI()
	--end
	--self.m_control:setOnceTimer(1.5, delayTime)
	self:lockTouch()
	self.m_control:setOnceTimer(1, function()
		self:unlockTouch()
	end)
	
	self:playVedio()
end

function M:playVedio()
	local function vedio_paly()
		self.vedio = self:findGameObject("vedio")
		local video_control = self.vedio:GetComponent("VideoControl")
		local full_path,file_type = io.fileFullPath("mp4/xh_05.mp4")
		if full_path then
			video_control:VideoPlay(file_type,"mp4/xh_05.mp4",true,0);
		end
	end
	local state, err = pcall(vedio_paly)
	if not state then
		Logger.logErrorAlways(err," GachaTenPop view vedio error: ")
	end
end

function M:initUI()
	audio:SendEvtUI("licensing")
	-- local function cardCallback(obj,index)
	-- 	self:openCard(index)
	-- end
	if self.cards_node == nil then
		return
	end
	for i=1,#self.cards_node do
		local card = self.m_model.m_cards[i]
		local luabehaviour = self.cards_node[i]:GetComponent("LuaBehaviour")
		local card_str_name = "a_ui_currency_ws_TY_kabei"
		--local card_str_name =  card_bei_table[self.m_model.m_pool_id]
		if card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_img", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_spine", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"item_img", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"xia_img", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"zi_wenli", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_ZhenZK_01", false)
			local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
			local card_id = card[2]
			local cfg = card_hero_cfg[card_id]
			if cfg == nil then
				Logger.logError(card, "card cfg is nil : ")
				GameUtil:sendLuaError("Gacha card cfg is nil :card[1] =  " .. card[1] .. "card[2] = " .. card[2])
			end
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
			if hero_cfg == nil then
				Logger.logError(cfg, "hero cfg is nil : ")
				GameUtil:sendLuaError("Gacha hero cfg is nil :hero_id =  " .. cfg.hero_id)
			end
			local card_bg_img = luabehaviour:FindGameObject("card_bg_img")
			local card_kuang_img = luabehaviour:FindGameObject("card_kuang_img")
			if cfg.hero_evo < 3 then -- 绿
				-- self:setImg("ck_z_daoju", "pub_ui", "card" .. i .. "_bg_img")
				-- self:setImg("ck_z_lvkadi_lan", "pub_ui", "card" .. i .. "_bg_img")
				-- self:setImg("ck_z_lvka", "pub_ui", "card" .. i .. "_kuang_img")
				-- self:setImg("ck_z_lvkaming_di", "pub_ui", "martial" .. i .. "_bg_img")
				GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_green")
				GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_green_shang")
			elseif cfg.hero_evo > 4 then -- 紫
				-- self:setImg("ck_z_kadi_zi", "pub_ui", "card" .. i .. "_bg_img")
				-- self:setImg("ck_z_zika", "pub_ui", "card" .. i .. "_kuang_img")
				-- self:setImg("ck_z_zikaming_di", "pub_ui", "martial" .. i .. "_bg_img")
				card_str_name = "a_ui_currency_ws_TY_kabei_zzk"
				GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_zi")
				GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_zi_shang")
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"zi_wenli", true)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_ZhenZK_01", true)
			else -- 蓝
				-- self:setImg("ck_z_kadi_lan", "pub_ui", "card" .. i .. "_bg_img")
				-- self:setImg("ck_z_lanka", "pub_ui", "card" .. i .. "_kuang_img")
				-- self:setImg("ck_z_lankaming_di", "pub_ui", "martial" .. i .. "_bg_img")
				GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_lan")
				GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_lan_shang")
			end

			local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
	        if race_data then
				LuaBehaviourUtil.setImg(luabehaviour,"emblem_img",race_data.race_icon, "language_zh_cn")
	        end
	        -- self:setText("martial" .. i .. "_text", string.cutTextForString(Language:getTextByKey(hero_cfg.name)))
			LuaBehaviourUtil.setTextByLanKey(luabehaviour,"martial_text",hero_cfg.name)
			-- self:initSpine(i, cfg)
			
			local icon_name = "h_"..hero_cfg.icon.."_j"
			local hero_img = luabehaviour:FindGameObject("hero_img")
			GameUtil:updateResourcesImg(hero_img, "Texture/pub_tex/" .. icon_name)
			-- if hero_cfg and hero_cfg.evo > 4 then --真紫
			-- 	LuaBehaviourUtil.setObjectVisible(luabehaviour,"xia_img", true)
			-- end
		else
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_img", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_spine", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"item_img", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", false)
			local card_bg_img = luabehaviour:FindGameObject("card_bg_img")
			GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_green")
			card_bg_img:GetComponent("Image"):SetNativeSize()
			local itemData = RewardUtil:getProcessRewardData(card)
			LuaBehaviourUtil.setImg(luabehaviour,"item_icon",itemData.icon_name, "item_icon")
			LuaBehaviourUtil.setTextByLanKey(luabehaviour,"item_num_text",itemData.data_num)
		end
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_top_img", true)
		local card_top_img = luabehaviour:FindGameObject("card_top_img")
		local card_img = GameUtil:updateResourcesImg(card_top_img, "Texture/pub_tex/" ..card_str_name)
		card_top_img:GetComponent("Image"):SetNativeSize()
	end
end

function M:initSpine(index, card)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local hero = hero_detail[card.hero_id]
	local name = hero.hero_spine
	local obj = self.cards_spine[index]
	local pos = obj.transform.localPosition
	pos.x = hero.show_position[1] or 0
	pos.y = hero.show_position[2] or -210
	obj.transform.localPosition = pos
 	local sg = obj:GetComponent("SkeletonGraphic")
	if name == "hero_0005_SkeletonData" then
		name = "hero_0006_SkeletonData"
	end
	local sk = ResourceUtil:GetSk(name, "rolespine_"..string.lower(name))
	sg.skeletonDataAsset = sk
	sg:Initialize(true)
	if card.hero_evo > 4 then
		sg.AnimationState:SetAnimation(0, "idle", true)
	else
		sg.AnimationState:SetAnimation(0, "pose", true)
	end
end

function M:updateUI()
	if self.m_model:getCloseCard() then
		self.oneKey_btn:SetActive(true)
		self.gacha_btn:SetActive(false)
		self.close_btn2:SetActive(false)
		--self:setObjectVisible("share_node", false)
	else
		self.oneKey_btn:SetActive(false)
		self.gacha_btn:SetActive(true)
		self.close_btn2:SetActive(true)
		--if GameVersionConfig.BYTE_DANCE_SERVER_VERSION ~= "1.0.1" then -- 屏蔽不删档测试包
		--	self:setObjectVisible("share_node", true)
		--end
	end
end

function M:openCard(index)
	-- self:setImg("ck_kabian", "pub_ui", "card" .. index .. "_kuang_img")
	if self.cards_node == nil then
		return
	end
	local luabehaviour = self.cards_node[index]:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_node", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_bg_img", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_btn_" .. index, false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_top_img", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"xia_img", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_ChouKa_Card_003", false)
	LuaBehaviourUtil.setObjectVisible(luabehaviour,"zi_wenli", false)
	local card_str_name = "a_ui_currency_ws_TY_kabei"
	--local card_str_name =  card_bei_table[self.m_model.m_pool_id]
	local card = self.m_model.m_cards[index]
	local effect_name = nil
	local function showCard(msg)
		if msg == "open_card" then
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_node", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_bg_img", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_btn_" .. index, true)
			local card_btn = luabehaviour:FindButton("card_btn_" .. index)
			local zika_effect = luabehaviour:FindGameObject("zika_effect")
			
			local card_node = luabehaviour:FindGameObject("card_node")

			card_btn.interactable = false
			local is_new = self.m_model:checkIsNewCard(index)
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"new_img", is_new)
			if effect_name then
				LuaBehaviourUtil.setObjectVisible(luabehaviour,effect_name, true)
				if effect_name == "UI_Pub_ZiKa_001" or "UI_Pub_T0_001" then
					if effect_name == "UI_Pub_ZiKa_001" then
						LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_ZiKa_001", true)
						LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_T0_001", false)
					elseif	effect_name == "UI_Pub_T0_001" then
						LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_ZiKa_001", false)
						LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_T0_001", true)
					end
					LuaBehaviourUtil.setObjectVisible(luabehaviour,"zika_effect", true)
					local function endCallFunc()
						
        			end
					local sequence = Tweening.DOTween.Sequence() 
					sequence:Append(card_node.transform:DOScale(Vector3(1.1, 1.1, 1.1), 0.3))
					sequence:Join(zika_effect.transform:DOScale(Vector3(1.1, 1.1, 1.1), 0.5))
         	 		sequence:AppendInterval(0.5);--两个动画之间的延时
         	 		sequence:Append(card_node.transform:DOScale(Vector3(1, 1, 1), 0.1))
         	 		sequence:Join(zika_effect.transform:DOScale(Vector3(1, 1, 1), 0.1))
					sequence:OnComplete(endCallFunc)
				end
			end
		elseif msg == "show_new" then
			self:updateMsg("show_new")
		elseif msg == "open_end" then
			local card_btn = luabehaviour:FindButton("card_btn_" .. index)
			card_btn.interactable = true
			self.open_end = self.open_end + 1
			if self.m_model.m_pool_id ~= 1 and self.open_end >= 10 then
				--self.big_close_btn:SetActive(true)
				self:updateUI()
			else
				self:updateUI()
			end
		end
	end
	
	local animation_name = nil
	if card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[card[2]]
		if cfg.hero_evo < 3 then
			animation_name = "GachaOnePop_Green"
			audio:SendEvtUI("flip_blue", true)
		elseif cfg.hero_evo > 4 then
			animation_name = "GachaOnePop_Purple"
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
			if hero_cfg and hero_cfg.Ex_hero == 1 then
				effect_name = "UI_Pub_T0_001"
			else
				effect_name = "UI_Pub_ZiKa_001"
			end
			card_str_name = "a_ui_currency_ws_TY_kabei_zzk"
			if hero_cfg and hero_cfg.evo > 4 then --真紫
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"xia_img", true)
			end
			LuaBehaviourUtil.setObjectVisible(luabehaviour,"zi_wenli", true)
			audio:SendEvtUI("flip_purple", true)
		else
			animation_name = "GachaOnePop_Blue"
			effect_name = "UI_Pub_LanKa_001"
			audio:SendEvtUI("flip_blue", true)
		end

	else
		animation_name = "GachaOnePop_Green"
		audio:SendEvtUI("flip_blue", true)
	end
	
	local open_effect = ResourceUtil:LoadUIGameObject("Pub/" .. animation_name, Vector3.zero,nil)
	open_effect.transform:SetParent(self.cards_node[index].transform, false)
	UIUtil.setScale(open_effect.transform, 1,1)
	self:setParticleRenderOrder(open_effect)
	local effect_luabehaviour = open_effect:GetComponent("LuaBehaviour")
	if effect_luabehaviour and animation_name == "GachaOnePop_Purple" then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[card[2]]
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		if hero_cfg and hero_cfg.Ex_hero == 1 then 
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_004", true)
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_003", true)
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_002", false)
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_001", false)
		else
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_004", false)
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_003", false)
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_002", true)	
			LuaBehaviourUtil.setObjectVisible(effect_luabehaviour, "UI_ChouKa_Card_Star_001", true)	
		end
	end
	local card_top_img = effect_luabehaviour:FindGameObject("card_top_img")
	GameUtil:updateResourcesImg(card_top_img, "Texture/pub_tex/" ..card_str_name)
	card_top_img:GetComponent("Image"):SetNativeSize()
	effect_luabehaviour:RunAnim(animation_name, showCard)
end

function M:openAllCard()
	for i=1,self.m_model.m_card_count do
		-- self:setImg("ck_kabian", "pub_ui", "card" .. i .. "_kuang_img")
		-- self.cards_top[i]:SetActive(false)
		if self.m_model:cardIsOpen(i) ~= true then
			self:openCard(i)
			self.m_model:openCard(i)
		end
	end
end

function M:setCardBtn(index, flag)
	local luabehaviour = self.cards_node[index]:GetComponent("LuaBehaviour")
	local card_btn = luabehaviour:FindButton("card_btn_" .. index)
	card_btn.interactable = flag or true
end

function M:setAllCardBtn(flag)
	if self.cards_node then
		for i,v in ipairs(self.cards_node) do
			local luabehaviour = v:GetComponent("LuaBehaviour")
			local card_btn = luabehaviour:FindButton("card_btn_" .. i)
			card_btn.interactable = flag or true
		end
	end
end

function M:showZiCardEffect(index)
	if self.cards_node then
		local luabehaviour = self.cards_node[index]:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_ChouKa_Card_003", true)
	end
end

function M:ShareShow(flag)
	--self:setObjectVisible("share_node", flag)
	self:setObjectVisible("gacha_btn", flag)
	self:setObjectVisible("close_btn2", flag)
	self:setObjectVisible("oneKey_btn_text", flag)
	self:setObjectVisible("CommonCloseNode", flag)
	self.m_attr_node:setVisible(flag)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M