local M = class("AdvancedSuccessPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_hero = self.m_params.hero
	self.m_link_id = self.m_params.link_id
	self.m_martial = self.m_params.martial or {}
	self:linkType()
end

function M:checkExclusive()
	local new_hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
	if new_hero and new_hero.evo >= open_evo and cfg.evo >= 5 then
		if BtnOpenUtil:isBtnOpen(147) then
			return BtnOpenUtil:isBtnOpen(148)
		else
			return false
		end
	else
		return false
	end
end

-- 如果有侠客已经装备秘籍，则本引导视为已完成
function M:isSkipGuide()
	local skip_flag = false
	local heros_data = UserDataManager.hero_data:getHerosData()
	if heros_data then
		for _, v in pairs(heros_data) do
			local mystics = v.mystics or {}
			for _,mystic_id in pairs(mystics) do
				if mystic_id ~= 0 then
					skip_flag = true
					break
				end
			end
		end
	end
	return skip_flag
end

--获取上一联动等级的品质等级数据
function M:getLastLinkEvo()
	local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	local num = 5
	if heroData.link and heroData.link ~= "" then
		local last_link = heroData.link_lv > 1 and heroData.link_lv - 1 or 0
		if last_link > 0 then
			local link_heroData, link_cfg = UserDataManager.hero_data:getHeroDataById(heroData.link)
			local ex_hero_cfg = exhero_evolution[last_link]
			if ex_hero_cfg then
				local evo_max = ex_hero_cfg and ex_hero_cfg.evo_max or heroData.evo
				num = math.min(link_heroData.evo, evo_max)
			end
		end
	else
		local ex_hero_cfg = exhero_evolution[heroData.link_lv]
		if ex_hero_cfg then
			local evo_max = ex_hero_cfg and ex_hero_cfg.evo_max or heroData.evo
			local link_heroData, link_cfg = UserDataManager.hero_data:getHeroDataById(self.m_link_id)
			num = math.min(link_heroData.evo, evo_max)
		end
	end
	return num
end

function M:isLink()
	-- local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	-- return cfg.islink == 1 or false
	return false
end

--结义类型 1结义 2加深 3解除
function M:linkType()
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	if heroData.link == nil or heroData.link == "" then
		return 3
	end
	if heroData.link_lv == 1 then
		return 1
	elseif heroData.link_lv > 1 then
		return 2
	end
	return 3
end

return M
