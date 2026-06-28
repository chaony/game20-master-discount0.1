local M = class("BossSkillPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self.m_skill_index = self.m_params.index
	self.m_hero_id = self.m_params.hero_id
	self.m_skill = self.m_params.skill
	self.m_hero_lv = self.m_params.cur_lv
	self.m_click_transform = self.m_params.click_transform
	self.m_pivot = self.m_params.pivot or Vector2.New(0.5,0.5)
	self.m_is_ordinary_skill = self.m_params.ordinary_skill or 0 --0普通技能，1天命化星技能, 2宠物技能
	self.m_title_text = self.m_params.title_text or ""
	self.m_skill_text = self.m_params.skill_text or ""
	
	self.m_boss_idx = self.m_params.boss_idx or 1
end

function M:getSkill()
	local skill_id = self:getCurBossSkill(self.m_boss_idx)
	return GameUtil:getSkill(skill_id)
end

function M:getCurBossSkill(boss_idx, skill_idx) --第几阶段boss ， 第几个技能
	return self.m_skill[boss_idx][1]
end

--技能描述
function M:getSkillBaseDesc(key)
	local id = self.m_skill[key][1]
	local lv_desc = ""
	local skill = GameUtil:getSkill(id)
	lv_desc = lv_desc.."<color=#3A485E>"..Language:getTextByKey(skill.des).."</color>"
	return lv_desc
end

function M:getSkillNeedLv(key)
	local lv = self.m_skill[key][2]
	return lv
end

--该技能是否已解锁
function M:isLock()
	if self.m_hero_lv >= self.m_skill[1][2] then
		return true
	else
		return false
	end
end

--function M:getSkillDesc()
--	local lv_desc = ""
--	for i = 2, #self.m_skill do
--		if self.m_hero_lv >= self.m_skill[i][2] then
--			local c_sk = self.m_skill[i][1]
--			local sk_data = GameUtil:getSkill(c_sk)
--			lv_desc = lv_desc.."<color=#3A485E>"..Language:getTextByKey(sk_data.des).."</color>\n"
--		else
--			local c_sk = self.m_skill[i][1]
--			local sk_data = GameUtil:getSkill(c_sk)
--			lv_desc = lv_desc.."<color=#3A485E>"..Language:getTextByKey(sk_data.des).."</color>"..Language:getTextByKey("new_str_0153",self.m_skill[i][2]).."\n"
--		end
--	end
--	return lv_desc
--end

--获取英雄信息
function M:getHeroById()
	return UserDataManager.hero_data:getHeroDataById(self.m_heroid)
end

function M:destroy()

	M.super.destroy(self)
end

return M