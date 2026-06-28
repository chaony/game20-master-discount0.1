local M = class("LibraryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData("library_troop_index")
end

function M:onEnter()
	self.m_cur_key = nil
end

function M:getShowData()
	local type_id_key = {}
	local show_data = {}
	local troops = self.m_data.troops or {}
	local teahouse = ConfigManager:getCfgByName("teahouse")
	for k,v in pairs(teahouse) do
		if type_id_key[v.type_id] == nil then
			local data = troops[tostring(v.type_id)] or {}
			type_id_key[v.type_id] = 1
			table.insert(show_data, {id = k, data = data, cfg = v})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.id < data2.id
	end)
	return show_data
end

function M:getTalkWord()
	local common_value = ConfigManager:getCommonValueById(94, {})
	local random_value_map = {}
	local value = 0
	for k,v in ipairs(common_value) do
		value = value + v[2]
		random_value_map[k] = {v[1], value}
	end
	local word_key = nil
	if #random_value_map > 1 then
		repeat
			word_key = self:getRandomWordKey(random_value_map, value)
		until self.m_cur_key ~= word_key
	elseif #random_value_map == 1 then
		word_key = random_value_map[1][1]
	end
	self.m_cur_key = word_key or "???"
	local language_id = nil
	local sys_dialogue = ConfigManager:getCfgByName("sys_dialogue")
	if self.m_cur_key then
		local sys_dialogue_item = sys_dialogue[self.m_cur_key] or {}
		language_id = sys_dialogue_item.language_id
	end
	return language_id or ""
end

function M:getRandomWordKey(random_value_map, value)
	local word_key = nil
	local random_value = math.random(value)
	for k,v in ipairs(random_value_map) do
		if v[2] > random_value then
			word_key = v[1]
			break
		end
	end
	return word_key
end

function M:initData(data)
    table.merge(self.m_data, data)
end

return M
