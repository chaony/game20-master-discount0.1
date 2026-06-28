local M = class("MagicWeaponSkillLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_wea_id = self.m_params.wea_id
	self.m_c_lv = self.m_params.c_lv
	self.m_call_func = self.m_params.call_func
	self.l_wea_cfg, self.m_wea_cfg = self:getWeaCfg()
end

function M:getTreasureConfig(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_config")
	return tab_cfg[index]
end

--法宝信息  上一级/当前的
function M:getWeaCfg()
	local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
	return  treasure_cfg.detail[self.m_c_lv], treasure_cfg.detail[self.m_c_lv+1]
end


--法宝属性
function M:getWeaAttr()
	if self.l_wea_cfg then
		return self.l_wea_cfg.att
	end
	return {}
end

--属性的下一级属性获取
function M:getAttrNextById(id)
	for k,v in pairs(self.m_wea_cfg.att) do
		if v[1] == id then
			return v[2]
		end
	end
	return 0
end

--法宝下一级的技能描述
function M:getWeaNextSkill()
	if self:getWeaLv() < self.m_wea_cfg.skill_limit then
		local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
		local lv = self:getWeaLv()
		local next_cfg = treasure_cfg.detail[lv+1]
		return next_cfg.des
	else
		return nil	
	end
end

--技能信息
function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	local skill_cfg = tab_cfg[id]
	return skill_cfg.icon, Language:getTextByKey(skill_cfg.name),  skill_cfg.des
end

return M
