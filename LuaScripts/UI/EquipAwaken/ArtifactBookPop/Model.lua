local M = class("ArtifactBookPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.tag_index = 1
	local artifact_book_quick_lv = UserDataManager.local_data:getUserDataByKey("artifact_book_quick_lv", 0)
	self.quick_lv_up = artifact_book_quick_lv == 1 --一键升级
	local lv_top = UserDataManager.hero_data:getLevelTop()
	if next(lv_top) == nil then
		self.m_unlock_lv = UserDataManager.m_clv	
	elseif lv_top[5] then
		self.m_unlock_lv = lv_top[5][2]
	else
		self.m_unlock_lv = 0
	end
end

--开启图鉴升级
function M:openEquipLvUp()
	if self.m_unlock_lv < 300 then
		return false
	end
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local cry_data = crystal_upgrade[self.m_unlock_lv] 
	return cry_data.display_level >= 300
end


function M:getTagList()
	local tag_tab = ConfigManager:getCfgByName("equip_throne")
	local tag_cfg = tag_tab[self.tag_index] or  tag_tab[1]
	return tag_cfg
end

function M:checkEquipThroneById(equip_id)
	for k,v in pairs(UserDataManager.m_thrones) do
		for kk,vv in pairs(v) do
			if equip_id == vv then
				return true
			end
		end
	end
	return false
end

--完成度
function M:degreeOfCompletion()
	local tag_tab = ConfigManager:getCfgByName("equip_throne")
	local tag_cfg = tag_tab[self.tag_index]
	local get_num =  0
	if UserDataManager.m_thrones[tostring(self.tag_index)] then
		get_num = #UserDataManager.m_thrones[tostring(self.tag_index)]
	end
	local num = get_num/#tag_cfg.eqiup_id
	return math.floor(num*100) 
end

--收集属性
function M:getShowAttrs()
	local tag_tab = ConfigManager:getCfgByName("equip_throne")
	local tag_cfg = tag_tab[self.tag_index]
	local get_num =  0
	if UserDataManager.m_thrones[tostring(self.tag_index)] then
		get_num = #UserDataManager.m_thrones[tostring(self.tag_index)]
	end
	local attr = table.copy(tag_cfg.add_advance)
	for k,v in pairs(attr) do
		v[2] = v[2]*get_num
	end
	local attr_str = ""
	for k,v in pairs(attr) do
		local atk_cfg = GameUtil:getAttrCfg(v[1])
		local atk_name = Language:getTextByKey(atk_cfg.name)
		attr_str = attr_str..""..atk_name.."+"..GameUtil:formatValueToString(v[2]).."  "
	end
	return attr_str
end

--图鉴属性
function M:getShowAttrs2()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo]
	local attr = table.copy(cur_throne.attr2)
	local attr_str = ""
	for k,v in pairs(attr) do
		local atk_cfg = GameUtil:getAttrCfg(v[1])
		local atk_name = Language:getTextByKey(atk_cfg.name)
		local cur_num = v[2]
		if GameUtil:canPerAttrTransition(atk_cfg.user_key) == true then
			cur_num = cur_num*100
		end
		if GameUtil:attrTransition(atk_cfg.user_key) == true then 
			attr_str = attr_str..""..atk_name.."+"..cur_num.."%  "
		else
			attr_str = attr_str..""..atk_name.."+"..cur_num.."  "
		end
	end
	return attr_str
end


--完成度2
function M:degreeOfCompletion2()
	local tag_tab = ConfigManager:getCfgByName("equip_throne")
	local tag_cfg = tag_tab[self.tag_index]
	local get_num =  0
	if UserDataManager.m_thrones[tostring(self.tag_index)] then
		get_num = #UserDataManager.m_thrones[tostring(self.tag_index)]
	end
	return get_num.."/"..#tag_cfg.eqiup_id
end

function M:getEquipDataByIndex(index)
	local tag_cfg = self:getTagList()
	if tag_cfg.eqiup_id and tag_cfg.eqiup_id[index] then
		local equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(tag_cfg.eqiup_id[index])
		if equip_cfg then
			return equip_cfg
		end
	end
	return nil
end

