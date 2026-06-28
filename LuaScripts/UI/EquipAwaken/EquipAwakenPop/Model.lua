local M = class("EquipAwakenPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_equip_data = self.m_params.equip_data
	self.m_equip_cfg = self.m_params.equip_cfg
end


function M:getThronesPhase()
	return UserDataManager.m_thrones_phase
end

function M:getCurThronesPhaseData()
	return ConfigManager:getCfgByName("equip_throne_phase")
end

return M
