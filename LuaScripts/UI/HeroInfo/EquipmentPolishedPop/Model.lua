local M = class("EquipmentPolishedPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.heroid
	self.m_pos = self.m_params.pos
	self.m_is_all_lock = self.m_params.is_all_lock or false --高阶洗练全锁 true
	self.m_attrs, self.m_affix_ts = self:getPolishedAttrs()
	self.order_affix_combat = self:getOrderCombat()
	if self.m_is_all_lock == true then
		self.order_affix_combat = self:getHighOrderCombat()
	end
    self.new_affix_combat = math.ceil(UserDataManager:getEquipAffixCombat(self.m_equip_data))
end

function M:getEqpData()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local equips = h_data.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
	return self.m_equip_data, cfg
end

function M:getPolishedAttrs()
	local e_data,e_cfg = self:getEqpData() -- pid是洗练之前的
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_attrs = {} --洗练属性
	local affix_ts = {  } --专属属性
	if e_data.affix then
		for k,v in pairs(e_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg.unique ~= 1 then
				local p_affix_cfg = equip_affix_tab[v.pid]
				local parm = {}
				parm.data = v
				parm.index = tonumber(k)
				if e_cfg.quality == 8 then
					parm.cfg = affix_cfg.effect[1].random_value[0]
					if v.lock == 1 or self.m_is_all_lock then
						parm.p_cfg = affix_cfg.effect[1].random_value[0]
					else
						parm.p_cfg = p_affix_cfg.effect[1].random_value[0]
					end
				elseif 	e_cfg.quality >= 9 and e_cfg.quality <= 12 then
					parm.cfg = affix_cfg.effect[1].random_value[e_cfg.quality]
					if v.lock == 1 or self.m_is_all_lock then
						parm.p_cfg = affix_cfg.effect[1].random_value[e_cfg.quality]
					else
						parm.p_cfg = p_affix_cfg.effect[1].random_value[e_cfg.quality]
					end
				else
					parm.cfg = affix_cfg.effect[1].random_value[0]
					if v.lock == 1 or self.m_is_all_lock then
						parm.p_cfg = affix_cfg.effect[1].random_value[0]
					else
						parm.p_cfg = p_affix_cfg.effect[1].random_value[0]
					end
				end
				table.insert(affix_attrs, parm)
			else
				local new_temp = {data = v, cfg = affix_cfg}
				local p_affix_cfg = equip_affix_tab[v.pid]
				local old_temp2 = new_temp
				if v.pid then
					p_affix_cfg = equip_affix_tab[v.pid]
					old_temp2 = {data = v, cfg = p_affix_cfg}
				end
				affix_ts[#affix_ts + 1] = old_temp2
				affix_ts[#affix_ts + 1] = new_temp
			end
		end
	end
	local function sortFunc(data1, data2)
		return data1.index < data2.index
    end
    table.sort(affix_attrs, sortFunc)
	return affix_attrs, affix_ts
end

function M:getOrderCombat()
	local sum_score = 0
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	if self.m_equip_data and self.m_equip_data.affix then
		for k,v in pairs(self.m_equip_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if v.lock == 0 and affix_cfg.unique == 0 then
				affix_cfg = equip_affix_tab[v.pid]
			end
			if affix_cfg then
				if affix_cfg.unique == 0 then
					--词缀评分=词缀评分*词缀当前数值/词缀affix1_tier11的第二个值
					local value = v.lock == 1 and v.value or v.pvalue
					for i,o in pairs(value) do
						local attr_value = o[3] or 0
						if affix_cfg.effect[i] then
							local effect = affix_cfg.effect[i].random_value[11][2]
							local affix1_score = affix_cfg.effect[i].score  or 1000
							local aff_score = affix1_score * attr_value/effect
							sum_score = sum_score + aff_score
						end
					end
				else
					local value = v.value 
					if v.pid then --如果有老词缀默认使用老词缀
						affix_cfg = equip_affix_tab[v.pid]
					end
					for i,o in pairs(affix_cfg.effect) do
						local affix_score = o.score  or 1000
						sum_score = sum_score + affix_score
					end
				end
			end
		end
	end
	return math.ceil(sum_score)
end

--高阶洗练
function M:getHighOrderCombat()
	local sum_score = 0
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	if self.m_equip_data and self.m_equip_data.affix then
		for k,v in pairs(self.m_equip_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg then
				if affix_cfg.unique == 0 then
					--词缀评分=词缀评分*词缀当前数值/词缀affix1_tier11的第二个值
					local value = v.value 
					for i,o in pairs(value) do
						local attr_value = o[3] or 0
						if affix_cfg.effect[i] then
							local effect = affix_cfg.effect[i].random_value[11][2]
							local affix1_score = affix_cfg.effect[i].score  or 1000
							local aff_score = affix1_score * attr_value/effect
							sum_score = sum_score + aff_score
						end
					end
				else
					affix_cfg = equip_affix_tab[v.pid]
					local value = v.pvalue	
					for i,o in pairs(value) do
						if affix_cfg.effect[i] then
							local affix_score = affix_cfg.effect[i].score  or 1000
							sum_score = sum_score + affix_score
						end
					end
				end
			end
		end
	end
	return math.ceil(sum_score)
end

return M
