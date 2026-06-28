local M = class("TitleAttributePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

-- 称号收集属性
function M:getTitleCollectAttrById(title_id)
	local attr = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	if title_cfg[title_id] then
		attr = title_cfg[title_id].attr1
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return attr
end

function M:onEnter()
	local titleData = self.m_params.titleData or {}
	local numerAttrList = {}
	local sortAttrList = {}
	self.m_attrsList = {}
	local arenaLevel = 0
	local titleXlsxData = ConfigManager:getCfgByName("title")
	for _, itemData in pairs(titleData) do
		local collect_cfg_attrs = self:getTitleCollectAttrById(itemData.id)
		if table.nums(collect_cfg_attrs) > 0 then
			for _, attrInfo in pairs(collect_cfg_attrs) do
				local attrId = attrInfo[1]
				local attrValue = attrInfo[2]
				if numerAttrList[attrId] == nil then
					numerAttrList[attrId] = attrValue
				else
					numerAttrList[attrId] = numerAttrList[attrId] + attrValue
				end
			end
		end
		local itemXlsxData = titleXlsxData[itemData.id] or {}
		if itemXlsxData.level_up and itemXlsxData.level_up > 0 then
			arenaLevel = arenaLevel + itemXlsxData.level_up
		end
	end
	local hero_enumerationData = ConfigManager:getCfgByName("hero_enumeration")
	for attrId, attrValue in pairs(numerAttrList) do
		table.insert(sortAttrList, {attrId, attrValue})
	end
	if table.nums(sortAttrList) > 0 then
		table.sort(sortAttrList, function(itemData1, itemData2)
			return itemData1[1] < itemData2[1]
		end)
		for _, itemAttrData in pairs(sortAttrList) do
			local id = itemAttrData[1]
			local value = itemAttrData[2]
			local itemXlsxData = hero_enumerationData[id]
			if itemXlsxData.base_on_id and itemXlsxData.base_on_id > 0 then
				id = itemXlsxData.base_on_id
				value = value * 100
			else
				if itemXlsxData.is_percent and itemXlsxData.is_percent == 1 then
					value = value * 100
				end
			end
			local nameXlsxData = itemXlsxData.name
			if itemXlsxData.name1 ~= nil and itemXlsxData.name1 ~= "" then
				nameXlsxData = itemXlsxData.name1
			end
			local attrName = Language:getTextByKey(nameXlsxData)		
			-- 四舍五入保留小数点后一位
			local attr_value = value or 0
			local attrValue = nil
			attr_value = math.floor(attr_value * 10 + 0.5)/10
			if itemXlsxData.is_percent and itemXlsxData.is_percent == 1 then
				attrValue = GameUtil:formatNum(attr_value).."%"
			else
				attrValue = GameUtil:formatNum(attr_value)
			end
			if itemXlsxData.user_key == "critrate" then     -- 暴击（特殊）
				attrValue = attrValue .. "%"
			end
			table.insert(self.m_attrsList, {attrName, attrValue})
		end
	end
	if arenaLevel > 0 then
		table.insert(self.m_attrsList, {Language:getTextByKey("titleAtr_text_0002"), arenaLevel})
	end
end

return M
