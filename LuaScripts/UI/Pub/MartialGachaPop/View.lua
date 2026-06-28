local M = class("MartialGachaPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/MartialGachaPop"
M.m_size_type = 2

local card_bei_table = {"a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei","a_ui_currency_ws_TY_kabei"}
function M:onEnter()
	self.vedio = self:findGameObject("vedio")
	local video_control = self.vedio:GetComponent("VideoControl")
	local full_path,file_type = io.fileFullPath("mp4/xh_05.mp4")
	if full_path then
		video_control:VideoPlay(file_type,"mp4/xh_05.mp4",true,0);
	end
	
	-- self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
	self.card_panel = self:findGameObject("card_panel")
	self:setTextByLanKey("pop_tips_text", "Pub_str_0031")
	for i=1,4 do
		--self:setTexture(string.format("card%d_bg_img", i), "HeroIcon/a_ui_zi_di", "heroicon_a_ui_zi_di")
		--self:setTexture(string.format("card%d_kuang_img", i), "HeroIcon/a_ui_zi", "heroicon_a_ui_zi")
	end
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_card then
		for i=1,4 do
			local btn = self:findButton(string.format("card_btn_%d", i))
			btn.interactable = false
			--self:setTexture(string.format("card%d_bg_img", i), "HeroIcon/a_ui_zi_di", "heroicon_a_ui_zi_di")
			--self:setTexture(string.format("card%d_kuang_img", i), "HeroIcon/a_ui_zi", "heroicon_a_ui_zi")
			local card = self:findGameObject("card_" .. i)
			local luabehaviour = card:GetComponent("LuaBehaviour")
			if i == self.m_model.m_gacha_id then
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_top_img", false)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_bg_img", false)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_spine", false)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"item_img", false)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", false)
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_img", false)
				--self:setObjectVisible(string.format("card%d_top_img", i), false)
				--self:setObjectVisible(string.format("card%d_bg_img", i), false)
				--self:setObjectVisible(string.format("hero%d_spine", i), false)
				--self:setObjectVisible(string.format("item%d_img", i), false)
				--self:setObjectVisible(string.format("card%d_kuang_img", i), false)
				--self:setObjectVisible(string.format("hero_img_%d", i), false)

				local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
				local card_id = self.m_model.m_card[2]
				local cfg = card_hero_cfg[card_id]
				local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)

				-- self:setImg("ck_z_kadi_zi", "pub_ui", string.format("card%d_bg_img", i))
				-- self:setImg("ck_z_zikaming_di", "pub_ui", string.format("martial%d_bg_img", i))
				-- self:setImg("ck_z_zika", "pub_ui", string.format("card%d_kuang_img", i))

		        -- self:setText("martial" .. i .. "_text", string.cutTextForString(Language:getTextByKey(hero_cfg.name)))
				LuaBehaviourUtil.setTextByLanKey(luabehaviour,"martial_text", hero_cfg.name)
				-- self:initSpine(i, cfg)

				local icon_name = "h_"..hero_cfg.icon.."_j"
				--self:setTexture("hero_img_" .. i, "HeroIcon/"..icon_name, "heroicon_"..icon_name)
				local hero_img = luabehaviour:FindGameObject("hero_img")
				GameUtil:updateResourcesImg(hero_img, "Texture/pub_tex/" .. icon_name)
				self:openCard(i)
			else
				LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_top_img", true)
			end
		end
	end
	
end

function M:initSpine(index, card)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local hero = hero_detail[card.hero_id]
	local name = hero.hero_spine
	local spine_obj = self:findGameObject(string.format("hero%d_spine", index))
	local pos = spine_obj.transform.localPosition
	pos.x = hero.show_position[1] or 0
	pos.y = hero.show_position[2] or -210
	spine_obj.transform.localPosition = pos
 	local sg = spine_obj:GetComponent("SkeletonGraphic")
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

function M:openCard(index)
	local card = self:findGameObject("card_" .. index)
	local function showCard()
		-- self:setObjectVisible(string.format("hero%d_spine", index), true)
		local luabehaviour = card:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_bg_img", true)
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"card_kuang_img", true)
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"hero_img", true)
		LuaBehaviourUtil.setObjectVisible(luabehaviour,"UI_Pub_ZiKa_001", true)
		local btn = self:findButton(string.format("card_btn_%d", index))
		btn.interactable = true
		self:updateMsg("show_new")
	end
	audio:SendEvtUI("flip_purple")
	
	local open_effect = ResourceUtil:LoadUIGameObject("Pub/GachaOnePop_Purple", Vector3.zero,nil)
	open_effect.transform:SetParent(card.transform, false)
	UIUtil.setScale(open_effect.transform, 1,1)
	self:setParticleRenderOrder(open_effect)
	local luabehaviour = open_effect:GetComponent("LuaBehaviour")
	local card_top_img = luabehaviour:FindGameObject("card_top_img")
	GameUtil:updateResourcesImg(card_top_img, "Texture/pub_tex/" .. card_bei_table[index])
	luabehaviour:RunAnim("GachaOnePop_Purple", showCard)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M