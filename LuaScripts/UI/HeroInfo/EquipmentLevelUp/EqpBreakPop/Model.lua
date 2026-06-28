local M = class("EqpBreakPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_eqp_cfg = self.m_params.eqp_cfg 
	self.is_lock = false --界面加锁
end

function M:getTopQualityEquip(id)
	local cur_equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(id)	
	local str_name = ""
	local equip_cfg = nil
	if cur_equip_cfg then
		if cur_equip_cfg.quality == 12 then
			local str = string.split(cur_equip_cfg.picture_effect, "UI_")
			str_name = str[2]
			equip_cfg = cur_equip_cfg
		else
			if cur_equip_cfg.evolution_id and cur_equip_cfg.evolution_id > 0 then
				return self:getTopQualityEquip(cur_equip_cfg.evolution_id)
			elseif cur_equip_cfg.awake_id and cur_equip_cfg.awake_id > 0  then
				return self:getTopQualityEquip(cur_equip_cfg.awake_id)
			end
		end
	end
	return str_name, equip_cfg
end


return M
