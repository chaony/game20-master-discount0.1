local M = class("DepositorySkillUpgradeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_id = self.m_params.id
	self.m_mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_id)

end

-- 通过秘籍id获取buff列表
function M:getMysticBuffGroup()
	local buff_group_cfg = {}
	if self.m_mystic_cfg then
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		local buff = UserDataManager.mystic_data:getMysticEfficientSkill(self.m_id)
		for i, v in pairs(buff) do
			buff_group_cfg[i] = mystic_buff_cfg[v]
		end
	end
	return buff_group_cfg
end

-- 奥义解放
function M:getInsetSkillAttr()
	local show_data = UserDataManager.mystic_data:getMysticInsetSkillEffect(self.m_id)
	return show_data
end

return M
