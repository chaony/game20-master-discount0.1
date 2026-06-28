local M = class("WorldMapPrestigeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("big_map_prestige_index")
end

function M:onEnter()
	self.m_cur_map_id = SceneManager.curScene.sceneId
	self.m_prestiges = self.m_data.prestiges or {}
	self.m_sel_tab_index =  nil
	self.cur_prestiges_num = self.m_prestiges.value or 0
	self.cur_prestiges_done = self.m_prestiges.done or {}
	self.m_open_tab_index = 1
	self.m_area_map = 1
end

function M:InitNetData(id, callback)
	self:getNetData("big_map_prestige_rank", {area_id = id}, callback)	
end

function M:mapAreaTab()
	local map_tab = ConfigManager:getCfgByName("map_area")
	local new_tab = {}
	for k,v in pairs(map_tab) do
		table.insert(new_tab, {id = k, cfg =v})
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
    table.sort(new_tab, sortFunc)
	return new_tab
end

function M:checkPrestigesDone(id)
	for k,v in pairs(self.cur_prestiges_done) do
		if id == v then
			return true
		end
	end
	return false	
end

function M:checkPrestigesDone2(id)
	for k,v in pairs(self.cur_prestiges_done) do
		if id == v then
			return 1
		end
	end
	return 0	
end

function M:getCurMapName()
	local map_tab = ConfigManager:getCfgByName("map_area")
	local map_data = map_tab[self.m_cur_map_id]
	return map_data.name
end

function M:getPrestigeTab()
	local pre_tab = ConfigManager:getCfgByName("prestige")
	local tab_list = pre_tab[self.m_cur_map_id]
	local new_list = {}
	for k,v in pairs(tab_list) do
		table.insert( new_list, k)
	end
	local function sortFunc(id_one, id_two)
		local bl_1 = self:checkPrestigesDone2(id_one)
		local bl_2 = self:checkPrestigesDone2(id_two)
		if bl_1 == bl_2 then
			return id_one < id_two
		else
			return bl_1 < bl_2	
		end
    end
    table.sort(new_list, sortFunc)
	return new_list
end

function M:getPrestigeCfg(id)
	local pre_tab = ConfigManager:getCfgByName("prestige")
	local tab_list = pre_tab[self.m_cur_map_id]
	return tab_list[id]
end

function M:getRankByMapId(id)
	
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "big_map_prestige_rank" then
		self.m_ranks = data.ranks
	end
end

return M
