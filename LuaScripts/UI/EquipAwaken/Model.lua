local M = class("EquipAwakenModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_equips = self:getEquips()
	self.tag_index = 0
	self.select_index = 1
	self.m_hero_oid = self.m_params.hero_oid
	self.m_pos = self.m_params.pos
	if self.m_hero_oid and self.m_pos then
		local data,cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero_oid)
		local select_eqp = data.equips[tostring(self.m_pos)]
		if select_eqp and select_eqp.oid then
			for k,v in pairs(self.m_equips) do
				if v.hero_id and v.equ_id == select_eqp.oid then
					self.select_index = k
				end
			end
		end
	end
end

function M:updateData()
	self.m_equips = self:getEquips()
end


function M:getEquips()
	local new_ids = {}
	local eqp_ids = UserDataManager.equip_data:getEquipsId()
	for k,v in pairs(eqp_ids) do
		local data,cfg = UserDataManager.equip_data:getEquipDataById(v)
		if cfg.quality >= 8 and cfg.quality < 12 then
			table.insert(new_ids, {equ_id = tonumber(v), equ_data = data, equ_cfg = cfg})
		end
	end
	local hero_ids = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(hero_ids) do
		local data,cfg = UserDataManager.hero_data:getHeroDataById(v)
		for kk,vv in pairs(data.equips) do
			local equ_cfg = UserDataManager.equip_data:getEquipConfigByCid(vv.id)
			if equ_cfg.quality >= 8 and equ_cfg.quality < 12 then
				table.insert(new_ids, {equ_id = vv.oid, hero_id = v, pos = kk, equ_data = vv, equ_cfg = equ_cfg})
			end
		end
	end
	table.sort(new_ids, function(data1,data2)
		if data1.equ_cfg.quality == data2.equ_cfg.quality then
			if data1.equ_data.lv == data2.equ_data.lv then
				if data1.equ_cfg.pos == data2.equ_cfg.pos then
					return data1.equ_id > data2.equ_id
				else
					return data1.equ_cfg.pos < data2.equ_cfg.pos
				end
			else
				return data1.equ_data.lv > data2.equ_data.lv
			end
		else
			return data1.equ_cfg.quality > data2.equ_cfg.quality
		end
	end)
	return new_ids
end

function M:getFilterEquips()
	local new_eqps = {}
	if self.tag_index > 0 then
		for k,v in pairs(self.m_equips) do
			local equip_data = v.equ_data
			local equip_cfg = v.equ_cfg
			if equip_cfg.pos ==  self.tag_index then
				table.insert(new_eqps, v)
			end
		end
	end
	return new_eqps
end

function M:getCurEquip()
	local cur_eqp_data = nil
	if self.tag_index == 0 then
		cur_eqp_data = self.m_equips[self.select_index]		
	else
		local eqp_list = self:getFilterEquips()
		cur_eqp_data = eqp_list[self.select_index]	
	end
	return cur_eqp_data
end

function M:canAwakenIng()
    local cur_equip_data = self:getCurEquip()
	if cur_equip_data then
        local equip_data = cur_equip_data.equ_data
        local equip_cfg = cur_equip_data.equ_cfg
		local need_quality = ConfigManager:getCommonValueById(475,3)
		if equip_cfg.quality < 11 then
			return false,0
		end
		if equip_cfg.quality >= 12 then
			return false,0
		end
		if equip_data.lv < 5 then
			return false,1
		end
		local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
		local data = ConfigManager:getCommonValueById(535)
		if equip_cfg.pos ~= 1 then
			data = ConfigManager:getCommonValueById(536)
		end
		for i,v in pairs(data) do
			local reward_data = RewardUtil:getProcessRewardData(v)
			if reward_data.user_num < reward_data.data_num then
				return false,2
			end
		end
		if equip_data.affix then
			for k,v in pairs(equip_data.affix) do
				local affix_cfg = equip_affix_tab[v.id]
				if affix_cfg.unique == 0 then
					if affix_cfg.affix_quality < need_quality then
						return false,1
					end
				end
			end
		end
		return true
    end
	return false,0
end

function M:getPolishedAttrs()
	local e_data,e_cfg = self:getEqpData()

	local affix_attrs = {} --洗练属性
	local affix_ts = nil --专属属性

	return affix_attrs,affix_ts
end

function M:getThronesPhase()
	return UserDataManager.m_thrones_phase
end

function M:getCurThronesPhaseData()
	return ConfigManager:getCfgByName("equip_throne_phase")
end



return M
