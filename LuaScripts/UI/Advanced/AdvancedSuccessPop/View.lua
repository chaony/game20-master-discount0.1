local M = class("AdvancedSuccessPopView",LikeOO.OOPopBase)

M.m_uiName = "Advanced/AdvancedSuccessPop2"
M.m_size_type = 2

local attrs = {"combat", "maxLv", "hp", "atk", "def", "morale"}
function M:onEnter()
	self.cost_panel = self:findGameObject("cost_panel")
	self.hero_prefab = self:findGameObject("hero_prefab")
	self.hero_new_prefab = self:findGameObject("hero_new_prefab")
	self.hero_sk = self:findGameObject("hero_sk")
	self.attrs_node = {}
	for i,v in ipairs(attrs) do
		self.attrs_node[v] = self:findGameObject("attrs_" .. v)
	end
	self:refreshUI()
end

function M:refreshUI()
	local new_hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
	local hero = table.copy(new_hero)
	self:setObjectVisible("reward_scroll_view", false)
	hero.evo = hero.evo - 1
	if self.m_model:isLink() == true then
		hero.evo = self.m_model:getLastLinkEvo()
		if self.m_model:linkType() == 3 then
			self.m_control:setOnceTimer(2, function ()
				self:setObjectVisible("reward_scroll_view", true)
			end)
			self:updateMartial()
		end
	end
	local itemNewData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, new_hero.id, 1, new_hero.oid})
	GameUtil:updateHeroContentByData(self.hero_new_prefab, new_hero, cfg)
	local itemData = table.copy(itemNewData)
	itemData.quality = itemData.quality - 1
	GameUtil:updateHeroContentByData(self.hero_prefab, hero, cfg)

	local new_attrs = UserDataManager:getHeroAttrsById(new_hero.oid)
	local attrs = UserDataManager:computeHeroAttrsClient(hero)
	hero.attrs = attrs
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	new_attrs.combat = UserDataManager:computeHeroCombat(new_hero,nil,nil,nil,nil, true) --.combat
	new_attrs.maxLv = hero_evolution[new_hero.evo].level_max
	attrs.combat =  UserDataManager:computeHeroCombat(hero,nil,nil,nil,nil, true)
	attrs.maxLv = hero_evolution[hero.evo].level_max
	attrs = UserDataManager:getHeroAttrsByData(hero, cfg, true, nil,nil,true)

	for k,v in pairs(self.attrs_node) do
		UIUtil.setText(v.transform, GameUtil:formatValueToString(math.floor(attrs[k]+ 0.5)) , "value_text")
		UIUtil.setText(v.transform, GameUtil:formatValueToString(math.floor(new_attrs[k] + 0.5)), "value_new_text")
		if k ~= "combat" then
			if k == "maxLv" then
				UIUtil.setText(v.transform, Language:getTextByKey("advanced_str_0002"), "name_text")
			else
				local name = GameUtil:getAttrsName(k)
				UIUtil.setText(v.transform, name, "name_text")
			end
		else
			UIUtil.setText(v.transform, Language:getTextByKey("new_str_0490"), "name_text")
		end
	end
	UIUtil.setText(self:findGameObject("evo_image").transform, Language:getTextByKey("hero_evolution" .. new_hero.evo), "Text")

	self:setTextByLanKey("main_title_text", cfg.name )
	local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
	self:setImg(race, ResourceUtil:getLanAtlas(), "camp_img_btn")
	local quality = new_hero.evo or 0
	--local frameData = GlobalConfig.QUALITY_FRAME[quality] or GlobalConfig.QUALITY_FRAME[1]
	self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,quality), "common_ui", "name_quality_bg_img")
	
	local poetry = string.gsub(Language:getTextByKey(cfg.poetry), "\\n", "\n")
	local poe =  string.split(poetry,"\n")
	for i,v in ipairs(poe) do
		self:setText("poetry_text_" .. i, v)
	end
	
	--屏蔽经脉展示
	self:setObjectVisible("channel",false)
	-- 武器解锁
	self:setObjectVisible("equip",false)
end

function M:updateMartial()
	for i,v in ipairs(self.m_model.m_martial) do
		local itemData =  RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, v, 1})
		local icon, ui_element = CommonUIUtil:createHeroElementByData(itemData)
		icon.transform:SetParent(self.cost_panel.transform, false)
		UIUtil.setScale(icon.transform, 0.6)
		LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour, "lv_text", false)
	end
end


function M:setSpine()
	local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
	local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero, cfg)
 	local sg = self.hero_sk:GetComponent("SkeletonGraphic")
	local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
	GameUtil:updateSpineLoadSet(self.hero_sk, "RoleSpine/"..spine, "idle", 0, true)
end

return M