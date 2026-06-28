local M = class("EquipmentSmeltingPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end
local __item_exp_stone = {103, 1101, 0}
local __item_exp_coin = {104, 0, 0}

function M:onEnter()
	self:initData()
end

function M:initData()
	self.m_cur_select_eqb_tab = {}
	self.m_show_data = {}
	self.m_total_cost_tab = {} --进阶返回道具物品
	self.m_consume_item_id_tab = {} -- key 是道具类型拼上道具id, v 是在total_cons中的索引
	self.m_common_consum = {} -- common表里配的必展示的奖励
	self.m_exp_coin_tab = {} --消耗的总的金币 经验
	local temp_data = {}
	GameUtil:insertEquipsData(temp_data)
	for i, v in pairs(temp_data) do
		local quality = v.quality
		local need_quality = ConfigManager:getCommonValueById(513,8)
		local max_quality = ConfigManager:getCommonValueById(571,12)
		if quality >= need_quality and quality < max_quality then
			table.insert(self.m_show_data, v)
		end
	end
	--local high_consum = ConfigManager:getCommonValueById(511, {})
	--local low_consum = ConfigManager:getCommonValueById(512,{})
	--table.insert(self.m_common_consum, low_consum)
	--table.insert(self.m_common_consum
	--, high_consum)
end

function M:getEqpData()
	return self.m_show_data
end

function M:getRighShowData()
	local temp = {}
	temp = table.copy(self.m_total_cost_tab)
	for i = 1, 2 do
		--table.insert(temp, 1, self.m_common_consum[i])
		if self.m_exp_coin_tab[i] and next(self.m_exp_coin_tab[i]) then
			table.insert(temp, self.m_exp_coin_tab[i])
		end
	end
	local function sortFunc(d1,d2)
		local sort_id1 = d1[4] and d1[4] or 0
		local sort_id2 = d2[4] and d2[4] or 0
		return sort_id1 > sort_id2
	end
	table.sort(temp, sortFunc)
	return temp
end

function M:isSelect(oid)
	if self.m_cur_select_eqb_tab[tostring(oid)] == nil then
		return false
	end
	return true
end

function M:addEquipToSelect(oid, cid)
	self.m_cur_select_eqb_tab[tostring(oid)] = cid 
	--self:getConsume()
end

function M:removeEquipFromSelect(oid)
	if self.m_cur_select_eqb_tab[tostring(oid)] ~= nil then
		self.m_cur_select_eqb_tab[tostring(oid)] = nil
	end
end

function M:udpateConsume(oid, cid, is_add)
	--self:getEqpNum(oid)
	local c_id = cid
	local cur_cons, low_consum, high_consum = {},{},{}
	local equip_cfg = ConfigManager:getCfgByName("equip_detail")
	local cur_cons = table.copy(equip_cfg[c_id].evolution_cost_back or {}) 
	local low_consum, high_consum = self:getCommonConsume(equip_cfg.pos)
	table.insert(cur_cons, low_consum)
	table.insert(cur_cons, high_consum)
	for i, item_data in pairs(cur_cons) do
		self:dealItemData(item_data, is_add)
	end
	self:getEqpExpAndMoney(oid, is_add)
end

--获取装备对应的common表中的返还道具
function M:getCommonConsume(equip_pos)
	local high_consum = table.copy( ConfigManager:getCommonValueById(511, {}))
	local low_consum = table.copy( ConfigManager:getCommonValueById(512,{}))

	if equip_pos == 1 then
		 high_consum =  table.copy( ConfigManager:getCommonValueById(540, {})) 
		 low_consum =  table.copy( ConfigManager:getCommonValueById(541, {}))
	end
	if high_consum and next(high_consum) then
		high_consum[4] = 2
		low_consum[4] = 1
	end
	return low_consum, high_consum
	
end

--计算奖励数目，同类的合并，不同的插入
function M:dealItemData(item_data, is_add)
	local cons_id = item_data[1] .. "_" .. item_data[2]
	if is_add then
		if self.m_consume_item_id_tab[cons_id] then
			self.m_total_cost_tab[self.m_consume_item_id_tab[cons_id]][3] = self.m_total_cost_tab[self.m_consume_item_id_tab[cons_id]][3] + item_data[3]
		else
			table.insert(self.m_total_cost_tab, item_data)
			self.m_consume_item_id_tab[cons_id] = #self.m_total_cost_tab
		end
	else
		if self.m_consume_item_id_tab[cons_id] then
			self.m_total_cost_tab[self.m_consume_item_id_tab[cons_id]][3] = self.m_total_cost_tab[self.m_consume_item_id_tab[cons_id]][3] - item_data[3]
			if self.m_total_cost_tab[self.m_consume_item_id_tab[cons_id]][3] <= 0 then
				table.remove(self.m_total_cost_tab, self.m_consume_item_id_tab[cons_id])
				self.m_consume_item_id_tab[cons_id] = nil
				self:updateConsumeIndex()
			end
		end
	end
end

function M:resetConsumeData()
	self.m_cur_select_eqb_tab = {}
	self.m_show_data = {}
	self.m_total_cost_tab = {} --进阶返回道具物品
	self.m_consume_item_id_tab = {} -- key 是道具类型拼上道具id, v 是在total_cons中的索引
	self.m_common_consum = {} -- common表里配的必展示的奖励
	self.m_exp_coin_tab = {} --消耗的总的金币 经验
end

function M:updateConsumeIndex()
	for i, v in pairs(self.m_total_cost_tab) do
		local cons_id = v[1] .. "_" .. v[2]
		self.m_consume_item_id_tab[cons_id] = i
	end
end

--当前的经验
function M:getEqpExpAndMoney(oid, is_add)
	local equip_data = UserDataManager.equip_data:getEquipDataById(oid)
	local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, equip_data.id, equip_data.race, v,equip_num=equip_data.amount or 0})
	local exp = equip_data.exp
	
	if equip_data.lv> 0 then
		local next_exp = 0
		for i = 0, equip_data.lv - 1 do
			next_exp = next_exp + GameUtil:getEquipUpGrade(data.quality, i, data.item_cfg.pos) or 0
		end
		exp = exp + next_exp
	end
	local rate = ConfigManager:getCommonValueById(11)
	local money = exp * rate
	local exp_stone_num = math.floor( exp / 10)
	if #self.m_exp_coin_tab > 1 and next(self.m_exp_coin_tab[1]) then
		if is_add then
			self.m_exp_coin_tab[1][3] = self.m_exp_coin_tab[1][3] + exp_stone_num
			self.m_exp_coin_tab[2][3] = self.m_exp_coin_tab[2][3] + money
		else
			self.m_exp_coin_tab[1][3] = self.m_exp_coin_tab[1][3] - exp_stone_num
			self.m_exp_coin_tab[2][3] = self.m_exp_coin_tab[2][3] - money
			if self.m_exp_coin_tab[1][3] <= 0 then
				self.m_exp_coin_tab[1] = {}
			end
			if self.m_exp_coin_tab[2][3] <= 0 then
				self.m_exp_coin_tab[2] = {}
			end
		end
	else
		local item_stone = {}
		local item_coin = {}
		if exp_stone_num > 0 then
			item_stone = __item_exp_stone
			item_stone[3] = exp_stone_num
			item_coin = __item_exp_coin
			item_coin[3] = money
		end
		self.m_exp_coin_tab[1] = item_stone
		self.m_exp_coin_tab[2] = item_coin
	end
end

return M