function M:getThronsUpgrade()
	return UserDataManager.m_thrones_upgrade
end

--当前强化等级
function M:getThronslvByIndex(id)
	if next (UserDataManager.m_thrones_upgrade) == nil then
		return 0
	end
	if UserDataManager.m_thrones_upgrade.level and UserDataManager.m_thrones_upgrade.level[tostring(id)] then
		return UserDataManager.m_thrones_upgrade.level[tostring(id)].lv or 0
	end
	return 0
end

--当前等级上限
function M:getThronsMaxlvByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo]
	return cur_throne.limit
end

--当前展示品质等级
function M:getThronsShowQualityByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo] or {}
	return cur_throne.show_quality or 0
end

--当前品质
function M:getThronsQualityLevelByIndex()
	if next (UserDataManager.m_thrones_upgrade) == nil then
		return 0
	end
	return UserDataManager.m_thrones_upgrade.evo or 0
end

--练武场等级限制
function M:getLvUpLock()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local quality = self:getThronsQualityLevelByIndex()
	local throne_cfg = tag_tab[quality]
	local cry_data = crystal_upgrade[throne_cfg.hero_level] 
	if cry_data then
		return cry_data.display_level or 0
	end
	return 0
end

--检测练武场是否达到
function M:checkCryLv()
	local lock_lv = self:getLvUpLock()
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local quality = self:getThronsQualityLevelByIndex()
	local cry_data = crystal_upgrade[self.m_unlock_lv] 
	return cry_data.display_level >= lock_lv
end

--当前星级
function M:getThronsStarByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo] 
	return cur_throne.star
end

--升级消耗
function M:getThronsConsByIndex(id) 
	local lv = self:getThronslvByIndex(id)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_level")
	return tag_tab[lv].consume or {}
end

--一键升级消耗
function M:getQuickLvThronsConsByIndex(id) 
	local lv = self:getThronslvByIndex(id)
	local max_lv = self:getThronsMaxlvByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_level")
	local cons_tab = {}
	local sav_num =  0
	local sav_num2 =  0
	for i = lv, max_lv-1 do
		local cur_cons = tag_tab[i].consume
		local cons_data1 = RewardUtil:getProcessRewardData(cur_cons[1])
		local cons_data2 = RewardUtil:getProcessRewardData(cur_cons[2])
		if cons_tab[1] then
			sav_num = cons_tab[1][3]
		end
		if cons_tab[2] then
			sav_num2 = cons_tab[2][3]
		end
		if cons_data1.user_num >= (cons_data1.data_num+sav_num) and cons_data2.user_num >= (cons_data2.data_num+sav_num2) then
			if cons_tab[1] then
				cons_tab[1][3] = sav_num + cons_data1.data_num
			else
				cons_tab[1] = table.copy(cur_cons[1]) 
			end
			if cons_tab[2] then
				cons_tab[2][3] = sav_num2 + cons_data2.data_num
			else
				cons_tab[2] = table.copy(cur_cons[2])
			end
		else
			if next(cons_tab) == nil then
				return cur_cons
			end
			return cons_tab
		end
	end
	if next(cons_tab) == nil then
		return self:getThronsConsByIndex(id)
	end
	return cons_tab
end

--赛季控制
function M:checkSeason()
	local cue_season = UserDataManager:getCurSeason()
	local cur_stage = UserDataManager:getCurStage()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
    local quality = UserDataManager.m_thrones_upgrade.evo or 0
    local throne_cfg = tag_tab[quality]
	local unlock3 = throne_cfg.unlock_condition_param3 or 0
    if (cue_season < throne_cfg.season) and (unlock3 <= 0 or unlock3 > cur_stage) then --赛季未解锁，且，超前开启未设置或者设置了但不满足
        return false
    end
	return true
end

--下一条数据的赛季控制
function M:checkSeasonForNextQulity()
	local cue_season = UserDataManager:getCurSeason()
	local cur_stage = UserDataManager:getCurStage()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local quality = UserDataManager.m_thrones_upgrade.evo or 0
	local throne_cfg = tag_tab[quality + 1] or {} --quality已经是最大值时，返回false，不展示红点
	local unlock3 = throne_cfg.unlock_condition_param3 or 0
	if (throne_cfg.season and cue_season >= throne_cfg.season) or (unlock3 > 0 and cur_stage >= unlock3) then --满足赛季解锁，或者，满足超前解锁
		return true
	end
	return false
