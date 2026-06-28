local M = class("EquipmentLevelUpModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.new_resultRace = 1
	self.m_check_list = {}
	self.m_pos = self.m_params.data.pos --当前槽位索引
	self.m_heroid = self.m_params.data.heroid 
	self.m_callback = self.m_params.callback
	self.m_open_tab_index = 1
	self.m_batch_polished = false --批量刷新
	self.m_random_index = 0
	self.m_roundNum = 0 --转动轮数
	self.m_batch_num = 5 --批量洗练的倍数
	self:checkRecoin()
	self:refreshData()
	self.god_cons = {} --神装强化消耗列表
	if self.cur_eqpcfg.quality >= 12 then
		self.m_open_tab_index = 5
	end
end

function M:refreshData()
	local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local equips = hero_data.equips
	self.cur_eqpdata = equips[tostring(self.m_pos)]
	self.cur_eqpcfg = UserDataManager.equip_data:getEquipConfigByCid(self.cur_eqpdata.id)
	self.m_canlevelup =  self.cur_eqpdata.lv < self.cur_eqpcfg.lv_limit
	self.item_list =  self:getfiltItem() 
	self.eqp_list = table.copy(UserDataManager.equip_data:getEquipsId())
	self:consTable()
end

--消耗品列表
function M:consTable()
	self.cons_list = {}
	for i,v in ipairs(self.item_list) do
		local item_data = UserDataManager.item_data:getItemDataById(v)
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, v, item_data.num})
		table.insert(self.cons_list ,data)
	end
	self:DataSort(self.cons_list)
	for i,v in ipairs(self.eqp_list) do
		local equip_data, equip_cfg = UserDataManager.equip_data:getEquipDataById(v)
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, equip_data.id, equip_data.race, v,equip_num=equip_data.amount or 0})
		if equip_cfg.add_exp > 0 then
			data.user_num = equip_data.amount or 0
			data.exp = equip_data.exp
			table.insert(self.cons_list ,data)
		end
	end
	self:DataSort(self.cons_list)
end

function M:getfiltItem()
	local items = table.copy(UserDataManager.item_data:getItemsId())
	local filt_tab = {}
	for k,v in pairs(items) do
		local data, cfg = UserDataManager.item_data:getItemDataById(v)
		if cfg and cfg.type == 10 then
			table.insert(filt_tab, v)
		end
	end
	return filt_tab
end


function M:getCurEquipData()
	return self.cur_eqpdata, self.cur_eqpcfg
end

function M:getEqpById(id)
	return UserDataManager.equip_data:getEquipDataById(id)
end

--添加一件装备
function M:addCheckEqp(data)
	if self.m_check_list[data] then
		self.m_check_list[data] = self.m_check_list[data] + 1
		return
	end
	self.m_check_list[data] = 1
end

--添加多件装备
function M:addMoreCheckEqp(data, num)
	if self.m_check_list[data] then
		self.m_check_list[data] = self.m_check_list[data] + num
		return
	end
	self.m_check_list[data] = num
end

--检查当前装备数量是否达到最大
function M:checkIsInEqpList(data)
	if self.m_check_list[data] and self.m_check_list[data] >= data.user_num then
		return true
	end
	return false
end

--检查当前装备在列表中的数量
function M:checkNumInList(data)
	for k,v in pairs(self.m_check_list) do
		local m_data = k
		if m_data == data then
			return v
		end
	end

	return 0
end

--移除一件装备
function M:removeCheckEqp(data)
	if self.m_check_list[data] and self.m_check_list[data] > 1 then
		self.m_check_list[data] = self.m_check_list[data] -1 
	else
		self.m_check_list[data] = nil
	end

	if self.overlay_lv == self.cur_eqpcfg.lv_limit then
		self.m_isfull = true
	else
		self.m_isfull = false
	end
end

--当前的经验 （(本身的+列表里的)）
function M:getEqpNum()
	local exp_num = self.cur_eqpdata.exp
	for k,v in pairs(self.m_check_list) do
		local data = k
		if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			exp_num = exp_num + data.item_cfg.effect * v
		elseif 	data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			local star_num = self:getStarExpNum(data.oid)
			exp_num = exp_num + (data.item_cfg.add_exp + star_num) * v
		end
	end
	return exp_num
