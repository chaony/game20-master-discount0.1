local M = class("MysticPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("mystic_index")
end

function M:onEnter()
	Logger.log(self.m_data,"data ====")
	self.m_tab_index = self.m_params.tab_index or 1
	self.m_select = {}
	self:updateData()
	self:reset()
	if self.m_params.evoluation_oid then
		self:AddMystic(self.m_params.evoluation_oid)
	end
end

function M:getUsedMysticDataByIndex(index)
	return self.m_data.mystic_slots[tostring(index)]
end

function M:setTabIndex(index)
	self.m_tab_index = index
	if index == 2 then
		self:reset()
	end
end

function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end

	local effect = UserDataManager.mystic_effect_data
	Logger.log(effect,"effect ====")
	local group_effect = {}
	for i,v in ipairs(effect) do
		if v[1] == 2 then -- 1单本秘籍效果， 2套装效果
			group_effect[#group_effect + 1] = v
		end
	end
	self.m_group_effect = group_effect
end

function M:reset()
	self.m_select = {}
	self.m_need_count = 0
	self.m_need_evo = 0
	self.m_recommend_id = 0
	
	self:updateList()
end

function M:AddMystic(oid)
	local data, cfg = UserDataManager.mystic_data:getMysticDataById(oid)
	-- Logger.log(heroData,"heroData ====")
	-- Logger.log(cfg,"cfg ====")
	if #self.m_select == 0 then
		local mystic_evo = ConfigManager:getCfgByName("mystic_evo")
		local evo_data = mystic_evo[data.evo].consume
		if evo_data == nil or #evo_data == 0 then
			return 3 -- 已达到最高阶
		end
		self.m_need_count = evo_data[1] + 1
		self.m_need_evo = evo_data[2]
		self.m_recommend_id = data.id
		self.m_select[1] = oid

		self:updateList()
		return 0, 1
	end
	for i=1,self.m_need_count do
		if self.m_select[i] == nil then
			if self.m_need_evo == data.evo then
				self.m_select[i] = oid
				return 0, i
			else
				return 1 -- 非材料卡
			end
			break
		end
	end
	return 2 -- 材料满
end

function M:removeMystic(oid)
	for i=1,self.m_need_count do
		if self.m_select[i] == oid then
			if i == 1 then
				self:reset()
			else
				self.m_select[i] = nil
			end
			return i
		end
	end
end

function M:updateList()
	local mystices = {}
	mystices = table.copy(UserDataManager.mystic_data:getMysticesId())

	self.m_red_point_card_ids = {}
	local canUp = {}
	local maxUp = {}
	for i=#mystices,1,-1 do
		local data, cfg = UserDataManager.mystic_data:getMysticDataById(mystices[i])
		local flag = true
		if #self.m_select > 0  and self.m_select[1] ~= mystices[i] then
			if data.evo ~= self.m_need_evo or data.is_active == 1 then
				table.remove(mystices,i)
				flag = false
			end
		end

		if flag then
			-- if RedPointUtil:isHeroAdvanced(heros[i]) then
			-- 	canUpHeros[#canUpHeros + 1] = heros[i]
			-- 	self.m_red_point_card_ids[heros[i]] = 1
			-- 	table.remove(heros,i)
			-- elseif heroData.evo >= cfg.max_evo then
			-- 	maxUpHeros[#maxUpHeros + 1] = heros[i]
			-- 	table.remove(heros,i)
			-- end
		end
	end

	self.m_list_data = canUp
	for i,v in ipairs(mystices) do
		self.m_list_data[#self.m_list_data + 1] = v
	end
	for i,v in ipairs(maxUp) do
		self.m_list_data[#self.m_list_data + 1] = v
	end
end

function M:isSelected(oid)
	for i,v in pairs(self.m_select) do
		if v == oid then
			return true
		end
	end
	return false
end

function M:getOneKeyData()
	if self.m_data.select_mystic.fixed and #self.m_data.select_mystic.fixed > 0 then
		return 1, self.m_data.select_mystic.fixed
	end
	if self.m_data.select_mystic.random and #self.m_data.select_mystic.random > 1 then
		return 2, self.m_data.select_mystic.random
	end
end

function M:getRedPoint(index)
	if index == 1 then
		for i=1,5 do
			local data = self:getUsedMysticDataByIndex(i-1)
			if data == nil then
				local mystic_ids = UserDataManager.mystic_data:getMysticesId()
				for ii,v in ipairs(mystic_ids) do
					local data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
					local slot_type = i-1
					if slot_type == 0 or cfg[1].type == slot_type then
						return true
					end
				end
			end
		end
		return false
	elseif index == 2 then
		if self.m_data.select_mystic.fixed and #self.m_data.select_mystic.fixed > 0 then
			return true
		elseif self.m_data.select_mystic.random and #self.m_data.select_mystic.random > 0 then
			return true
		end
		return false
	end
	return false
end

return M
