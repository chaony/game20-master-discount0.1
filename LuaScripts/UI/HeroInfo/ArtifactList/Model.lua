local M = class("EquipmentListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.heroid --当前英雄id
	self.m_callback = self.m_params.callback
	self.m_herodata, self.herocfg =	self:getHero()
	self:getArtfactList()
end


--获取当前槽位对应的装备列表 （剔除不同职业不同槽位以及自己）
function M:getFiltrateIds()
	local f_ids = {}
	local ids = UserDataManager.equip_data:getEquipsId()
	for k,v in pairs(ids) do
		local data, cof = self:getEquipById(v)
		if cof.pos == self.m_pos and cof.type == self.herocfg.type and data.oid ~= self.m_cur_eqp_id then 
			table.insert(f_ids, v)
		end
	end
	return f_ids
end

--获取英雄信息
function M:getHero()
	return self:getHeroById(self.m_heroid)
end

function M:getHeroById(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

function M:getArtfactList()
	local artifacts_data = table.copy(UserDataManager.artifact_data:getEquipsData())
	local heros = table.copy(UserDataManager.hero_data:getHerosData()) 
	local new_tab = {}
	for k,v in pairs(heros) do
		if v.artifact and next(v.artifact) ~= nil then
			local n = tostring(v.artifact.oid)
			v.artifact.h_id = k
			artifacts_data[n] = v.artifact
		end
	end
	local art_tab = ConfigManager:getCfgByName("artifact")
	self.m_artifacts_data = self:artSort(artifacts_data)
	self.no_m_artifacts = {}
	for k,v in pairs(art_tab) do
		if self:checkIn(k, self.m_artifacts_data) == false then
			table.insert(self.no_m_artifacts, k)
		end
	end
	for i = 1, table.nums(self.m_artifacts_data) do
		table.insert(new_tab, self.m_artifacts_data[i].id)
	end
	for i = 1, table.nums(self.no_m_artifacts) do
		table.insert(new_tab, self.no_m_artifacts[i])
	end
	return new_tab
end

function M:checkIn(id, tab)
	for k,v in pairs(tab) do
		if id == v.id then
			return true
		end
	end
	return false
end

function M:checkIsHeros(id)
	for k,v in pairs(self.m_artifacts_data) do
		if v.h_id and id == v.h_id then
			return true
		end
	end
	return false	
end

function M:getArtifactData(id)
	local cfg = nil
	local data = nil
	for k,v in pairs(self.m_artifacts_data) do
		if v.id == id then
			data = v
			break
		end
	end
	cfg = UserDataManager.artifact_data:getArtifactConfigByCid(id)
	return data, cfg
end

function M:getArtifactByCid(c_id)
	return UserDataManager.artifact_data:getArtifactConfigByCid(c_id)
end

--[[
    神器排序
]]
function M:artSort(datas)
	local new_sort = {}
	local main_tab = self:getMainArt(datas)
	for k,v in pairs(main_tab) do
		table.insert( new_sort, v)
	end
	local can_wear_tab = self:getCanWear(datas)
	self:artsSort(can_wear_tab)
	for k,v in pairs(can_wear_tab) do
		table.insert(new_sort, v)
	end
	self:artsSort(datas)
	for k,v in pairs(datas) do
		if not self:checkIn(v.id, new_sort) then
			table.insert(new_sort, v)
		end   
	end
	return new_sort
end

--检测出自己穿戴的神器
function M:getMainArt(datas)
	local c_arts = {}
	for k,v in pairs(datas) do
		if v.h_id and  v.h_id == self.m_heroid then
			table.insert(c_arts, v)
		end
	end
	return c_arts
end

--检测出可穿戴神器
function M:getCanWear(datas)
	local c_arts = {}
	for k,v in pairs(datas) do
		if v.h_id == nil then
			table.insert(c_arts, v)
		end
	end
	return c_arts
end

--[[
    神器排序
]]
function M:artsSort(arts)
    arts = arts or {}
    local function sortFunc(id_one, id_two)
        local data1 = id_one
		local data2 = id_two
		local cid1, cid2 = data1.id, data2.id
		return cid1 < cid2
    end
    table.sort(arts, sortFunc)
end

--获取当前等级对应的特殊属性
function M:getParam_des(data, cfg)
	if data then
		local lv_up = cfg.level_up[data.lv]
		if #lv_up.param_des == 0 and data.lv > 0 then
			for i = data.lv, 0,-1 do
				local n_lv_up = cfg.level_up[i]
				if #n_lv_up.param_des ~= 0 then
					return n_lv_up.param_des 
				end
			end
		else
			return 	lv_up.param_des
		end
	else
		return cfg.des
	end
end

return M
