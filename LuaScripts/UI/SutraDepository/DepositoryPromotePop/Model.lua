---@class DepositoryPromotePopModel:OODataBase
local M = class("DepositoryPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_sel_func_tab_index = 1
	self.m_sel_tab_index = self.m_params.open_tab_index or 1 -- 1 全部 2 先天 3 绝学
	self.m_maxMysticQuality = self:getMaxQualityMystic() -- 获取配置表 中能合成的最大的品质
	self:resetData()
end

function M:resetData()
	self.selMysticQuality = 0 -- 首个添加的秘籍的品质
	self.selMysticType = 0 -- 首个添加的秘籍的类型
	self.selMysticList = {} -- 选择的秘籍列表
	self.selMysticListPos = {} -- 选择的秘籍在左侧的位置
	self.m_maxMysticQuality = self:getMaxQualityMystic() -- 获取配置表 中能合成的最大的品质
	self.m_next_quality = 0 -- 下阶段合成的秘籍品质
	self.m_reward_mystic = nil -- 合成后的秘籍
end

function M:getMaxQualityMystic()
	local synthesisCfg = ConfigManager:getCommonValueById(507)
	local quality = 0
	for i, v in pairs(synthesisCfg) do
		if v[1] > quality then
			quality = v[1]
		end
	end
	return quality
end

-- 获取拥有的所有秘籍的id
function M:getAllMysticDataList()
	local dataList = {}
	local all_mystic_ids = UserDataManager.mystic_data.m_mystices
	for i, v in pairs(all_mystic_ids) do
		--local flag = self:checkMysticSelected(v.oid)
		local cfg = self:getMysticData(v.id)
		if self.m_sel_func_tab_index == 1 then
			if cfg.quality <= self.m_maxMysticQuality then
				if self.selMysticType == 0 then
					dataList[#dataList+1] = {id = v.id, oid = v.oid}
				elseif self.selMysticType == 3 and cfg.type == 3 then
					dataList[#dataList+1] = {id = v.id, oid = v.oid}
				elseif self.selMysticType ~= 3 and cfg.type ~= 3 then
					dataList[#dataList+1] = {id = v.id, oid = v.oid}
				end
			end
		elseif self.m_sel_func_tab_index == 2 then
			dataList[#dataList+1] = {id = v.id, oid = v.oid}
		end
	end
	return dataList
end

-- 通过秘籍配置id获取秘籍详情
function M:getMysticData(m_oid)
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(m_oid)
	return cfg
end

-- 通过秘籍唯一id获取秘籍详情
function M:getMysticDataByOid(m_oid)
	local data, cfg = UserDataManager.mystic_data:getMysticDataById(m_oid)
	return data, cfg
end

-- 检查秘籍是否已在选中列表里
function M:checkMysticSelected(oid)
	local flag = false
	local index = 1
	for i, v in pairs(self.selMysticList) do
		if tonumber(v) ==  tonumber(oid) then
			flag = true
			index = i
		end
	end
	return flag, index
end

-- 添加选中的秘籍列表
function M:addSelMysticList(data)
	local index = table.keyof(self.selMysticList, data.oid)
	if index then
		--table.remove(self.selMysticList,index)
		self.selMysticList[index] = nil
		if table.nums(self.selMysticList) == 0 then -- 首次加入列表判断秘籍品质
			self.selMysticQuality = 0
			self.selMysticType = 0
			self.m_next_quality = 0
		end
	else
		if table.nums(self.selMysticList) == 0 then -- 首次加入列表判断秘籍品质
			local cfg = self:getMysticData(data.data_id)
			self.selMysticType = cfg.type or 0
			self.selMysticQuality = cfg.quality -- 设置秘籍品质
		end
		for i = 1, 10 do
			if not self.selMysticList[i] then
				self.selMysticList[i] = data.oid -- 添加秘籍id
				
				return
			end
		end
		
	end
end

function M:replaceSelMystic(data, index)
	if index == 1 then
		local cfg = self:getMysticData(data.data_id)
		self.selMysticQuality = cfg.quality -- 设置秘籍品质
	end
	self.selMysticList[index] = data.oid
end

-- 删除选中的秘籍列表
function M:removeSelMysticByIndex(m_index, m_oid)
	if self.selMysticList[m_index] then
		--table.remove(self.selMysticList, m_index) -- 删除下标秘籍的id
		self.selMysticList[m_index] = nil
		if table.nums(self.selMysticList) == 0 then -- 移除所有秘籍后品质置位0
			self.selMysticQuality = 0
			self.selMysticType = 0
			self.m_next_quality = 0
		end
	end
	self.m_reward_mystic = nil -- 重置获得奖励
end

-- 筛选已选中的品质的秘籍/所有秘籍
function M:screeningMysticByQuality()
	local screenList = {} -- 通过品质筛选后的秘籍列表
	local all_mystic_ids = self:getAllMysticDataList()
	local mystic_ids = {}
	if self.m_sel_tab_index~= 1 then
		for i, v in pairs(all_mystic_ids) do
			local cfg = self:getMysticData(v.id)
			if cfg.type == self.m_sel_tab_index-1 then
				table.insert(mystic_ids,v)
			end
		end
	else
		mystic_ids = all_mystic_ids
	end
	
	if self.selMysticQuality ~= 0 then
		for i, v in pairs(mystic_ids) do
			local cfg = self:getMysticData(v.id)
			if cfg.quality ==  self.selMysticQuality then
				table.insert(screenList, v)
			end
		end
		return self:sortMystic(screenList)
	else
		return self:sortMystic(mystic_ids)
	end
end

function M:sortMystic(tab)
	local id_num_list = {} -- 当前每个相同id秘籍对应的个数
	for i, v in pairs(tab) do
		if id_num_list[v.id] then
			id_num_list[v.id] = id_num_list[v.id] + 1
		else
			id_num_list[v.id] = 1
		end
	end
	table.sort(tab, function(data1,data2) -- 按秘籍品质从低到高排序
		local cfg1 = self:getMysticData(data1.id)
		local cfg2 = self:getMysticData(data2.id)
		local haveNum1 = id_num_list[data1.id] or 1
		local haveNum2 = id_num_list[data2.id] or 1
		if cfg1.quality == cfg2.quality then
			if haveNum1 == haveNum2 then
				if data1.id == data2.id then
					return data1.oid < data2.oid
				else
					return data1.id < data2.id
				end
			else
				return haveNum1 > haveNum2
			end
		else
			return cfg1.quality < cfg2.quality
		end

	end)
	return tab
end

-- 一键添加秘籍
function M:quickAddMystic()
	local all_mystic_ids = self:getAllMysticDataList()
	table.sort(all_mystic_ids, function(data1,data2) -- 按秘籍品质从低到高排序
		local cfg1 = self:getMysticData(data1.id)
		local cfg2 = self:getMysticData(data2.id)
		if cfg1.quality == cfg2.quality then
			if data1.id == data2.id then
				return data1.oid < data2.oid
			else
				return data1.id < data2.id
			end
		else
			return cfg1.quality < cfg2.quality
		end
	end)
	local data = all_mystic_ids[1]
	if data then
		local cfg = self:getMysticData(data.id)
		for i = cfg.quality, cfg.quality+20 do
			local mysticList, num = self:checkMysticNumByQuality(i)
			local needNum = self:screenSynthesisMysticNumByQuality(i)
			if num >= needNum then
				self.selMysticQuality = i -- 手动选择的品质先重置
				self.selMysticList = {}
				for m = 1, #mysticList do
					if table.nums(self.selMysticList) < needNum then
						table.insert(self.selMysticList, mysticList[m].oid)
						if table.nums(self.selMysticList) == needNum then return end
					else
						return
					end
				end
			end
			local s_mysticList, s_num = self:checkMysticNumByQuality(i, 3)
			local s_needNum = self:screenSynthesisMysticNumByQuality(i, 3)
			if s_num >= s_needNum then
				self.selMysticQuality = i -- 手动选择的品质先重置
				self.selMysticList = {}
				for m = 1, #s_mysticList do
					if table.nums(self.selMysticList) < s_needNum then
						table.insert(self.selMysticList, s_mysticList[m].oid)
						if table.nums(self.selMysticList) == s_needNum then return end
					else
						return
					end
				end
			end
		end
	end
end

-- 通过品质获取对应品质的秘籍总个数/ type类型 只区别于神技 
function M:checkMysticNumByQuality(quality, type)
	local screenList = {} -- 当天品质秘籍
	local all_num = 0 -- 当天品质秘籍总数量
	local all_mystic_ids = self:getAllMysticDataList()
	for i, v in pairs(all_mystic_ids) do
		local cfg = self:getMysticData(v.id)
		if cfg.quality ==  quality then
			if type and type == 3 then
				if cfg.type == type then
					table.insert(screenList, v)
					all_num = all_num + 1
				end
			else
				if cfg.type ~= 3 then
					table.insert(screenList, v)
					all_num = all_num + 1
				end
			end
		end
	end
	return self:sortMystic(screenList), all_num
end

-- 通过秘籍品质筛选合成个数
function M:screenSynthesisMysticNumByQuality(quality, type)
	local num = 5
	local synthesisCfg = ConfigManager:getCommonValueById(507)
	if type and type == 3 then
		synthesisCfg = ConfigManager:getCommonValueById(653)
	end
	if quality then
		for i, v in pairs(synthesisCfg) do
			if v[1] == quality then
				num = v[2]
			end
		end
	end
	return num
end

-- 神技合成个数
function M:screenSynthesisMysticNumByType3(quality)
	local num = 5
	local synthesisCfg = ConfigManager:getCommonValueById(653)
	if quality then
		for i, v in pairs(synthesisCfg) do
			if v[1] == quality then
				num = v[2]
			end
		end
	end
	return num
end

-- 获取秘籍的所有属性,并组装
function M:getMysticAllAttr(item_cfg)
	local all_attrs = {} -- 所有属性包括经脉属性顺序排列
	local sort_attrs = {} -- 筛选为两两一组
	all_attrs = table.copy(item_cfg.attrs) or {}
	local meridian = table.copy(item_cfg.meridian) or {}
	for i, v in pairs(meridian) do
		table.insertto(all_attrs, v.attr)
	end
	all_attrs = UserDataManager:appendAttrs(all_attrs) -- 属性id转换成key
	local attr_list = {}
	for i, v in pairs(all_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 通过秘籍id获取buff列表
function M:getMysticBuffGroupById(data_id)
	local buff_group_cfg = {}
	local cfg = self:getMysticData(data_id)
	if cfg then
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		for i, v in pairs(cfg.buff) do
			buff_group_cfg[i] = mystic_buff_cfg[v]
		end
	end
	return buff_group_cfg
end

-- 获得下阶段合成的秘籍的品质
function M:resetMysticNextQuality()
	local next_quality = 0
	for i, oid in pairs(self.selMysticList) do
		local cur_data, cur_cfg = self:getMysticDataByOid(oid)
		next_quality = cur_cfg.next_quality
	end
	self.m_next_quality = next_quality
end

-- 获取秘籍合成概率 
function M:getMysticDepositoryPromote()
	local my_random_type_list = {} -- 要合成的秘籍随机类型
	local next_random_type_list = {} -- 合成后的的秘籍随机类型
	local cur_random_type_list = {} -- 当前阶段所有的秘籍随机类型
	local new_random_type_list = {} -- 排除所有与当前品质相同random_type的下一阶段的秘籍random_type
	local old_random_type_list = {} -- 当前选择列表中和下一阶段相同的random_type
	local new_random_type_rate = 0 -- 新random_type的合成概率
	local old_random_type_rate = 0 -- 旧random_type的合成概率
	local mystic_rate_list = {} -- 能合成的所有秘籍的概率
	local next_quality = 0
	for i, oid in pairs(self.selMysticList) do
		local cur_data, cur_cfg = self:getMysticDataByOid(oid)
		next_quality = cur_cfg.next_quality
		my_random_type_list[cur_cfg.random_type] = my_random_type_list[cur_cfg.random_type] and my_random_type_list[cur_cfg.random_type] + 1 or 1
	end
	next_random_type_list = self:getMysticRandomTypeByQuality(next_quality, true) -- 通过品质计算出同一品质下不同RandomType的秘籍的个数
	cur_random_type_list = self:getMysticRandomTypeByQuality(self.selMysticQuality) -- 通过品质计算出同一品质下不同RandomType的秘籍的个数
	self.m_next_quality = next_quality
	new_random_type_list = table.copy(next_random_type_list) -- 先默认下阶段都是新random_type
	-- 排除所有与当前品质相同random_type的下一阶段的新的秘籍random_type
	for i, v in pairs(next_random_type_list) do
		for m, n in pairs(cur_random_type_list) do
			if i == m then
				new_random_type_list[i] = nil -- 把所有相同random_type的置空
			end
		end
	end
	
	-- 算出当前选择的和下一阶段相同的random_type
	for random_type, count in pairs(my_random_type_list) do
		if next_random_type_list[random_type] then
			old_random_type_list[random_type] = count
		end
	end
	local commonRate = -1
	local common_cfg = ConfigManager:getCfgByName("common")
	local commonRateList = common_cfg[595] and common_cfg[595].value or {}
	for i, v in pairs(commonRateList) do
		if v[1] == next_quality then
			commonRate = v[2]*0.01
		end
	end
	if table.nums(new_random_type_list) > 0 then
		new_random_type_rate = table.nums(new_random_type_list) / table.nums(next_random_type_list)
		if new_random_type_rate ~= 1 and commonRate ~= -1 then
			new_random_type_rate = commonRate   -- 新秘籍概率替换
		end
		old_random_type_rate = 1 - new_random_type_rate
	else
		new_random_type_rate = table.nums(new_random_type_list) / (table.nums(new_random_type_list) + table.nums(old_random_type_list)) -- 新random_type的合成概率
		old_random_type_rate = table.nums(old_random_type_list) / (table.nums(new_random_type_list) + table.nums(old_random_type_list)) -- 旧random_type的合成概率
	end
	local old_random_type_rate_list = {} -- 每一个旧random_type的合成概率
	for random_type, count in pairs(old_random_type_list) do
		local rate = old_random_type_rate * (count/table.nums(self.selMysticList)) -- 旧random_type的总合成概率 * x本同random_type秘籍 / 旧random_type的总数
		old_random_type_rate_list[random_type] = rate
	end
	local new_random_type_rate_list = {} -- 每一个新random_type的合成概率
	local new_mystic_count = 0 -- 能合成的新的秘籍总数
	for random_type, v in pairs(new_random_type_list) do
		local mystic_list = self:getMysticByQualityAndRandomType(next_quality, random_type)
		new_mystic_count = new_mystic_count + #mystic_list
	end
	for random_type, count in pairs(new_random_type_list) do
		local rate = new_random_type_rate / new_mystic_count -- 新random_type的总合成概率 / 新秘籍的总数
		new_random_type_rate_list[random_type] = rate
	end
	local old_random_type_mystic_rate_list ={} -- 每本旧random_type秘籍的概率
	for random_type, rate in pairs(old_random_type_rate_list) do
		local mystic_list = self:getMysticByQualityAndRandomType(next_quality, random_type)
		if #mystic_list > 0 then
			for i, id in pairs(mystic_list) do
				old_random_type_mystic_rate_list[id] = rate/#mystic_list
			end
		end
	end

	local new_random_type_mystic_rate_list ={} -- 每本新random_type秘籍的概率
	for random_type, rate in pairs(new_random_type_rate_list) do
		local mystic_list = self:getMysticByQualityAndRandomType(next_quality, random_type)
		if #mystic_list > 0 then
			for i, id in pairs(mystic_list) do
				new_random_type_mystic_rate_list[id] = rate
			end
		end
	end

	mystic_rate_list = table.copy(old_random_type_mystic_rate_list)
	for id, rate in pairs(new_random_type_mystic_rate_list) do
		if mystic_rate_list[id] then
			Logger.logErrorAlways("秘籍展示概率算错了")
		end
		mystic_rate_list[id] = rate
	end
	local max_rate = 0
	local max_rate_mystic_list = {} -- 合成概率最大的秘籍
	for id, rate in pairs(mystic_rate_list) do
		if rate >= max_rate then
			max_rate = rate -- 找到最大的概率
		end
	end
	for id, rate in pairs(mystic_rate_list) do
		if rate == max_rate then
			max_rate_mystic_list[id] = rate -- 找到最大概率的秘籍
		end
	end
	
	return mystic_rate_list, max_rate_mystic_list
end

-- 通过品质计算出同一品质下不同RandomType的秘籍的个数
function M:getMysticRandomTypeByQuality(quality, nextFlag)
	local mystic_cfg = ConfigManager:getCfgByName("mystic")
	local random_type_list = {}
	local flag, selType = self:getSelMysticType() -- 选择的秘籍type
	for id, v in pairs(mystic_cfg) do
		if v.quality == quality and id > 100000 then
			if flag and nextFlag then
				if selType == 2 and v.type == 2 then
					random_type_list[v.random_type] = random_type_list[v.random_type] and random_type_list[v.random_type] + 1 or 1 -- 相同RandomType的秘籍的个数
				elseif selType == 1 then
					random_type_list[v.random_type] = random_type_list[v.random_type] and random_type_list[v.random_type] + 1 or 1 -- 相同RandomType的秘籍的个数
				end
			else
				random_type_list[v.random_type] = random_type_list[v.random_type] and random_type_list[v.random_type] + 1 or 1 -- 相同RandomType的秘籍的个数
			end
		end
	end
	return random_type_list
end

function M:getMysticByQualityAndRandomType(quality, random_type)
	local mystic_cfg = ConfigManager:getCfgByName("mystic")
	local mystic_list = {}
	for id, v in pairs(mystic_cfg) do
		if v.quality == quality and v.random_type == random_type and id > 100000 then
			table.insert(mystic_list, id)
		end
	end
	return mystic_list
end

function M:getSelMysticType()
	local selType = 0
	local typeNum = 0
	local flag = false
	for i, oid in pairs(self.selMysticList) do
		local cur_data, cur_cfg = self:getMysticDataByOid(oid)
		if cur_cfg and cur_cfg.type ~= selType then
			typeNum = typeNum + 1
			selType = cur_cfg.type
		end
	end
	if typeNum == 1 then
		flag = true
	end
	return flag, selType
end

function M:setFuncTabIndex(id)
	self:resetData()
	self.m_sel_func_tab_index = id
end

function M:getTuiyanCost(quality, oid)
	if not quality then
		return
	end
	local common_ids = {[8] = 605, [12] = 606}
	local common_id = common_ids[quality]
	if oid then
		local cur_data, cur_cfg = self:getMysticDataByOid(oid)
		if cur_cfg.type == 3 then
			common_id = 696
		end
	end
	--Logger.log(quality,"getTuiyanCost quality ===")
	--Logger.log(common_ids[quality],"getTuiyanCost common_ids[quality] ===")
	local data = ConfigManager:getCommonValueById(common_id)
	--Logger.log(data,"getTuiyanCost data ===")
	return RewardUtil:getProcessRewardData(data)
end

--推演
function M:tuiyanScreeningMystic()
	local screenList = {} -- 通过品质筛选后的秘籍列表
	local all_mystic_ids = self:getAllMysticDataList()
	local mystic_ids = {}
	if self.m_sel_tab_index~= 1 then
		for i, v in pairs(all_mystic_ids) do
			local cfg = self:getMysticData(v.id)
			if cfg.type == self.m_sel_tab_index-1 then
				table.insert(mystic_ids,v)
			end
		end
	else
		mystic_ids = all_mystic_ids
	end
	for i, v in pairs(mystic_ids) do
		local cfg = self:getMysticData(v.id)
		if cfg.quality >= 8 or cfg.type == 3 then
			if cfg.push and cfg.push == 1 then
				table.insert(screenList, v)
			end
		end
	end
	return self:sortMystic(screenList)
end

function M:getTuiyanProbability()
	local data, cfg = self:getMysticDataByOid(self.selMysticList[1])
	local xian_num = 0
	local jue_num = 0
	local shen_num = 0
	local all_mystic = ConfigManager:getCfgByName("mystic")
	local season = UserDataManager:getCurSeason()
	for k,v in pairs(all_mystic or {}) do
		if v.quality == cfg.quality and k ~= data.id then
			if v.type == 1 then
				xian_num = xian_num + 1
			elseif v.type == 2 then
				jue_num = jue_num + 1
			elseif season >= 4 and 	v.type == 3 then
				shen_num = shen_num + 1
			end
		end
	end
	--神技秘籍出的概率是同品阶其他秘籍出现概率的1/20
	local total_num = xian_num + jue_num + (shen_num/20)
	local tab = {xian_rate = xian_num/total_num, jue_rate = jue_num/total_num, shen_num = (shen_num/20)/total_num}
	if cfg.type == 3 then
		tab = {xian_rate = 0, jue_rate = 0, shen_num = 1}
	end
	return tab
end

return M
