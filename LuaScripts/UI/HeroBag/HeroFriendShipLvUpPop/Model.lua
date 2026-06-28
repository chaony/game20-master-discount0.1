local M = class("HeroFriendShipLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

M.dataTime = 22

function M:onEnter()
	self.order_data = self.m_params.order_data
	self.hero_id = self.m_params.hero_id
	self.attrsData = self.m_params.friendLevelUpParams
	self.new_data = UserDataManager.m_friendliness[tostring(self.hero_id)] 
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.hero_id)
	self.m_last_combat = self.m_params.last_combat or 0
	self.m_cur_combat = self.m_params.cur_combat or 0
	self.m_hero_skin_data = self.m_params.hero_skin_data or ""
end

function M:getOrderFetterLv()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[self.m_hero_cfg.role_type or 1]
		return fet_tab[self.order_data.lv]
	end
	return nil
end

function M:getHeroCfg(id)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
	return cfg
end

function M:getNewFetterLv()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[self.m_hero_cfg.role_type or 1]
		return fet_tab[self.new_data.lv]
	end
	return nil
end

function M:unlockFunc()
    local str = ""
	local is_legend = false
	local hero_fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local hero_tab = hero_fetters_tab[self.hero_id] or hero_fetters_tab[101]
	for i = self.order_data.lv+1, self.new_data.lv do
		local cur_cfg = hero_tab[i]
		if cur_cfg.dialogue and #cur_cfg.dialogue > 0 then
			str = self:getDoalogueName(cur_cfg.dialogue) 
		end
		if cur_cfg.legend_id and next(cur_cfg.legend_id) ~= nil then
			for l_i = 1, #cur_cfg.legend_id do
				local legen_cfg = self:getHeroLegendCfg(cur_cfg.legend_id[l_i])
				str = str..Language:getTextByKey(legen_cfg.legend_name)
				is_legend = true
			end
		end
	end
    return str, is_legend
end

--解锁的语音
function M:unlockDialogue()
	local hero_fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local hero_tab = hero_fetters_tab[self.hero_id] or hero_fetters_tab[101]
	for i = self.order_data.lv+1, self.new_data.lv do
		local cur_cfg = hero_tab[i]
		if cur_cfg.dialogue and #cur_cfg.dialogue > 0 then
			local fetters_tab = ConfigManager:getCfgByName("random_disposition")
			local fetter_cfg = fetters_tab[tonumber(cur_cfg.dialogue)]
			return fetter_cfg
		end
	end
	return nil
end

function M:getLevelUpAttrDataByLevel()
	local orderLv = self.order_data.lv
	orderLv = orderLv > 0 and orderLv or 1
	local newLv = self.new_data.lv
	local m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.hero_id)
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	local heroEnumeration = ConfigManager:getCfgByName("hero_enumeration")
	local addAttrData = {}
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[m_hero_cfg.role_type or 1]
		for i = orderLv, newLv do
			for _, itemData in pairs(fet_tab[i].Meridian_attr) do
				local attrKeyId = itemData[1]
				addAttrData[attrKeyId] = itemData[2]
			end
		end
	end
	local oldAttrData = {}
	for _, itemData in pairs(self.attrsData) do
		oldAttrData[itemData.attrKeyId] = {
			curNum = itemData.curAttrNumber,
			attrValue = itemData.attrValue,
		}
	end
	local tempData = {}
	for attrId, attrValue in pairs(addAttrData) do
		local key = GameUtil:getAttrsKey(attrId)
		local name = GameUtil:getAttrsName(key)
		local curData = oldAttrData[attrId]
		local curNum = (curData == nil) and 0 or curData.curNum
		local curTempValue = self:friendLikeValueFormat(key, curNum)
		local curAttrValue = (curData == nil) and -1 or curData.attrValue

		local lastTempValue = self:friendLikeValueFormat(key, attrValue)
		local lastAddAttrValue = -1
		if curAttrValue > 0 then
			if curNum > 0 then
				lastAddAttrValue = (curAttrValue / (1 + curNum)) * attrValue
			else
				lastAddAttrValue = (curAttrValue * attrValue)
			end
		end
		if lastAddAttrValue > 0 then
			lastAddAttrValue = math.floor(lastAddAttrValue)
			lastTempValue = lastTempValue .. "("..lastAddAttrValue..")"
		end
		local curAttrId = attrId
		local base_on_id = heroEnumeration[curAttrId].base_on_id
		curAttrId = base_on_id > 0 and base_on_id or curAttrId
		table.insert(tempData,{
			attrsName = name,
			curNum = curTempValue,
			lastNum = lastTempValue,
			isNotChange = (curNum == attrValue),
			attrId = curAttrId,
		})
	end
	table.sort(tempData, function(itemData1, itemData2)
		if itemData1.attrId ~= itemData2.attrId then
			return itemData1.attrId < itemData2.attrId
		end
	end)
	return tempData
end

-- 好感度属性格式化
function M:friendLikeValueFormat(attrKey, num)
	if num <= 0 then
		return tostring(num)
	end
	if GameUtil:canPerAttrTransition(attrKey) == true then
		num = GameUtil:formatNum(num * 100)
	end
	if GameUtil:attrTransition(attrKey) == true then
		return tostring(num).."%"
	end
	return tostring(num)
end

function M:getDubbingText()
	local hero_fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local hero_tab = hero_fetters_tab[self.hero_id] or hero_fetters_tab[101]
	local friendLevelData = hero_tab[self.order_data.lv+1]
	if friendLevelData and friendLevelData.dialogue and friendLevelData.dialogue ~= "" then
		local hero_fetters_tab = ConfigManager:getCfgByName("random_disposition")
		-- 策划说每条只会填一个id
		local audioId = tonumber(friendLevelData.dialogue)
		if hero_fetters_tab[audioId] then
			return hero_fetters_tab[audioId].lines
		end
	end
	return nil
end

function M:getDoalogueName(id)
	local fetters_tab = ConfigManager:getCfgByName("random_disposition")
	if fetters_tab[tonumber(id)] then
		local cur_fetter = fetters_tab[tonumber(id)]
		return cur_fetter.name
	else
		return id	
	end
end


function M:getHeroLegendCfg(id)
	local hero_legend_tab = ConfigManager:getCfgByName("hero_legend")
	local hero_tab = hero_legend_tab[self.hero_id] or hero_legend_tab[101]
	return hero_tab[id]
end


function M:getRewards()
	local new_tab = {}
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[1]
		local c_reward = table.copy(fet_tab[self.new_data.lv]) 
		if c_reward then
			for k,v in pairs(c_reward.item_id) do
				self:AddRewards(new_tab, v)
			end
		end
		-- for i = self.order_data.lv, self.new_data.lv do
		-- 	local c_reward = table.copy(fet_tab[i]) 
		-- 	if c_reward then
		-- 		for k,v in pairs(c_reward.item_id) do
		-- 			self:AddRewards(new_tab, v)
		-- 		end
		-- 	end
		-- end
	end
	return new_tab
end

function M:AddRewards(tab,reward)
	for k,v in pairs(tab) do
		if v[1] == reward[1] and v[2] == reward[2] then
			v[3] = v[3] + reward[3]	
			return
		end
	end
	table.insert( tab, reward)
end

return M
