local M = class("RpgSelectChapterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_team_id = self.m_params.id
	self.m_chapter_data = self.m_params.chapter_data.chapter_datas
	self.cur_chapter = self.m_params.chapter_data.cur_chapter
	self.m_show_list = self:getList()
end

function M:getShowData()
	local logs = self.m_data.damage_log or {}
	return logs
end

function M:getList()
	local cfg = {}
	local tab = ConfigManager:getCfgByName("roleplaying_team")
	local tab_data = tab[self.m_team_id]
	for k,v in pairs(tab_data.chapter_id) do
		table.insert(cfg, v)
	end
	self:sort(cfg)
	return cfg
end

function M:getTeamName()
	local cfg = {}
	local tab = ConfigManager:getCfgByName("roleplaying_team")
	local tab_data = tab[self.m_team_id]
	return tab_data.team_name
end

--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(one, two)
        return one < two
    end
    table.sort(pros, sortFunc)
end
  
function M:getChapterCfgByCId(c_id)
	local tab = ConfigManager:getCfgByName("roleplaying_chapter")
	if self.m_chapter_data then
		local data = self.m_chapter_data[tostring(c_id)] or {}
		return tab[c_id], data
	end
	return tab[c_id], nil
end

function M:getProgress(c_id)
	local cfg, data = self:getChapterCfgByCId(c_id)
	if next(data) ~= nil then
		local num = table.nums(data.ending_list)
		return num.."/"..cfg.ending_num
	end
	return "0/"..cfg.ending_num
end

function M:getEnding(c_id)
	local cfg, data = self:getChapterCfgByCId(c_id)
	if next(data) ~= nil then
		return table.nums(data.ending_list) 
	end
	return 0
end

function M:getBuffById(c_id)
	local ending_data = table.copy(UserDataManager.enable_ending)
    local show_end_id = ending_data[tostring(c_id)]
	local tab = ConfigManager:getCfgByName("roleplaying_ending")
	local c_cfg = tab[c_id]
	local cur_cfg = c_cfg[show_end_id[1]] 
	if cur_cfg then
		return cur_cfg["att"]
	end
	return {}
end



function M:checkLock(c_id)
	if c_id == 1001 then
		return true
	else
		return false	
	end
end

function M:checkIsIn()
	return false
end

return M
