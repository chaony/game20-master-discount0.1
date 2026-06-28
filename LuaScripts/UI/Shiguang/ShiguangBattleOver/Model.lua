local M = class("ShiguangBattleOverModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_ending_event = self.m_params.ending_event
	self.m_chapter_id = self.m_params.chapter_id
end

function M:getShowData()
	local roleplaying_ending = ConfigManager:getCfgByName("roleplaying_ending")
	local chapter_roleplaying_ending_cfg = roleplaying_ending[self.m_chapter_id] or {}
	local roleplaying_ending_cfg = chapter_roleplaying_ending_cfg[self.m_ending_event] or {}
	local hero = roleplaying_ending_cfg.hero or {}
	local att = roleplaying_ending_cfg.att or {}
	local show_data = {}
	local hero_names = ""
	for i, v in ipairs(hero) do
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v)	
		if hero_cfg then
			local name = Language:getTextByKey(hero_cfg.name)
			if hero_names == "" then
				hero_names = name
			else
				hero_names = hero_names .. " " .. name
			end
		end
	end
	if hero_names ~= "" then
		table.insert(show_data, hero_names .. " " .. Language:getTextByKey("new_str_0455"))
	end
	for i, v in ipairs(att) do
		local attr_cfg = GameUtil:getAttrCfg(v[1])
		local attr_name = Language:getTextByKey(attr_cfg.name)
		if GameUtil:attrTransition(attr_cfg.user_key) == true then
			table.insert(show_data, attr_name .. ": +" .. tostring(v[2]*100) .. "%")
		else
			table.insert(show_data, attr_name .. ": +" .. tostring(v[2]))
		end
	end
	return show_data
end

function M:getShowName()
	local roleplaying_ending = ConfigManager:getCfgByName("roleplaying_ending")
	local chapter_roleplaying_ending_cfg = roleplaying_ending[self.m_chapter_id] or {}
	local roleplaying_ending_cfg = chapter_roleplaying_ending_cfg[self.m_ending_event] or {}
	return Language:getTextByKey(roleplaying_ending_cfg.end_name or "")
end

return M