end

function M:getStarExpNum(oid)
	local data, cfg = UserDataManager.equip_data:getEquipDataById(oid)
	local equip_levelup_tab = ConfigManager:getCfgByName("equip_levelup")
	local sub_num = data.exp 
	if data then
		local exp_cfg_list = equip_levelup_tab[cfg.quality]
		for k = 1, data.lv do
			if cfg.pos == 1 then
				sub_num = sub_num + exp_cfg_list[k].arms_exp
			else
				sub_num = sub_num + exp_cfg_list[k].exp
			end
		end
	end
	return sub_num
end

--本次升级需要的经验
function M:getNeedExpNum()
	local need_num = 0
	if self.cur_eqpdata.lv >= self.cur_eqpcfg.lv_limit then
		need_num = 0
	else
		need_num = self:getAllExpNum(1)
	end
	return need_num
end

--展示当前等级经验进度 （(本身的+列表里的)-上一级所需）
function M:getShowCueExpNum()
	local cur_lv_exp = 0 
	local lv_exp = self:lvToExp()  --110000 获得装备升级消耗
	local cur_exp = self:getEqpNum() + lv_exp --177240
	local next_lv = self:getPreviewLevel()
	local need_exp = self:getAccum(next_lv) --200000
	cur_lv_exp = self:getShowNextExpNum() - (need_exp - cur_exp)
	return cur_lv_exp
end

function M:getShowCurExpNumByNum(lv)
	local exp = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, lv, self.cur_eqpcfg.pos)
	return exp or 0
end


--展示下阶段经验
function M:getShowNextExpNum()
	local need_num = 0
	local next_lv = self:getPreviewLevel()
	local data_exp = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, next_lv - 1 ,self.cur_eqpcfg.pos)
	return data_exp
end

function M:lvToExp()
	local exp_num = 0
	for i = 0, self.cur_eqpdata.lv - 1 do
		local data_exp = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, i, self.cur_eqpcfg.pos)
		exp_num = exp_num + data_exp
	end
	return exp_num
end

--多次升级需要的总经验
function M:getAllExpNum(add_num)
	local need_num = 0
	for i = 0, add_num -1 do
		if  self.cur_eqpcfg.lv_limit > self.cur_eqpdata.lv + i then
			local exp = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, self.cur_eqpdata.lv + i, self.cur_eqpcfg.pos)
			need_num = need_num + exp
		end 
	end
	return need_num
end

--累计经验
function M:getAccum(lv)
	local accum_num = 0
	for i = 0, lv - 1 do
		local exp = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, i, self.cur_eqpcfg.pos)
		accum_num = accum_num + exp
	end
	return accum_num
end



--多次经验是否足够
function M:enoughExp(add_num)
	local need_exp = self:getAllExpNum(add_num)
	local all_exp = 0
	for k,v in pairs(self.cons_list) do
		if v.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			all_exp = all_exp + v.item_cfg.effect * v.user_num
		elseif v.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			all_exp = all_exp + v.item_cfg.add_exp * v.user_num
		end
	end
	if need_exp > all_exp then
		return false
	else
		return true	
	end
end

function M:getCfgById(id)
	local cfg = UserDataManager.equip_data:getEquipConfigByCid(id)
	return cfg
end

--装备列表
function M:getEqpList()
	return self.eqp_list
end

--
function M:getEqpByIndex(index)
	local eq_id = self.eqp_list[index]
	return eq_id
end

--快速填充
function M:rapidFilling()
	if self:getShowNextExpNum() == self:getShowCueExpNum() and self:getPreviewLevel() < self.cur_eqpcfg.lv_limit then
		for k,v in pairs(self.cons_list) do
			if self:checkIsInEqpList(v) == false then
				self:addCheckEqp(v)
				break
			end
		end
	end
	local needExp = self:getShowNextExpNum() - self:getShowCueExpNum()
	local add_tab = {}
	for k,v in ipairs(self.cons_list) do
		if self:getRapidEqpNum(add_tab) < needExp then
			if v.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS and self:checkRapidAdd(v.quality) == false then
				break
			end
			for i = 1, v.user_num do
				if self:getRapidEqpNum(add_tab) < needExp then
					if add_tab[v] then
						if self:checkRapidNum(v, add_tab[v]) == false then
							add_tab[v] = add_tab[v] + 1
						end
					elseif self:checkRapidNum(v, 1) == false then	
						add_tab[v] = 1
					end
				else

				end
			end
		end
	end
	for k,v in pairs(add_tab) do
		self:addMoreCheckEqp(k, v)
	end
