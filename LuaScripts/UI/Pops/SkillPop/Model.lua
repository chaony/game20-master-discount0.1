---@class SkillPopModel:OODataBase
local M = class("SkillPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_skill_index = self.m_params.index
	self.m_hero_id = self.m_params.hero_id
	self.m_skill = self.m_params.skill
	self.m_hero_lv = self.m_params.cur_lv
	self.m_click_transform = self.m_params.click_transform
	self.m_pivot = self.m_params.pivot or Vector2.New(0.5,0.5)
	self.m_is_ordinary_skill = self.m_params.ordinary_skill or 0 --0普通技能，1天命化星技能, 2宠物技能,3登仙楼技能，4秘籍技能
	self.m_title_text = self.m_params.title_text or ""
	self.m_skill_text = self.m_params.skill_text or ""
	self.m_lv4Unlock=self.m_params.lv4Unlock
	self.sk_lv = self:getSkillCurLv()
	self.m_awaken_god_cfg = ConfigManager:getCfgByName("awaken_god")
	self.cur_awaken_god_cfg = self.m_awaken_god_cfg[(self.m_hero_id)]  or {}

	--指定第四级技能
	self.m_is_lv4=self.m_params.is_lv4
end

function M:getSkill()
	local skill_id = self:getCurLvSkill(self.m_hero_lv)
	return GameUtil:getSkill(skill_id) 
end

function M:getCurLvSkill(hero_lv)
	local cur_skill = 0
	if self.m_is_lv4 == nil  then
		for k,v in pairs(self.m_skill) do
			if hero_lv < v[2] then
				if k <= 1 then
					return self.m_skill[1][1]
				else
					return self.m_skill[k-1][1]
				end
			end
		end
		if self.m_lv4Unlock then
			return self.m_skill[#self.m_skill][1]
		else
			return self.m_skill[#self.m_skill-1][1]
		end

	else
		if self.m_is_lv4==true then
			return self.m_skill[#self.m_skill][1]
		else
			return self.m_skill[#self.m_skill-1][1]
		end
	end
end


function M:getSkillCurLv()
	for k,v in pairs(self.m_skill or {}) do
		if self.m_hero_lv < v[2] then
			if k <= 1 then
				return k - 1
			else
				return k - 1
			end
		end
	end
	return 0
end

--技能描述
function M:getSkillBaseDesc(key)
	local id = self.m_skill[key][1]
	local lv_desc = ""
	local skill = GameUtil:getSkill(id)
	local unlock_lv = skill.unlock_lv
	if self.m_is_ordinary_skill == 3 then
		unlock_lv = 1
	end
	if self.m_hero_lv >= unlock_lv then
		lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(skill.des).."</color>"
	else
		if self.m_is_ordinary_skill == 3 then
			local c_sk = self.m_skill[key][1]
			local sk_data = GameUtil:getSkill(c_sk)
			local cur_cfg = self.cur_awaken_god_cfg[(self.m_skill[key][2])]
			local text = cur_cfg  and cur_cfg.name or ""
			lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>" .. Language:getTextByKey("awake_system_text_0055", text)
		else
		    lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(skill.des).."</color>"..Language:getTextByKey("new_str_0153", skill.unlock_lv)
		end
	end
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

function M:getSkillDesc()
	local lv_desc = ""
	for i = 2, #self.m_skill do
		if self.m_hero_lv >= self.m_skill[i][2] and i<=3 then
			local c_sk = self.m_skill[i][1]
			local sk_data = GameUtil:getSkill(c_sk)
			lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>\n"
		else
			if self.m_is_ordinary_skill == 3 then
				local c_sk = self.m_skill[i][1]
				local sk_data = GameUtil:getSkill(c_sk)
				local cur_cfg = self.cur_awaken_god_cfg[(self.m_skill[i][2])]
				local text = cur_cfg  and cur_cfg.name or ""
				local sig_name=self:getUnLockSkillSigName(self.m_skill_index)
				if i==4 then
					if self.m_lv4Unlock then
						lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>\n"
					else
						lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>"..Language:getTextByKey("new_str_1139",sig_name..text).."\n"
					end
				else
					lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>" .. Language:getTextByKey("awake_system_text_0055", text) .."\n"
				end

			elseif self.m_is_ordinary_skill==0 then
				if i==4  then
					local c_sk = self.m_skill[i][1]
					local sk_data = GameUtil:getSkill(c_sk)
					local sig_name=self:getUnLockSkillSigName(self.m_skill_index)
					if self.m_lv4Unlock then
						lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>\n"
					else
						lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>"..Language:getTextByKey("new_str_1139",sig_name).."\n"
					end
				else
					local c_sk = self.m_skill[i][1]
					local sk_data = GameUtil:getSkill(c_sk)
					lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>"..Language:getTextByKey("new_str_0153",self.m_skill[i][2]).."\n"
				end
			else
				local c_sk = self.m_skill[i][1]
				local sk_data = GameUtil:getSkill(c_sk)
				lv_desc = lv_desc.."<color=#78310E>"..Language:getTextByKey(sk_data.des).."</color>"..Language:getTextByKey("new_str_0153",self.m_skill[i][2]).."\n"
			end
		end
	end
	return lv_desc
end

--获取解锁对应经脉技能名字
function M:getUnLockSkillSigName(skill_index)
	local meridians_cultivation_cfg=ConfigManager:getCfgByName("meridians_cultivation")
	for i, cfg_item in pairs(meridians_cultivation_cfg) do
		if cfg_item.open_maxlv_skill_index==skill_index then
			return cfg_item.lv_name
		end
	end
end


--获取英雄信息
function M:getHeroById()
	return UserDataManager.hero_data:getHeroDataById(self.m_heroid)
end

return M
