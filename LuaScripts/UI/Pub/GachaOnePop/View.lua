local M = class("GachaOnePopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/GachaOnePop"
M.m_size_type = 2

--local card_bei_table = {"a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei"}
function M:onEnter()
	self:setObjectVisible("UI_Pub_ZhenZK_01", false)
	if self.m_model.m_type_index == 1 then
		self:setTextByLanKey("close_title_text", "Pub_str_0009")
	elseif self.m_model.m_type_index == 2 then
		self:setTextByLanKey("close_title_text", "Pub_str_0010")
	elseif self.m_model.m_type_index == 3 then
		self:setTextByLanKey("close_title_text", "Pub_str_0011")
	elseif self.m_model.m_type_index == 5 then
		self:setTextByLanKey("close_title_text", "Pub_str_0053")
	end
	
	self:setTextByLanKey("gacha_btn_text", "Pub_str_0026")
	self:setTextByLanKey("oneKey_btn_text", "Pub_str_0024")
	EventDispatcher:registerTimeEvent("kaPaiIn", function()
		audio:SendEvtUI("gacha_in")
	end ,0.3, 0.3)
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 5})
	self.big_close_btn = self:findGameObject("big_close_btn")
	self.card_panel = self:findGameObject("card_panel")
	self.big_close_btn:SetActive(false)
	--self.card_panel:SetActive(false)
	self.hero_spine = self:findGameObject("hero_spine")
	self.item_img = self:findGameObject("item_img")
	self.hero_img = self:findGameObject("hero_img")
	self.gacha_btn = self:findGameObject("gacha_btn")
	self.card_top_img = self:findGameObject("card_top_img")
	self.card_bg_img = self:findGameObject("card_bg_img")
	self.card_kuang_img = self:findGameObject("card_kuang_img")
	self.card_btn = self:findGameObject("card_btn")
	self.card_node = self:findGameObject("card_node")
	self.card_spine = self:findGameObject("card_spine")
	self.card_spine:SetActive(false)
	self.oneKey_btn = self:findGameObject("oneKey_btn")
	self.oneKey_btn:SetActive(false)

	self.card_bg_img:SetActive(false)
	self.card_kuang_img:SetActive(false)
	self.card_top_img:SetActive(false)

	--local function comeincall(msg)
	--	if msg == "come_in" then
	--		local function complete()
	--			self.card_panel:SetActive(true)
	--			self.oneKey_btn:SetActive(true)
	--		end
	--		self.card_spine:SetActive(true)
	--		local animation = self.card_spine:GetComponent("SkeletonGraphic")
	--		self:addSpineComplete(animation.AnimationState,complete)
	--		animation.AnimationState:SetAnimation(0, "animation_1", false)
	--	end
	--end
	--LuaBehaviourUtil.addAnimEvent(self.m_luaBehaviour, comeincall)
	
	local sequence = Tweening.DOTween.Sequence()
	sequence:AppendInterval(0.5)
	sequence:OnComplete(function()
		self:setObjectVisible("UI_ChouKa_Card_002", true)
		self.oneKey_btn:SetActive(true)
	end)
	sequence:SetAutoKill(true)

	local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_pool_id]
	self.gacha_times = 0
	local cost = gacha.cost
	local subscribe = UserDataManager:hasGachaSubscribe()
	if subscribe then
		cost = gacha.special_cost
	end
	self:setObjectVisible("subscribe_img", false)
	for i,v in ipairs(cost or {}) do
		local itemData = RewardUtil:getProcessRewardData(v)
		if itemData.user_num >= itemData.data_num then
			UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
			UIUtil.setText(self.gacha_btn.transform, itemData.data_num, "Image/Text")
			UIUtil.setTextColor(self.gacha_btn.transform, Color(255/255,255/255,255/255,1), "Image/Text")
			self.gacha_times = 1
			if itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				self:setObjectVisible("subscribe_img", subscribe and self.m_model.m_type_index == 2)
			end
			break
		else
			if i == #gacha.cost then
				UIUtil.setImg(self.gacha_btn.transform, itemData.icon_name, "item_icon", "Image/Image")
				UIUtil.setText(self.gacha_btn.transform, itemData.data_num, "Image/Text")
				UIUtil.setTextColor(self.gacha_btn.transform, Color(183/255,65/255,65/255,1), "Image/Text")
				self:setObjectVisible("subscribe_img", subscribe and self.m_model.m_type_index == 2)
			end
		end
	end
	self.gacha_btn:SetActive(false)
	self:setParticleRenderOrder(self.content_node)
	self:refreshUI()
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
	