end

--快速填充检查品级
--[[
	一键强化橙及橙以上的装备时，不会自动选择与自身品阶相同或更高的装备；
	比如，强化橙装时，只会自动选择橙色一下的装备；强化红装时，只会选择红色一下的装备；
	但是紫色及紫色以下的装备强化时，可以选择与自己品阶相同的装备，但不会选择比自己等级高的装备；
	比如：强化蓝装时，会自动选择蓝色及蓝色以下 的装备，强化紫装时，会自动选择紫色及紫色以下的装备
]]
function M:checkRapidAdd(quality)
	if self.cur_eqpcfg.quality >= 6 then
		if quality >= self.cur_eqpcfg.quality then
			return false
		else
			return true
		end
	else
		if quality > self.cur_eqpcfg.quality then
			return false
		else
			return true	
		end
	end
	return false
end

function M:checkRapidNum(data, num)
	if self.m_check_list[data] and (self.m_check_list[data] + num) >= data.user_num then
		return true
	end
	return false
end

--计算经验
function M:getRapidEqpNum(tab)
	local exp_num = 0
	for k,v in pairs(tab) do
		local data = k
		if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			exp_num = exp_num + data.item_cfg.effect * v
		elseif 	data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			local star_num = self:getStarExpNum(data.oid)
			if star_num > 0 then
				exp_num = exp_num + (data.item_cfg.add_exp + star_num) * v
			else
				exp_num = exp_num + data.item_cfg.add_exp * v
			end
		end
	end
	return exp_num
end


--消耗金币
function M:getNeedMoney()
	local money = 0
	local add_exp = 0
	for k,v in pairs(self.m_check_list) do
		local data = k
		if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			add_exp = add_exp + data.item_cfg.effect * v
		elseif 	data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			local star_num = self:getStarExpNum(data.oid)
			add_exp = add_exp + (data.item_cfg.add_exp + star_num) * v
		end
	end
	local cur_num = self:getShowCueExpNum() --当前经验
    local max_num = self:getShowNextExpNum() -- 当前上线
	if cur_num > max_num then
		add_exp = add_exp - (cur_num - max_num)
	end
	local rate = ConfigManager:getCommonValueById(11)
	money = add_exp * rate
	return money
end

--经验是否可以升一级
function M:isFull()
	local cur_num = self:getEqpNum()
	local need_num = self:getNeedExpNum()
	return cur_num >= need_num
end

--获取预览的等级(根据当前经验算出来的等级)
function M:getPreviewLevel()
	if not self:isFull() then
		return self.cur_eqpdata.lv + 1
	end
	local cur_num = self:getEqpNum()
	local max_lv = self.cur_eqpcfg.lv_limit - 1
	for i = self.cur_eqpdata.lv, max_lv do
		local need_num = GameUtil:getEquipUpGrade(self.cur_eqpcfg.quality, i, self.cur_eqpcfg.pos)
		local cc_num =  cur_num - need_num 
		if cc_num == 0 then
			return i + 1
		elseif cc_num < 0 then	
			return i + 1
		end
		cur_num = cc_num
	end
	if cur_num >= 0 then
		return self.cur_eqpcfg.lv_limit
	end
end

--强化已达最大等级
function M:expIsFull()
	local show_cur_exp = self:getShowCueExpNum()
	local show_next_exp = self:getShowNextExpNum()
	if self:getPreviewLevel() == self.cur_eqpcfg.lv_limit and show_cur_exp >= show_next_exp then
		return true
	end
	return false
end

function M:DataSort(data)
    local function sortFunc(data1, data2)
        local quality1 = data1.item_cfg.quality
		local quality2 = data2.item_cfg.quality
		if data1.data_type == data2.data_type then
			if quality1 == quality2 then
				return tonumber(data1.data_id) < tonumber(data2.data_id)
			else
				return quality1 < quality2
			end
		else
			return data1.data_type > data2.data_type
		end
    end
    table.sort(data, sortFunc)
