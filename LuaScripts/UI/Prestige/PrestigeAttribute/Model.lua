---@class PrestigeAttributeModel : OODataBase
local M = class("PrestigeAttributeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_prestige_attr_list = self.m_params.prestige_attr_list
	if self.m_prestige_attr_list ~= nil and next(self.m_prestige_attr_list) ~= nil then
		local attrs = {}
		local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
		for k,v in pairs(self.m_prestige_attr_list) do
			table.insert(attrs,{k,v})
		end
		table.sort(attrs, function(itemData1, itemData2)
			return itemData1[1] < itemData2[1]
		end)
		self.m_attrs = attrs
	end
end

--检查属性的其他加成
function M:checkKeyOtherAdd(key, hero_attr)
	local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
	local cur_atr_num = hero_attr[key] or 0
	local add = false
	for k,v in pairs(hero_attar_tab) do
		if key ~= v.user_key then
			if self:checkGetKey2(v.key, key) == true and hero_attr[v.user_key] and not add then
				local group = v.group or 0
				add = group > 0 and true or false
				cur_atr_num = cur_atr_num + hero_attr[v.user_key]
			end
		end
	end
	return cur_atr_num
end

function M:checkGetKey2(key_tab, key)
	if key_tab == nil then
		return false
	end
	for k,v in pairs(key_tab) do
		if v == key then
			return true
		end
	end
	return false
end

return M
