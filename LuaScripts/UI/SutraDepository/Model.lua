---@class SutraDepositoryModel:OODataBase
local M = class("SutraDepositoryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_tab_index = self.m_params.tab_index or 1
	self.m_index = 1
	self.m_select = {}
	self.m_has_synthesis = false
	self.m_has_up_star = false
	self:updateData()
	if self.m_params.id then
		for i,v in ipairs(self.m_list_data or {}) do
			if v.id == self.m_params.id then
				self.m_index = i
				break
			end
		end
	end
	local mystic_inset = BtnOpenUtil:isBtnOpen(337)
	if mystic_inset then
		local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_inset_finger", 1)
		if show_finger == 1 then
			for i,v in ipairs(self.m_list_data or {}) do
				if UserDataManager.mystic_data:checkMysticInset(v.id) then
					self.m_index = i
					break
				end
			end
		end
	end
end

function M:setSelectIndex(index)
	self.m_index = index
end

function M:getMysticListDataByIndex(index)
	return self.m_list_data[index]
end

function M:getUsedMysticDataByIndex(index)
	return self.m_data.mystic_slots[tostring(index)]
end

function M:setTabIndex(index)
	self.m_tab_index = index
	self.m_index = 1
	self.m_has_synthesis = false
	self.m_has_up_star = false
	self:updateList()
end

function M:updateData()
	self:updateList()
end

--[[
	--1=先天
	--2=绝世
]]
function M:updateList()
	--self.m_show_equips = {}
	local mystic_cfg = ConfigManager:getCfgByName("mystic")
	local mystic_level_cfg =ConfigManager:getCfgByName("mystic_level")
	local mystic_buff_cfg =ConfigManager:getCfgByName("mystic_buff")
	local mystic_star_cfg=ConfigManager:getCfgByName("mystic_star")
	local common_cfg_item=ConfigManager:getCfgByName("common")[832]

	--local equip_ids = UserDataManager.mystic_data:getMysticesId()
	--local hero_ids = UserDataManager.hero_data:getHerosId()
	--for k,v in pairs(mystic_cfg) do
	--	local inlay_mystic = UserDataManager.mystic_data:getInlayMysticData(k)
	--	if inlay_mystic then
	--		for m,n in pairs(inlay_mystic) do
	--			if n.oid then
	--				table.insert(self.m_show_equips, n)
	--			end
	--		end
	--	end
	--end
	
	--for k, v in pairs(hero_ids) do
	--	if v ~= self.m_heroid then
	--		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
	--		local mystics = hero_data.mystics or {}
	--		for m, n in pairs(mystics) do
	--			--n.owner = v
	--			table.insert(self.m_show_equips, n)
	--		end
	--	end
	--end
	--for k, v in pairs(equip_ids) do
	--	local data, cof = UserDataManager.mystic_data:getMysticDataById(v)
	--	if data.oid ~= self.m_mystic_id then
	--		table.insert(self.m_show_equips, data)
	--	end
	--end
	local mystices_data = UserDataManager.mystic_data:getMysticesData()
	self.mystices_tab = {}
	--for k,id in pairs(self.m_show_equips) do
	--	if self.mystices_tab[id] then
	--		self.mystices_tab[id] = self.mystices_tab[id] + 1
	--	else
	--		self.mystices_tab[id] = 1
	--	end
	--end
	
	self.m_list_data = {}
	local sel_type = self.m_tab_index - 1
	local limit_num = self:showShenJi() == true and 3 or 2
	local mystic_lv=1
	local mysticData=nil
	local star_lv=0
	local next_star_cfg=nil
	for k,v in pairs(mystic_cfg) do
		if v.type <= limit_num then --只有 0-1-2
			if v.type == sel_type or sel_type == 0  then
				--local sort_value = 0
				--local synthesis_flag = false
				--local cost_data = {}
				--local cfg = UserDataManager.mystic_data:getMysticConfigByCid(k)
				mysticData=UserDataManager.mystic_data:getMysticDataById(k)
				local num = self.mystices_tab[k] or 0
				--不爲空不在后台传来的列中説明已經激活
				if mysticData~=nil then
					mystic_lv=mysticData.lv
					if mysticData.star then
						star_lv=mysticData.star
					end
				end
				local params = {}
				params.id = k
				params.cfg = v

				params.data = mysticData
				params.mystic_lv=mystic_lv
				params.cur_cfg_lv = mystic_level_cfg[k][mystic_lv]
				params.next_cfg_lv = mystic_level_cfg[k][mystic_lv+1]
				if params.next_cfg_lv==nil then
					Logger.log("sddsf")
				end

				params.star_cfg=mystic_star_cfg[k][star_lv]
				next_star_cfg=mystic_star_cfg[k][star_lv+1]
				params.next_star_cfg=next_star_cfg
				params.star_lv=star_lv
				if mystic_buff_cfg[k]==nil then
					Logger.log(k,"mystic_buff_cfg is nil")
				end
				if params.star_cfg==nil then
					Logger.log("sddsfd")
				end
				params.mystic_buff_cfg1=mystic_buff_cfg[params.star_cfg.buff[1]]
				if params.star_cfg.buff[2] then
					params.mystic_buff_cfg2=mystic_buff_cfg[params.star_cfg.buff[2]]
				end
				params.num = num
				params.alive=mysticData~=nil
				params.canBreakStar=self:getCanBreakStar(next_star_cfg,mystic_lv)
				params.breakDiffValue=self:getBreakDiffValue(next_star_cfg,mystic_lv)

				params.canEquipNum=common_cfg_item.value[star_lv+1]
				params.nextCanEquipNum=common_cfg_item.value[star_lv+2] or params.canEquipNum
				params.isMaxStarLv=next_star_cfg==nil and mystic_lv==GlobalConfig.MYSTIC_MAX_LV
				if num > 0 then
					params.have = 1
				else
					params.have = 0
				end
				self.m_list_data[#self.m_list_data + 1] = params
				mysticData=nil
				star_lv=0
			end
		end
	end
	-- 秘籍排序顺序 拥有>品质>id
	local function sortFunc(data1,data2)
		--local have1 = data1.have or 0
		--local have2 = data2.have or 0
		--local quality1 = data1.cfg.quality
		--local quality2 = data2.cfg.quality
		if data1.alive==true and data2.alive==false then
			return true
		else
			if data1.alive==data2.alive then
				return data1.id > data2.id
			else
				return false
			end
		end

	end
	Logger.log("sdsfd")
	table.sort(self.m_list_data,sortFunc)
end


function M:getCanBreakStar(mystic_star_cfg_item,curLv)
	if mystic_star_cfg_item then
		return mystic_star_cfg_item.break_level<=curLv
	else
		return GlobalConfig.MYSTIC_MAX_LV<=curLv
	end
end

function M:getBreakDiffValue(mystic_star_cfg_item,curLv)
	return mystic_star_cfg_item and mystic_star_cfg_item.break_level-curLv or GlobalConfig.MYSTIC_MAX_LV-curLv
end

--当前选中是否先天秘籍
function M:curIsXianTian()
	local data=self.m_list_data[self.m_index]
	return data.cfg.type==1
end


function M:getNextStarBuffDetail()
	local buff_cfg=ConfigManager:getCfgByName("mystic_buff")
	local data=self.m_list_data[self.m_index]
	local buffs=data.next_star_cfg.buff
	local name=buff_cfg[buffs[1]].name
	local des=""
	for i, buff_id in pairs(buffs) do
		local _des=Language:getTextByKey(buff_cfg[buff_id].des)
		if des~="" then
			des=des.."\n".._des
		else
			des=_des
		end
	end
	return name,des

end

function M:getBuffNameById(buff_id)
	local buff_cfg=ConfigManager:getCfgByName("mystic_buff")
	return buff_cfg[buff_id].name
end

--判断强化和解锁消耗碎片是否满足数目
function M:judgeCurSelectedMysticChipNum()
	local data=self.m_list_data[self.m_index]
	local itemData =nil
	local needNum=nil
	local meetCondition=true
	local lackNum=0
	--突破
	if data.alive then
		itemData =UserDataManager.item_data:getItemDataById(data.next_star_cfg.cost[1][2])
		needNum=data.next_star_cfg.cost[1][3]
		meetCondition= itemData.num>=needNum
	--解锁
	else
		itemData =UserDataManager.item_data:getItemDataById(data.cfg.chip_id)
		needNum=data.cfg.chip_num
		meetCondition= itemData.num>=needNum
	end
	lackNum=needNum-itemData.num
	return meetCondition,lackNum
end


function M:getCanMysticUpgradeById(id)
	local flag = false
	local mystic_slots = self.m_data.mystic_slots or {}
	local mystic_slots_item = mystic_slots[tostring(id)] or {}
	local lv = mystic_slots_item.lv or 1
	local mystic_upgrade_cfg = ConfigManager:getCfgByName("mystic_upgrade")
	local mystic_upgrade_cfg_item = mystic_upgrade_cfg[lv+1]
	if mystic_upgrade_cfg_item then
		local consumes = mystic_upgrade_cfg_item.consumes or {}
		local consume_item = consumes[tonumber(id)] or {}
		if #consume_item > 0 then
			local cost_data = RewardUtil:getProcessRewardData(consume_item[1])
			if cost_data.user_num >= cost_data.data_num then
				flag = true
			end
		end
	end
	return flag
end

function M:getNeddAlertById(id)

	local mystic_slots = self.m_data.mystic_slots or {}
	local mystic_slots_item = mystic_slots[tostring(id)] or {}
	if mystic_slots_item.need_alert ~= nil and mystic_slots_item.need_alert == 1 then
		return true
	else
		return false
	end
	return false
	
end

function M:getRedPoint(index)
	local sel_type = index - 1
	local limit_num = self:showShenJi() == true and 3 or 2
	local mystic_cfg = ConfigManager:getCfgByName("mystic")
	for k,v in pairs(mystic_cfg) do
		if v.type <= limit_num then --只有 0-1-2
			if v.type == sel_type or sel_type == 0  then
				-- Exhibition==1的秘籍不展示
				if v.Exhibition and v.Exhibition ~= 1 then
					if self:checkMysticNewRedPoint(k) then
						return true
					end
				end
			end
		end
	end
	return false
end

function M:checkMysticNewRedPoint(id)
	--if UserDataManager.mystic_data.m_new_ids[tostring(oid)] and UserDataManager.mystic_data.m_new_ids[tostring(oid)] == 1 then
	--	return true
	--end
	if self.mystices_tab[id] and self.mystices_tab[id] > 0 then
		if UserDataManager.mystic_data:checkMysticInset(id) then
			local slot_num = ConfigManager:getCommonValueById(732, 9)
			local inlay_mystic = UserDataManager.mystic_data:getInlayMysticData(id)
			local has_slot = false
			for i=1, slot_num do
				if inlay_mystic then
					local one_data = inlay_mystic[i]
					if not one_data.oid then
						has_slot = true
						break
					end
				else
					has_slot = true
					break
				end
			end
			if has_slot then
				local ids = UserDataManager.mystic_data:getMysticesId()
				for i,v in pairs(ids) do
					local data, cof = UserDataManager.mystic_data:getMysticDataById(v)
					if cof.quality >= 12 then
						return true
					end
				end
			end
		end
	end
	return false
end

--是否显示神技秘籍
function M:showShenJi()
	local season = UserDataManager:getCurSeason()
	return season >= 3
end


--基础属性
function M:getAllAttr()
	local show_data = {}
	local data = self:getMysticListDataByIndex(self.m_index)
	local mystic_data, cfg_lv = data.data, data.cur_cfg_lv
	show_data = cfg_lv.attrs or {}

	--local mystic_data, cfg = data.data, data.cfg
	--show_data = cfg.attrs or {}
	return show_data
end

--经脉属性
function M:getChannelAttr()
	local show_data = {}
	local data = self:getMysticListDataByIndex(self.m_index)
	local mystic_data, mystic_cfg = data.data, data.cfg
	local channel_lv = 0
	local sigData = {} -- 经脉数据
	if self.m_heroid then
		sigData = UserDataManager.hero_data:getSigDataByHeroOid(self.m_heroid)
	end
	for i, v in pairs(mystic_cfg.meridian) do
		local channel = sigData[tostring(i)] -- i 是经脉类型 -- 1.冲、2：带、3：任、4：督
		channel_lv = channel and channel.lv or 0
		local activation = v.activation
		for m = 1, #activation do
			show_data[#show_data + 1] = {lv = activation[m],channel_lv = channel_lv, attr = v.attr[m], meridian_type = i, mystic_type = mystic_cfg.type, open = channel_lv >= activation[m]}
		end
	end
	return show_data
end

-- 镶嵌属性
function M:getInsetAttr()
	local data = self:getMysticListDataByIndex(self.m_index)
	local show_data = UserDataManager.mystic_data:getMysticInsetAllAttrs(data.id)
	return show_data
end

-- 奥义解放
function M:getInsetSkillAttr()
	local data = self:getMysticListDataByIndex(self.m_index)
	local show_data = UserDataManager.mystic_data:getMysticInsetSkillEffect(data.id)
	return show_data
end

function M:getInsetSlot()
	local slot_num = ConfigManager:getCommonValueById(732, 9)
	local data = self:getMysticListDataByIndex(self.m_index)
	local inlay_mystic = UserDataManager.mystic_data:getInlayMysticData(data.id)
	local list = {}
	for i=1, slot_num do
		if inlay_mystic then
			local one_data = inlay_mystic[i]
			if one_data then
				table.insert(list, one_data)
			else
				table.insert(list, {})
			end
		else
			table.insert(list, {})
		end
	end
	return list
end

return M