end

function M:getLockSeason()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
    local quality = UserDataManager.m_thrones_upgrade.evo or 0
    local throne_cfg = tag_tab[quality]
	return throne_cfg.season
end

--加成属性
function M:getThronsAttrByIndex() 
	local lv = self:getThronslvByIndex(self.tag_index)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_level")
	return tag_tab[lv].equip_throne[self.tag_index] or {}
end

--根据等级获得加成属性
function M:getThronsAttrByIndexAndLv(lv)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_level")
	return tag_tab[lv].equip_throne[self.tag_index] or {}
end

function M:equipBookAttrRatioById(attr_id) 
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local hero_enumeration_tab = ConfigManager:getCfgByName("hero_enumeration")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo] 
	if cur_throne then
		for k,v in pairs(cur_throne.attr1) do
			local enum_attr = hero_enumeration_tab[v[1]]
			if enum_attr.base_on_id == attr_id then
				return v[2]
			end
		end
	end
	return 0
end


--当前页签是否满级
function M:checkIsMaxLv()
	local max_lv = self:getThronsMaxlvByIndex()
	local lv = self:getThronslvByIndex(self.tag_index)
	return lv >= max_lv
end

--是否可以进阶
function M:checkCanAdvanced() 
	local need_lv = self:getThronsMaxlvByIndex()
	--所有种类图鉴达到等级上限
	for i = 1 ,6 do 
		local lv = self:getThronslvByIndex(i)
		if lv < need_lv then
			return false
		end
	end
	return true
end

--是否可以升级(检测资源)
function M:checkCanLvUp() 
	local cons = self:getThronsConsByIndex(self.tag_index)
    if next(cons) ~= nil then
        local cons_data1 = RewardUtil:getProcessRewardData(cons[1])
        local cons_data2 = RewardUtil:getProcessRewardData(cons[2])
		return cons_data1.user_num >= cons_data1.data_num and cons_data2.user_num >= cons_data2.data_num
    end	
	return false
end

--是否可以升级(检测资源)
function M:checkCanLvUpByTag(index) 
	local cons = self:getThronsConsByIndex(index)
    if next(cons) ~= nil then
        local cons_data1 = RewardUtil:getProcessRewardData(cons[1])
        local cons_data2 = RewardUtil:getProcessRewardData(cons[2])
		return cons_data1.user_num >= cons_data1.data_num and cons_data2.user_num >= cons_data2.data_num
    end	
	return false
end

--是否可以进阶(检测资源)
function M:getThronsConsByIndex2() 
	local lv = self:getThronslvByIndex(self.m_type_index)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local quality = self:getThronsQualityLevelByIndex()
	local cons = tag_tab[quality].consume or {}
	if next(cons) ~= nil then
        local cons_data1 = RewardUtil:getProcessRewardData(cons[1])
        local cons_data2 = RewardUtil:getProcessRewardData(cons[2])
		return cons_data1.user_num >= cons_data1.data_num and cons_data2.user_num >= cons_data2.data_num
    end	
	return false
end

function M:getBookTips()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_inherit")
	local throne_tab = {}
	for k,v in pairs(tag_tab) do
		table.insert( throne_tab, {quality = k, ratio = v.ratio})
	end
	local function sortFunc(id_one, id_two)
		return id_one.quality > id_two.quality
    end
	table.sort(throne_tab, sortFunc)
	local show_text = ""
	local temp_str = Language:getTextByKey("equip_awake_010")
	for k,v in ipairs(throne_tab) do 
		local eqp_q = GlobalConfig.QUALITY_COMMON_SETTING[v.quality]
		local qu_text = Language:getTextByKey("equip_quality_str_00"..v.quality)
		local cur_text = string.format(temp_str, qu_text, GameUtil:formatNum(v.ratio*100))
		show_text = show_text..cur_text.."\n"
	end
	return show_text
end

return M