end

function M:getCons()
	local cons_cfg = ConfigManager:getCommonValueById(82)
	local consItem = RewardUtil:getProcessRewardData(cons_cfg[1])
	return consItem
end

function M:turnNum()
	if self.m_random_index >= 6 then
		self.m_random_index = 1
		self.m_roundNum = self.m_roundNum + 1
	else
		self.m_random_index = self.m_random_index + 1
	end
	if self.m_random_index == self.m_resultRace then
		self:turnNum()
	end
end

function M:canStop()
	if self.m_roundNum >= 3 and self.m_random_index ==  self.new_resultRace then
		self.m_roundNum = 0
		return true
	else
		return false	
	end
end

function M:checkRecoin()
	local e_data, e_cfg = self:getEqpData()
	self.m_resultRace = table.copy(e_data.race)  -- 当前
end

function M:checkNewRecoin()
	local e_data, e_cfg = self:getEqpData()
	self.new_resultRace = table.copy(e_data.race)  -- 新的种族
end

function M:getEqpData()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local equips = h_data.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
	return self.m_equip_data, cfg
end

function M:getCombat()
	local cur_data, cur_cfg = self:getEqpData()
	local cur_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, cur_cfg, 0)
	local next_cfg =	UserDataManager.equip_data:getEquipConfigByCid(cur_cfg.evolution_id) 
	local next_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, next_cfg, 0)
	local data1 = {}
	local data2 = {}
	for i,v in ipairs(cur_attr) do
		local key = GameUtil:getAttrsKey(v[1])
		data1[key] = v[2]
	end
	for i,v in ipairs(next_attr) do
		local key = GameUtil:getAttrsKey(v[1])
		data2[key] = v[2]
	end
	local cur_comb = UserDataManager:computeEquipCombat(data1)
	local next_comb = UserDataManager:computeEquipCombat(data2)
	return cur_comb, next_comb
end

function M:getAttr()
	local cur_data, cur_cfg = self:getEqpData()
	local cur_attr = UserDataManager:getEquipAttrsByData({lv = cur_data.lv, race = 0}, cur_cfg, 0)
	return UserDataManager:appendAttrs(cur_attr) 
end
function M:getNextAttr(kk)
	local cur_data, cur_cfg = self:getEqpData()
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(cur_cfg.evolution_id) 
	local next_attr = UserDataManager:getEquipAttrsByData({lv = cur_data.lv, race = 0}, cfg, 0)
	local next_append = UserDataManager:appendAttrs(next_attr) 
	return next_append[kk] or 0
end

--升阶消耗
function M:getConsume()
	local c_id = self.m_equip_data.id
	local tab = ConfigManager:getCfgByName("equip_detail")
	local next_id = tab[c_id].evolution_id
	local next_cons = tab[c_id].evolution_cost
	return next_cons
end

function M:checkCanBreak()
	if self:checkCanPoloshed() == false then
		return false
	end
	local e_data,e_cfg = self:getEqpData()
	local lv = ConfigManager:getCommonValueById(434,5)
	if e_data.lv >= lv then
		local cons = self:getConsume()
        local data = RewardUtil:getProcessRewardData(cons[1])
		if data.user_num >= data.data_num then
			return true
		end
	end
	return false
end

--装备强化吃的装备品级大于自身
function M:checkEatEqpOver()
	if self.cur_eqpcfg and self.cur_eqpcfg.quality > 5 then
		for k,v in pairs(self.m_check_list) do
			local data = k
			if data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS and data.item_cfg.quality >= self.cur_eqpcfg.quality then
				return true
			end
		end
	end
	return false
end

