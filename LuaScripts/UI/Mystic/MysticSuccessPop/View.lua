local M = class("AdvancedSuccessPopView",LikeOO.OOPopBase)

M.m_uiName = "Advanced/AdvancedSuccessPop"
M.m_size_type = 2

local attrs = {"combat", "maxLv", "hp", "atk", "def", "morale"}
function M:onEnter()
	self.hero_prefab = self:findGameObject("hero_prefab")
	self.hero_new_prefab = self:findGameObject("hero_new_prefab")
	self.attrs_node = {}
	for i,v in ipairs(attrs) do
		self.attrs_node[v] = self:findGameObject("attrs_" .. v)
	end
	self:refreshUI()
	self:setSpine()	
end

function M:refreshUI()
	local new_hero = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
	local hero = table.copy(new_hero)
	hero.evo = hero.evo - 1
	local itemNewData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, new_hero.id, 1, new_hero.oid})
	GameUtil:updateItemElementByData(self.hero_new_prefab, itemNewData, false, false)
	local itemData = table.copy(itemNewData)
	itemData.quality = itemData.quality - 1
	GameUtil:updateItemElementByData(self.hero_prefab, itemData, false, false)

	local new_attrs = UserDataManager:getHeroAttrsById(new_hero.oid)
	local attrs = UserDataManager:computeHeroAttrsClient(hero)
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	new_attrs.combat = new_hero.combat
	new_attrs.maxLv = hero_evolution[new_hero.evo].level_max
	attrs.combat =  UserDataManager:computeHeroCombat(new_hero)
	attrs.maxLv = hero_evolution[hero.evo].level_max
	for k,v in pairs(self.attrs_node) do
		UIUtil.setText(v.transform, attrs[k], "value_text")
		UIUtil.setText(v.transform, new_attrs[k], "value_new_text")
		if k ~= "combat" then
			if k == "maxLv" then
				UIUtil.setText(v.transform, Language:getTextByKey("advanced_str_0002"), "name_text")
			else
				local name = GameUtil:getAttrsName(k)
				UIUtil.setText(v.transform, name, "name_text")
			end
		end
	end
	UIUtil.setText(self:findGameObject("evo_image").transform, Language:getTextByKey("hero_evolution" .. new_hero.evo), "Text")
end

function M:setSpine()
	local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
 	local sg = self.hero_sk:GetComponent("SkeletonGraphic")
	UIUtil.setLocalPosition(self.hero_sk.transform,0,-45,0)

	local spine = cfg.hero_spine or "hero_0001_SkeletonData"
	local hehe = ResourceUtil:GetSk(spine, "rolespine_"..string.lower(spine))
 	sg.skeletonDataAsset = hehe
 	sg:Initialize(true)
end

return M