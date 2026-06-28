local M = class("HeroLvUpProPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_hero_id =self.m_params.heroid
	self.m_hero_lv = self.m_params.cur_lv
	self.m_hero_data, self.m_hero_cfg = self:getHeroById()
end

--获得即将激活的技能信息
function M:getSkillData()
	local skills = {}
	local next_lv = self.m_hero_lv
	Logger.log(next_lv,"等级信息：")
	Logger.log(self.m_hero_cfg.skill,"技能信息")
	for k,v in pairs(self.m_hero_cfg.skill) do
		for kk, vv in pairs(v) do
			if vv[2] == next_lv then
				if kk > 1 then
					return v[kk-1], vv
				else
					return nil, vv
				end
			end
		end
	end
end

function M:getSkillDataById(id)
	local sk_tab = ConfigManager:getCfgByName("skill_detail")
	return sk_tab[id]
end

--获得属性变化
function M:getProChange(pro)
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	local last_hero = table.copy(self.m_hero_data)
	last_hero.lv = last_hero.lv - 1
	local last_attrs = UserDataManager:computeHeroAttrsClient(last_hero)
	local new_attrs = UserDataManager:computeHeroAttrsClient(self.m_hero_data)

	local new_combat = UserDataManager:computeHeroCombat(self.m_hero_data)
	local last_combat =  UserDataManager:computeHeroCombat(last_hero)
	local max_data = hero_evolution[self.m_hero_data.evo]
	if pro == "lv_max" then
		return max_data.level_max, max_data.level_max
	elseif pro == "combat" then
		return last_combat, new_combat
	end
	return last_attrs[pro], new_attrs[pro]
end


function M:getHeroById()
	return UserDataManager.hero_data:getHeroDataById(self.m_hero_id)
end


return M
