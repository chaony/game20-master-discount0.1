local M = class("EquipmentPolishedsPopPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.hero_oid
	self.m_pos = self.m_params.pos
	self.m_select_index = 1
	self.m_polish_tab = self:getPolishs()
end

--刷新数据
function M:refreshData()
	self.m_select_index = 1
	self.m_polish_tab = self:getPolishs()
end

function M:getEqpData()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local equips = h_data.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
	local new_equip_data = table.copy(self.m_equip_data)  
	local attr_num = 0
	for k,v in pairs(new_equip_data.affix) do
		if v.wish then
			attr_num = #v.wish
		end
	end
	if self.m_pos == 1 then
		--武器批量刷新 后端没有给特殊词缀的wish 自己创建身上的特殊词缀
		local wish = {}
		local affix_1 = new_equip_data.affix["1"]
		for i = 1, attr_num do
			local wish_tab = {}
			table.insert( wish_tab, affix_1.id)
			table.insert( wish_tab, {affix_1.value[1]})
			table.insert(wish,wish_tab)
		end
		new_equip_data.affix["1"].wish = wish
	end
	for k,v in pairs(new_equip_data.affix) do
		if v.lock == 1 and v.wish == nil then
			local wish = {}
			for i = 1, attr_num do
				local wish_tab = {}
				table.insert( wish_tab, v.id)
				table.insert( wish_tab, {v.value[1]})
				table.insert(wish,wish_tab)
			end
			new_equip_data.affix[tostring(k)].wish = wish
		end
	end
	return new_equip_data, cfg
end

function M:getPolishs()
	local e_data,e_cfg = self:getEqpData()
	local polish_tab = {}
	self.cur_affix = e_data.affix
	local have_wish = false
	local attr_num = 0
	for k,v in pairs(e_data.affix) do
		if v.wish then
			have_wish = true
			attr_num = #v.wish
		end
	end
	if have_wish then
		for i = 1 ,attr_num do
			for k,v in pairs(e_data.affix) do
				local wish_tab = v.wish
				if wish_tab then
					if polish_tab[i] then
						polish_tab[i][tonumber(k)] =  wish_tab[i]
					else
						table.insert( polish_tab, i ,{[tonumber(k)] = wish_tab[i]} )
					end
				else
					local cur_affix = self.cur_affix[tostring(1)]
					local new_wish_tab = {}
					table.insert( new_wish_tab, cur_affix.id)
					table.insert( new_wish_tab, {cur_affix.value[1]})
					if polish_tab[i] then
						polish_tab[i][1] =  new_wish_tab[i]
					else
						table.insert(polish_tab, 1 ,new_wish_tab)
					end
				end
			end
		end
	end
	return polish_tab
end

function M:getPolishByIndex(index)
	if index == 1 then
		local cur_polish = {}
		local max_num  = table.nums(self.cur_affix)
		for i = 1,max_num do
			local cur_affix = self.cur_affix[tostring(i)]
			local wish_tab = {}
			table.insert( wish_tab, cur_affix.id)
			table.insert( wish_tab, {cur_affix.value[1]})
			table.insert(cur_polish,i ,wish_tab)
		end
		return cur_polish
	end
	return self.m_polish_tab[index-1] or {}
end


function M:getPolishedAttrs()
	local e_data,e_cfg = self:getEqpData()
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
	return affix_attrs, affix_ts
end

--获取属性范围
function M:switchAttrs(data)
	local id = data[1] or 0
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_cfg = equip_affix_tab[id]
	local e_data,e_cfg = self:getEqpData()
	if affix_cfg and affix_cfg.unique ~= 1 then
		local scope = {}
		local attr_id = affix_cfg.effect[1].attr or 0
		if e_cfg.quality == 8 then
			scope = affix_cfg.effect[1].random_value[0]
		elseif 	e_cfg.quality >= 9 and e_cfg.quality <= 12 then
			scope = affix_cfg.effect[1].random_value[e_cfg.quality]
		else
			scope = affix_cfg.effect[1].random_value[0]
		end
		return attr_id ,scope
	end
	return 0,{}
end

function M:getAffixData(id) 
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	return equip_affix_tab[id]
end

function M:getOrderCombat(affix_data)
	local sum_score = 0
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	for k,v in pairs(affix_data) do
		local affix_cfg = equip_affix_tab[v[1]]
		local affix_data = v[2][1]
		if affix_cfg then
			if affix_cfg.unique == 0 then
			--词缀评分=词缀评分*词缀当前数值/词缀affix1_tier11的第二个值
				local attr_value = affix_data[3] or 0
				if affix_cfg.effect[1] then
					local effect = affix_cfg.effect[1].random_value[11][2]
					local affix1_score = affix_cfg.effect[1].score  or 1000
					local aff_score = affix1_score * attr_value/effect
					sum_score = sum_score + aff_score
				end
			else
				local attr_value = affix_data[3] or 0
				if affix_cfg.effect[1] then
					local effect = affix_cfg.effect[1].random_value[11][2]
					local affix1_score = affix_cfg.effect[1].score  or 1000
					sum_score = sum_score + affix1_score
				end
			end
		end
	end
	return math.ceil(sum_score)
end

--稀有属性
function M:checkRareAttrs(data)
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	for i,v in ipairs(data) do
		local lock = self:checkLockStatus(i)
		if self.m_pos == 1 then
			lock = self:checkLockStatus(i-1)
		end
        local affix_id = v[1]
        local affix_cfg = equip_affix_tab[affix_id]
        if lock == false and affix_cfg and affix_cfg.unique == 0 and affix_cfg.affix_quality >= 4 then
            return true
        end
    end
	return false
end

function M:polishCons()
	local e_data,e_cfg = self:getEqpData()
	local lock_num = 1
	if e_data.affix then
		for k,v in pairs(e_data.affix) do
			if v.lock == 1 then
				lock_num = lock_num + 1
			end
		end
	end
	local consItem = nil
	local cons_cfg = nil
	if self.m_pos == 1 then
		cons_cfg = ConfigManager:getCommonValueById(471) 
	else
		cons_cfg = ConfigManager:getCommonValueById(472)
	end
	local cur_cons_cfg = cons_cfg[lock_num] or cons_cfg[#cons_cfg]
	consItem = RewardUtil:getProcessRewardData(cur_cons_cfg)
	consItem.data_num = consItem.data_num*5
	return consItem
end

function M:checkLockStatus(index)
	if self.m_pos == 1 then
		if self.m_equip_data.affix[tostring(index+1)] then
			return self.m_equip_data.affix[tostring(index+1)].lock == 1
		end
	else
		if self.m_equip_data.affix[tostring(index)] then
			return self.m_equip_data.affix[tostring(index)].lock == 1
		end
	end
	return false
end

--洗练后的五条内有稀有词缀
function M:checkHaveRars()
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	for k,v in pairs(self.m_polish_tab) do
		if self:checkRareAttrs(v) == true then
			return true
		end
	end
	return false
end

--原有词缀有稀有词缀
function M:checkOrdHaveRars()
	local data = self:getPolishByIndex(1)
	return self:checkRareAttrs(data) == true
end

return M