function M:refreshUI()
	local card = self.m_model.m_card
	self.card_top_img:SetActive(true)
	local card_str_name = "a_ui_currency_ws_TY_kabei"
	--local card_str_name =  card_bei_table[self.m_model.m_pool_id]
	self:setObjectVisible("xia_img", false)
	self:setObjectVisible("zi_wenli", false)
	if card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
		self.hero_img:SetActive(true)
		self.hero_spine:SetActive(false)
		self.item_img:SetActive(false)
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[card[2]]
		if cfg == nil then
			Logger.logError(card, "card cfg is nil : ")
			GameUtil:sendLuaError("Gacha card cfg is nil :card[1] =  " .. card[1] .. "card[2] = " .. card[2])
		end
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		if hero_cfg == nil then
			Logger.logError(cfg, "hero cfg is nil : ")
			GameUtil:sendLuaError("Gacha hero cfg is nil :hero_id =  " .. cfg.hero_id)
		end
		if cfg.hero_evo < 3 then -- 绿
			local card_bg_img = self:findGameObject("card_bg_img")
			GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_green")
			local card_kuang_img = self:findGameObject("card_kuang_img")
			GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_green_shang")
		elseif cfg.hero_evo > 4 then -- 紫
			local card_bg_img = self:findGameObject("card_bg_img")
			GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_zi")
			local card_kuang_img = self:findGameObject("card_kuang_img")
			GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_zi_shang")
			card_str_name = "a_ui_currency_ws_TY_kabei_zzk"
			self:setObjectVisible("UI_Pub_ZhenZK_01", true)
			self:setObjectVisible("zi_wenli", true)
			if hero_cfg and hero_cfg.evo > 4 then --真紫
				self:setObjectVisible("xia_img", true)
			end
		else -- 蓝
			local card_bg_img = self:findGameObject("card_bg_img")
			GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/a_ck_pinjie_lan")
			local card_kuang_img = self:findGameObject("card_kuang_img")
			GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/a_ck_pinjie_lan_shang")
		end

		local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
        if race_data then
            self:setImg(race_data.race_icon,  ResourceUtil:getLanAtlas(), "emblem_img")
        end
        -- self:setText("martial_text", string.cutTextForString(Language:getTextByKey(hero_cfg.name)))
        self:setText("martial_text", Language:getTextByKey(hero_cfg.name))

		-- self:initSpine(cfg)
		local icon_name = "h_"..hero_cfg.icon.."_j"
		local hero_img = self:findGameObject("hero_img")
		GameUtil:updateResourcesImg(hero_img, "Texture/pub_tex/"..icon_name)
		--self:setTexture("hero_img", "HeroIcon/"..icon_name, "heroicon_"..icon_name)
	else
		self.hero_img:SetActive(false)
		self.hero_spine:SetActive(false)
		self.item_img:SetActive(true)
		--self:setImg("ck_z_daoju", "pub_ui", "card_bg_img")
		GameUtil:updateResourcesImg(self.card_bg_img, "Texture/pub_tex/a_ck_pinjie_green")
		self.card_bg_img:GetComponent("Image"):SetNativeSize()
		local itemData = RewardUtil:getProcessRewardData(card)
		self:setImg(itemData.icon_name, "item_icon", "item_img")
		UIUtil.setText(self.item_img.transform, itemData.data_num, "Text")
		self.card_kuang_img:SetActive(false)
	end
	GameUtil:updateResourcesImg(self.card_top_img, "Texture/pub_tex/" .. card_str_name)
	self.card_top_img:GetComponent("Image"):SetNativeSize()
end

function M:initSpine(card)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local hero = hero_detail[card.hero_id]
	local name = hero.hero_spine
	local pos = self.hero_spine.transform.localPosition
	pos.x = hero.show_position[1] or 0
	pos.y = hero.show_position[2] or -210
	self.hero_spine.transform.localPosition = pos
 	local sg = self.hero_spine:GetComponent("SkeletonGraphic")
	if name == "hero_0005_SkeletonData" then
		name = "hero_0006_SkeletonData"
	end
	local sk = ResourceUtil:GetSk(name, "rolespine_"..string.lower(name));
	sg.skeletonDataAsset = sk
	sg:Initialize(true)
	if card.hero_evo > 4 then
		sg.AnimationState:SetAnimation(0, "idle", true)
	else
		sg.AnimationState:SetAnimation(0, "pose", true)
	end
