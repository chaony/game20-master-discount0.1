local M = class("HeroEchoModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_echo_cfg = ConfigManager:getCfgByName("hero_resonance")
	self.m_heroes = self:filtrateHero()
	self:setHero(self.m_heroes[1])
end

function M:filtrateHero()
	local hero_list = self:getAllHeroIds()
	local heroes = {}
	self.m_total_level = 0
	for k,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if l_hero_data.evo >= 19 and l_hero_cfg.is_sp == 1 then
			table.insert(heroes, v)
			local lv = l_hero_data.resonance_lv or 0
			self.m_total_level = self.m_total_level + lv
		end
	end
	UserDataManager.hero_data:heroIdsSort(heroes, "team")
	return heroes
end

function M:getAllHeroIds()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	return ids
end

function M:getHero(oid)
	local  data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	return data, cfg
end

function M:setHero(oid)
	local hero, cfg = self:getHero(oid)
	self.m_hero_oid = oid
	self.m_hero_id = hero.id
	self.m_hero_echo_lv = hero.resonance_lv or 0 --共鸣等级
	self.m_is_can_echo = false
end

--获得对应共鸣等级的属性
function M:getEchoAttrs()
	--local hero, cfg = self:getHero(self.m_hero_oid)
	local hero_echo_cfg = self.m_echo_cfg[self.m_hero_id] --此侠客的所有共鸣等级配置
	local index = 1
	if self.m_hero_echo_lv <= 0 then
		index = 1
		--index = #hero_echo_cfg  --0时返回最后一级的配置
	elseif self.m_hero_echo_lv > #hero_echo_cfg then
		index = #hero_echo_cfg
	else
		index = self.m_hero_echo_lv --当前共鸣等级的对应配置
	end
	local echo_cfg = hero_echo_cfg[index]
	return echo_cfg.attr
end

--获得共鸣技能配置
--param {技能索引1,2, 共鸣等级, 技能名字, 技能icon, 技能描述}
function M:getEchoSkillCfg()
	--local hero, cfg = self:getHero(self.m_hero_oid)
	local hero_echo_cfg = self.m_echo_cfg[self.m_hero_id] --此侠客的所有共鸣等级配置
	local skill_cfg = ConfigManager:getCfgByName("resonance_skill")
	local hero_skill_cfg = skill_cfg[self.m_hero_id]
	local skills = {}
	for k, v in pairs(hero_echo_cfg) do
		if v.skill and #v.skill > 0 then
			local idx = v.skill[1]
			local name_text = hero_skill_cfg.name[idx]
			local des_text = hero_skill_cfg.des[idx]
			local icon_img = hero_skill_cfg.icon[idx]
			table.insert(skills, {index = idx, lv = k, name = name_text, des = des_text, icon = icon_img})
		end
	end
	return skills
end

--获得共鸣升级消耗
function M:getEchoCost()
	local hero_echo_cfg = self.m_echo_cfg[self.m_hero_id] --此侠客的所有共鸣等级配置
	local index = self.m_hero_echo_lv + 1 --取下一级的消耗
	--index = #hero_echo_cfg + 1
	if index > #hero_echo_cfg then
		local echo_cfg = hero_echo_cfg[#hero_echo_cfg]
		return echo_cfg.cost[2][2] --满级，返回第二个材料的id，此材料约定为界面右侧侠客的id
		--return nil
	end
	local echo_cfg = hero_echo_cfg[index]
	return echo_cfg.cost
end

--获取总属性加成
function M:getEchoTotalAttrs()
	if self.m_total_level <= 0 then
		return nil
	end
	local cfg = ConfigManager:getCfgByName("hero_resonance_total")
	if self.m_total_level > #cfg then
		return cfg[#cfg]
	end
	local attrs = cfg[self.m_total_level].attr
	return attrs
end

function M:getEchoCostData()
	local cost = self:getEchoCost()
	if cost == nil or #cost <= 0 then
		return nil
	end
	local data = {}
	for k, v in pairs(cost) do
		if data[tostring(v[1])] == nil then --注意，必须判断，否则有相同类型的材料，会被覆盖
			data[tostring(v[1])] = {}
		end
		if v[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			data[tostring(v[1])][tostring(v[2])] = v[3]
		elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			local cfg = self:getEchoCostEvo(v[2]) --从card_hero表里，获取材料侠客的id和品质
			local hero_oids = UserDataManager.hero_data:getHeroIdsByCid(cfg.id, cfg.evo)--此id的所有侠客的oid
			for i = 1, v[3] do --根据所需侠客数量添加
				data[tostring(v[1])][hero_oids[i]] = 1
			end
		end
	end
	return data
end

function M:getEchoCostEvo(hero_id)
	--此配置里包含材料侠客的数据，后面筛选材料侠客时会用到其中的id和品质
	local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
	local cfg = card_hero_cfg[hero_id]
	if cfg == nil then
		return nil
	else
		return {id = cfg.hero_id, evo = cfg.hero_evo}
	end
end

function M:updateTotalLevel()
	--self.m_total_level = self.m_total_level + 1
	local hero_list = self:getAllHeroIds()
	self.m_total_level = 0
	for k,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if l_hero_data.evo >= 19 and l_hero_cfg.is_sp == 1 then
			local lv = l_hero_data.resonance_lv or 0
			self.m_total_level = self.m_total_level + lv
		end
	end
	UserDataManager.hero_data.m_echo_total_lv = self.m_total_level
end

return M