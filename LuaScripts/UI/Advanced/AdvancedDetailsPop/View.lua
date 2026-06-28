local M = class("AdvancedDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "Advanced/AdvancedDetailsPop"
M.m_size_type = 2

local attrs = {"combat", "maxLv", "hp", "atk", "def", "morale"}
function M:onEnter()
	self:setTextByLanKey("common_title_text", "advanced_str_0008")
	self:setTextByLanKey("yes_text", "new_str_0315")
	self:setText("cost_text", Language:getTextByKey("advanced_str_0001"))
	self:setObjectVisible("count_text", false)
	if self.m_model.m_islink == true then
		if self.m_model.m_link_type == 2 then
			self:setTextByLanKey("common_title_text", "结义加深")
			self:setText("cost_text", Language:getTextByKey("结义消耗"))
		elseif self.m_model.m_link_type == 3 then
			self:setTextByLanKey("common_title_text", "结义解除")
			self:setText("cost_text", Language:getTextByKey("资源返还"))
		elseif self.m_model.m_link_type == 1 then
			self:setTextByLanKey("common_title_text", "结义")
			self:setText("cost_text", "")
			self:setObjectVisible("count_text", true)
		end
	end
	self.hero_prefab = self:findGameObject("hero_prefab")
	self.hero_new_prefab = self:findGameObject("hero_new_prefab")
	self.cost_panel = self:findGameObject("cost_panel")
	self.attrs_node = {}
	for i,v in ipairs(attrs) do
		self.attrs_node[v] = self:findGameObject("attrs_" .. v)
	end
	self:refreshUI()	
end

function M:refreshUI()
	local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
	local new_hero = table.copy(hero)
	new_hero.evo = new_hero.evo + 1
	if self.m_model.m_islink == true then
		new_hero.evo = self.m_model:getLinkNextLv()
	end
	local evoData = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero.evo]
	self:setImg(evoData.icon, "common_ui", "evo_image")
	evoData = GlobalConfig.HERO_QUALITY_COMMON_SETTING[new_hero.evo]
	self:setImg(evoData.icon, "common_ui", "evo_new_image")

	GameUtil:updateHeroContentByData(self.hero_prefab, hero, cfg)
	GameUtil:updateHeroContentByData(self.hero_new_prefab, new_hero, cfg)
	for i,v in ipairs(self.m_model.m_martial) do
		local itemData = nil
		if self.m_model.m_islink == true and self.m_model.m_link_type == 2 then
			itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, self.m_model.hero_cid, 1})
		elseif self.m_model.m_islink == true and self.m_model.m_link_type == 3 then
			itemData =  RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, v, 1})
		else
			local hero = UserDataManager.hero_data:getHeroDataById(v)
			itemData =  RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 1, hero.oid})
			itemData.data_num = 0
		end
		local icon, ui_element = GameUtil:createItemElementByData(itemData)--CommonUIUtil:createHeroElementByData(itemData)
		icon.transform:SetParent(self.cost_panel.transform, false)
		-- UIUtil.setScale(icon.transform, 0.64)
		local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(v)
		if v == 0 then
			local num_text = LuaBehaviourUtil.setTextByLanKey(ui_element.luaBehaviour, "lv_text", "1/0")	
			LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour, "lv_text", true)
			num_text.color = Color.New(243/255, 53/255, 53/255)
		end
		if hero_skin_cfg and next(hero_skin_cfg) ~= nil then
			LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")	
		end
	end
	if self.m_model.need_universal_num and self.m_model.need_universal_num > 0 and self.m_model.m_universal_id then
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_model.m_universal_id, self.m_model.need_universal_num})
		local icon, ui_element = GameUtil:createItemElementByData(itemData, true, true)
		icon.transform:SetParent(self.cost_panel.transform, false)
	end
	local attrs = UserDataManager:getHeroAttrsById(hero.oid)
	local new_attrs = UserDataManager:computeHeroAttrsClient(new_hero)
	new_hero.attrs = new_attrs
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	attrs.combat = UserDataManager:computeHeroCombat(hero,nil,nil,nil,nil,true) --
	attrs.maxLv = hero_evolution[hero.evo].level_max
	new_attrs = UserDataManager:getHeroAttrsByData(new_hero, cfg, true, nil,nil,true)
	new_attrs.combat =  UserDataManager:computeHeroCombat(new_hero,nil,nil,nil,nil,true)
	new_attrs.maxLv = hero_evolution[new_hero.evo].level_max

	for k,v in pairs(self.attrs_node) do
		UIUtil.setText(v.transform, GameUtil:formatValueToString(math.floor(attrs[k]+ 0.5)) , "value_text")
		UIUtil.setText(v.transform, GameUtil:formatValueToString(math.floor(new_attrs[k] + 0.5)), "value_new_text")
		if k ~= "combat" then
			if k == "maxLv" then
				UIUtil.setText(v.transform, Language:getTextByKey("advanced_str_0002"), "name_text")
				UIUtil.setText(v.transform, Language:getTextByKey("advanced_str_0002"), "name_new_text")
			else
				local name = GameUtil:getAttrsName(k)
				UIUtil.setText(v.transform, name, "name_text")
				UIUtil.setText(v.transform, name, "name_new_text")
			end
		else
			UIUtil.setText(v.transform, Language:getTextByKey("new_str_0490"), "name_text")
			UIUtil.setText(v.transform, Language:getTextByKey("new_str_0490"), "name_new_text")
		end
	end

	UIUtil.setText(self:findGameObject("evo_image").transform, Language:getTextByKey("hero_evolution" .. hero.evo), "Text")
	UIUtil.setText(self:findGameObject("evo_new_image").transform, Language:getTextByKey("hero_evolution" .. new_hero.evo), "Text")
end

return M