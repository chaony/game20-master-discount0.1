local M = class("SkillLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_hero_id =self.m_params.heroid
	self.m_hero_lv = self.m_params.cur_lv
	self.m_callback = self.m_params.callback
	self.m_close_callback = self.m_params.close_callback
	self.m_data_exp = self.m_params.data_exp
	self.m_data_coin = self.m_params.data_coin
	self.m_data_special = self.m_params.data_special
	self.m_hero_data, self.m_hero_cfg = self:getHeroById()
end

--获得消耗
function M:getConsume()
	local up_expend = GameUtil:getHeroUpGrade(self.m_hero_lv)
	return up_expend
end

--获得即将激活的技能信息
function M:getSkillData()
	local skills = {}
	local next_lv = self.m_hero_lv+1
	for k,v in pairs(self.m_hero_cfg.skill) do
		for kk, vv in pairs(v) do
			if vv[2] == next_lv then
				if kk > 1 then
					return k, v[kk-1], vv
				else
					return k, nil, vv
				end
			end
		end
	end
end

function M:getSkillDataById(id)
	local sk_tab = ConfigManager:getCfgByName("skill_detail")
	return sk_tab[id]
end

--获得增加的战力
function M:getAddCombat()
	self.m_hero_data.lv = self.m_hero_lv 
	local new_hero = table.copy(self.m_hero_data)
	new_hero.lv = new_hero.lv + 1
	local new_attrs = UserDataManager:computeHeroAttrsClient(new_hero)
	local last_attrs = UserDataManager:computeHeroAttrsClient(self.m_hero_data)

	local new_combat = UserDataManager:computeEquipCombat(new_attrs)
	local last_combat =  UserDataManager:computeEquipCombat(last_attrs)
	local add_combat =  new_combat-last_combat
	return add_combat
end

function M:getHeroById()
	return UserDataManager.hero_data:getHeroDataById(self.m_hero_id)
end

function M:checkConsumeNum()
	local up_expend = self:getConsume()
	if up_expend.exp > self.m_data_exp then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0})
		return false, Language:getTextByKey("new_str_0098", data.name)
	elseif up_expend.coin > self.m_data_coin then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0})
		return false,  Language:getTextByKey("new_str_0098", data.name)
	elseif  up_expend.special_num > self.m_data_special then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0})
		return false,   Language:getTextByKey("new_str_0098", data.name)
	end
end

return M