end

function M:openCard()
	-- self:setImg("ck_kabian", "pub_ui", "card_kuang_img")
	-- local function complete()
	-- 	self.card_spine:SetActive(false)
	-- end
	if self.card_spine then
		self.card_spine:SetActive(false)
	end
	-- local animation = self.card_spine:GetComponent("SkeletonGraphic")
	-- self:addSpineComplete(animation.AnimationState,complete)
	-- animation.AnimationState:SetAnimation(0, "animation_2", false)
	self.card_bg_img:SetActive(false)
	self.card_btn:SetActive(false)
	self.card_kuang_img:SetActive(false)
	self.card_top_img:SetActive(false)
	self.oneKey_btn:SetActive(false)
	self.card_node:SetActive(false)
	self:setObjectVisible("zi_wenli", false)
	self:setObjectVisible("Fx_UI", false)
	self:setObjectVisible("Fx_UI_4006", false)
	local card_str_name = "a_ui_currency_ws_TY_kabei"
	--local card_str_name =  card_bei_table[self.m_model.m_pool_id]
	local card = self:findGameObject("card")
	local effect_name = nil
	local function showCard(msg)
		if msg == "open_card" then
			self.card_node:SetActive(true)
			self.card_panel:SetActive(true)
			self.card_bg_img:SetActive(true)
			self.card_btn:SetActive(true)
			self.card_btn:GetComponent("Button").interactable = false
			self.card_kuang_img:SetActive(self.m_model.m_card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT)

			if effect_name then
				self:setObjectVisible(effect_name, true)
			end
		elseif msg == "show_new" then
			self:updateMsg("show_new")
		elseif msg == "open_end" then
			--self.big_close_btn:SetActive(true)
			self.gacha_btn:SetActive(self.m_model.m_type_index ~= 5) --积分招募不再显示继续招募按钮
			self.card_btn:GetComponent("Button").interactable = true
		end
	end
	local animation_name = ""
	if self.m_model.m_card[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[self.m_model.m_card[2]]
		if cfg.hero_evo < 3 then
			animation_name = "GachaOnePop_Green"
			audio:SendEvtUI("flip_blue")
		elseif cfg.hero_evo > 4 then
			animation_name = "GachaOnePop_Purple"
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
			if hero_cfg and hero_cfg.Ex_hero == 1 then
				effect_name = "UI_Pub_T0_001"
			else
				effect_name = "UI_Pub_ZiKa_001"
			end
			audio:SendEvtUI("flip_purple")
			card_str_name = "a_ui_currency_ws_TY_kabei_zzk"
			self:setObjectVisible("zi_wenli", true)
		else
			animation_name = "GachaOnePop_Blue"
			effect_name = "UI_Pub_LanKa_001"
			audio:SendEvtUI("flip_blue")
		end
	else
		animation_name = "GachaOnePop_Green"
		audio:SendEvtUI("flip_blue")
	end
	local open_effect = ResourceUtil:LoadUIGameObject("Pub/" .. animation_name, Vector3.zero,nil)
	open_effect.transform:SetParent(card.transform, false)
	UIUtil.setScale(open_effect.transform, 1,1)
	self:setParticleRenderOrder(open_effect)
	local luabehaviour = open_effect:GetComponent("LuaBehaviour")
	if luabehaviour and animation_name == "GachaOnePop_Purple" then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[self.m_model.m_card[2]]
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		if hero_cfg and hero_cfg.Ex_hero == 1 then 
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_004", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_003", true)
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_002", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_001", false)
		else
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_004", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_003", false)
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_002", true)	
			LuaBehaviourUtil.setObjectVisible(luabehaviour, "UI_ChouKa_Card_Star_001", true)	
		end
	end
	local card_top_img = luabehaviour:FindGameObject("card_top_img")
	GameUtil:updateResourcesImg(card_top_img, "Texture/pub_tex/" .. card_str_name)
	card_top_img:GetComponent("Image"):SetNativeSize()
	luabehaviour:RunAnim(animation_name, showCard)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	EventDispatcher:unRegisterEvent("kaPaiIn")
    M.super.destroy(self)
end

return M