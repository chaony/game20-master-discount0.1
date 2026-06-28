local M = class("MagicWeaponLvUpModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "right_to_left"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_wea_id = self.m_params.wea_id
	self.m_wea_data = self.m_params.wea_data
	self.m_wea_cfg = self:getWeaCfg()
end

function M:updateInitData(data)
	self.m_wea_data = data
	self.m_wea_cfg = self:getWeaCfg()
end

function M:getTreasureConfig(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_config")
	return tab_cfg[index]
end

--法宝信息
function M:getWeaCfg()
	local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
	local lv = self:getWeaLv()
	return treasure_cfg.detail[lv]
end


--法宝等级
function M:getWeaLv()
	return self.m_wea_data.lv or 1
end

--法宝属性
function M:getWeaAttr()
	if self.m_wea_cfg then
		return self.m_wea_cfg.att
	end
	return {}
end

--属性的下一级属性获取
function M:getAttrNextById(id)
	if self:getWeaLv() < self.m_wea_cfg.skill_limit then
		local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
		local lv = self:getWeaLv()
		local next_cfg = treasure_cfg.detail[lv+1]
		for k,v in pairs(next_cfg.att) do
			if v[1] == id then
				return v[2]
			end
		end
	else
		return 0	
	end
end

--法宝技能  等级/图标/名字/描述
function M:getWeaSkill()
	local lv = self:getWeaLv()
	local skill_data = self:getSkillDataById()
	local icon_img = skill_data.icon 
	local name = Language:getTextByKey(skill_data.name) 
	local des = Language:getTextByKey(self.m_wea_cfg.skill_des) 
	return lv,icon_img,name,des
end

--法宝下一级的技能描述
function M:getWeaNextSkill()
	if self:getWeaLv() < self.m_wea_cfg.skill_limit then
		local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
		local lv = self:getWeaLv()
		local next_cfg = treasure_cfg.detail[lv+1]
		if next_cfg then
			return Language:getTextByKey(next_cfg.skill_des).. Language:getTextByKey("new_str_0153",lv+1) 	
		else
			return ""
		end		
	else
		return ""
	end
end

--法宝升级消耗
function M:getWeaCost()
	if self.m_wea_cfg and next(self.m_wea_cfg.cost) ~= nil then
		return RewardUtil:getProcessRewardData(self.m_wea_cfg.cost[1])
	end
	return nil
end

--获得所有消耗
function M:getAllWeaCost()
	local treasure_cfg = self:getTreasureConfig(self.m_wea_id)
	local lv = self:getWeaLv()
	local bast_cfg = treasure_cfg.detail[1]
	local cost_num = 0
	local cost_cfg =  table.copy(bast_cfg.cost[1])
	for i = 1,lv-1 do
		local cur_cfg = treasure_cfg.detail[i]
		cost_num = cost_num + cur_cfg.cost[1][3]
	end
	cost_cfg[3] = cost_num
	return cost_cfg
end


--法宝加持侠客
function M:getWeaHeros()
	if self.m_wea_cfg then
		return self.m_wea_cfg.skill_unit_list
	end
	return {}
end

--技能信息
function M:getSkillDataById()
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[self.m_wea_cfg.skill_id]
end

function M:checkMaxLv()
	if self:getWeaLv() < self.m_wea_cfg.skill_limit then
		return false
	else
		return true
	end
end

return M