function M:getPolishedAttrs()
	local e_data,e_cfg = self:getEqpData()
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_attrs = {} --洗练属性
	local affix_ts = nil --专属属性
	if e_data and e_data.affix then
		for k,v in pairs(e_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg == nil then
				break
			end
			if affix_cfg.unique == 1 then
				affix_ts = {data = v, cfg = affix_cfg} 
			else
				local parm = {}
				parm.data = v
				parm.index = tonumber(k)
				if e_cfg.quality == 8 then
					parm.cfg = affix_cfg.effect[1].random_value[0]
				elseif 	e_cfg.quality >= 9 and e_cfg.quality <= 12 then
					parm.cfg = affix_cfg.effect[1].random_value[e_cfg.quality]
				else
					parm.cfg = affix_cfg.effect[1].random_value[0]	
				end
				table.insert(affix_attrs, parm)
			end
		end
	end
    local function sortFunc(data1, data2)
		return data1.index < data2.index
    end
    table.sort(affix_attrs, sortFunc)
	return affix_attrs,affix_ts
end

function M:getEquipAffixData(id)
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	return equip_affix_tab[id]
end

function M:polishCons(is_high)
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
	
	if is_high then
		cons_cfg = ConfigManager:getCommonValueById(509)
	elseif e_cfg.pos == 1 then
		cons_cfg = ConfigManager:getCommonValueById(471) 
	else
		cons_cfg = ConfigManager:getCommonValueById(472)
	end
	local cur_cons_cfg = cons_cfg[lock_num] or cons_cfg[#cons_cfg]
	if is_high then
		consItem = RewardUtil:getProcessRewardData(cons_cfg[1])
	elseif cons_cfg and next(cons_cfg) and cur_cons_cfg then
		consItem = RewardUtil:getProcessRewardData(cur_cons_cfg)
	end
	if self.m_batch_polished == true and (is_high == false or is_high == nil) then
		consItem.data_num = consItem.data_num*self.m_batch_num
	end
	return consItem
end

--检测洗练是否还能加锁
function M:checkCanLock()
	local attrs = self:getPolishedAttrs()
	local lock_num = 0
	local e_data,e_cfg = self:getEqpData()
	if e_data.affix then
		for k,v in pairs(e_data.affix) do
			if v.lock == 1 then
				lock_num = lock_num + 1
			end
		end
	end
	lock_num = lock_num +1 --是否还有下一级消耗
	if lock_num > #attrs then
		return false
	end
	return true
end

function M:getBreakList()
	local e_data, e_cfg = self:getEqpData()
	local tab = {}
	local init_id = e_cfg.evolution_head
	--table.insert(tab, init_id)
	local new_table = self:addBreakList(init_id,tab)
	return new_table
end

function M:addBreakList(id, tab)
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(id)	
	if cfg.evolution_id and  cfg.evolution_id > 0 then
		table.insert(tab, cfg.evolution_id)
		self:addBreakList(cfg.evolution_id, tab)
	else
		if cfg.awake_id then
			table.insert(tab, cfg.awake_id)
		end
		return tab	
	end
	return tab
end

--是否有新增词缀
function M:checkNewAttrs()
	local attes = ConfigManager:getCommonValueById(473, {})
	local e_data,e_cfg = self:getEqpData()
	if e_cfg.pos ~= 1 then
		return 0
	end
	for k,v in pairs(attes) do
		if v[1] == e_cfg.quality then
			return v[2]
		end
	end
	return 0
end

--检测是否可以洗练/ 没有阵营的装备无法洗练
function M:checkCanPoloshed()
	local e_data, e_cfg = self:getEqpData()
	if e_data.race == 0 then
		return false
	else
		return true	
	end
end

--检查是不是需要继续洗练
function M:checkCanJueXing()
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local e_data, e_cfg = self:getEqpData()
	if e_data and e_data.affix then
		for k,v in pairs(e_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg ~= nil and affix_cfg.unique == 0 and v.lock == 0 and affix_cfg.affix_quality >= 3 then
				return true
			end
		end
	end
	return false
end

--检查是否开启神兵强化
function M:checkOpenAffixLvUp()
	local cfg,data = self:getCurEquipData()
	local season = UserDataManager:getCurSeason()
	local equip_legend_cfg, next_equip_legend_cfg = self:getEquipLegendCfg()
	local equip_affix_tab = ConfigManager:getCfgByName("equip_legend")
	local equip_cid = self.cur_eqpdata.id
	local equip_affix_item = equip_affix_tab[equip_cid]
	if equip_affix_item == nil or (equip_affix_item.season and equip_affix_item.season > season) then
		return false
	end
	local bl = BtnOpenUtil:isBtnOpen(299) --神兵谱中对应的种类需达到指定阶段
	if bl ==true and data.quality >= 12 then
		return true
	end
	return false
end

--检查装备图鉴需求 强化神级装备用
function M:checkArtifactLock()
	local equip_legend_cfg, next_equip_legend_cfg = self:getEquipLegendCfg()
	if next_equip_legend_cfg == nil then
		return false
	end
	local cfg,data = self:getCurEquipData()
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	return next_equip_legend_cfg.throne_limit <= evo
end


--是否消耗装备  强化神级装备用
function M:checkConsEquip()
	local equip_legend_cfg, next_equip_legend_cfg = self:getEquipLegendCfg()
	if next_equip_legend_cfg == nil then
		return false
	end
	if next(next_equip_legend_cfg.equip_cost) == nil then
		return true
	end
	if next(self.god_cons) ~= nil then
		return true
	end
	return false
end

--道具是否足够  强化神级装备用
function M:checkConsItem()
	local equip_legend_cfg, next_equip_legend_cfg = self:getEquipLegendCfg()
	if next_equip_legend_cfg == nil then
		return false
	end
	for k,v in pairs(next_equip_legend_cfg.cost) do
		local consItem = RewardUtil:getProcessRewardData(v)
		if consItem.data_num > consItem.user_num then
			return false
		end
	end
	return true
end
--神级装备强化数据表
function M:getEquipLegendCfg()
	local equip_affix_tab = ConfigManager:getCfgByName("equip_legend")
	local equip_cid = self.cur_eqpdata.id or 120101
	local star_lv = self.cur_eqpdata.lv 
	local next_star_lv = self.cur_eqpdata.lv + 1
	if equip_affix_tab[equip_cid] then
		return equip_affix_tab[equip_cid][star_lv],equip_affix_tab[equip_cid][next_star_lv]		
	end
	return nil,nil
end

--属性列表
function M:getEquipAttrsTab(c_data, n_data)
	local data = {}
	local temp_data = c_data or n_data
	for k,v in pairs(temp_data.attr) do 
		table.insert(data, {atr_id = v[1]})
	end
	local new_Data = {}
	local star_lv = self.cur_eqpdata.lv 
	local next_star_lv = self.cur_eqpdata.lv + 1
	if next_star_lv > 5 then 
		next_star_lv = 0
	end
	local lv_data = {atr_id = 0, c_num = star_lv, n_num = next_star_lv}
	table.insert(new_Data, lv_data)
	for k,v in pairs(data) do 
		local c_num = 0
		local n_num = 0
		if c_data then 
			for kk,vv in pairs(c_data.attr) do
				if vv[1] == v.atr_id then
					c_num = vv[2]
				end
			end
		end
		if n_data then 
			for kk,vv in pairs(n_data.attr) do
				if vv[1] == v.atr_id then
					n_num = vv[2]
				end
			end
		end
		if c_num >0 or n_num > 0 then
			table.insert(new_Data, {atr_id = v.atr_id, c_num = c_num, n_num = n_num })
		end
	end
	local function sortFunc(data1, data2)
		return data1.atr_id < data2.atr_id 
    end
	table.sort(new_Data, sortFunc)
	return new_Data
end


--神级装备消耗列表
function M:getEquipCostList(equ_cids)
	local equips = {}
	local cur_race = self.cur_eqpdata.race or 0
	for k,v in pairs(UserDataManager.equip_data.m_equips) do
		if v.race > 0 and self:checkInTab(v.id,equ_cids) == true then
			table.insert(equips, k)
		end
	end
	local function sortFunc(data1, data2)
		return tonumber(data1) < tonumber(data2) 
    end
	table.sort( equips, sortFunc)
	return equips
end

function M:checkInTab(id, tab)
	for k,v in pairs(tab) do
		if id == v then
			return true
		end
	end
	return false
end

function M:checkIsGetByGodCons(id)
	for k,v in pairs(self.god_cons) do
		if v == id then
			return true
		end
	end	
	return false
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "eqp_recast" then
		self:checkNewRecoin()
	elseif tag == "cancel_recast_recast" then
		self:checkNewRecoin()
	end
end

return M
