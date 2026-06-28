local M = class("ExclusiveWeaponsLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_mode = self.m_params.mode
	self.m_hero_oid = self.m_params.hero_oid
	if self.m_mode == 1 then --神器升级
		self.m_attrs = self:getArtList()
	elseif self.m_mode == 2 then --专属升级	
		self.m_attrs = self:getExclList()
	end
end

function M:getExclList()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero_oid)
	local diff_atts = {}
	if h_data.sig and next(h_data.sig) ~= nil then
		local title = {last_lv = h_data.sig.lv - 1, cur_lv = h_data.sig.lv}
		table.insert(diff_atts, title)
		local ex_tab = ConfigManager:getCfgByName("equip_heroes")
		local ex_eqp_cfg = ex_tab[h_cfg.equip_heroes_id] 
		local cur_attrs = ex_eqp_cfg.level_up[h_data.sig.lv].attr
		local last_attrs = ex_eqp_cfg.level_up[h_data.sig.lv - 1].attr
		for k,v in pairs(cur_attrs) do
			local attr = nil
			if last_attrs[k] then
				attr = { last_attr = last_attrs[k], cur_attr = v }
			else	
				attr = { last_attr = nil, cur_attr = v }
			end
			table.insert( diff_atts, attr)
		end
	end
	return diff_atts
end

function M:getArtList()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero_oid)
	local diff_atts = {}
	if h_data.artifact and next(h_data.artifact) ~= nil then
		local art_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(h_data.artifact.id) 
		local title = {last_lv = h_data.artifact.lv - 1, cur_lv = h_data.artifact.lv}
		table.insert(diff_atts, title)
		local cur_attrs = art_cfg.level_up[h_data.artifact.lv].attr
		local last_attrs = art_cfg.level_up[h_data.artifact.lv-1].attr
		for k,v in pairs(cur_attrs) do
			local attr = nil
			if last_attrs[k] then
				attr = { last_attr = last_attrs[k], cur_attr = v }
			else	
				attr = { last_attr = nil, cur_attr = v }
			end
			table.insert( diff_atts, attr)
		end
	end
	return diff_atts
end


function M:getArtData()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero_oid)
	if h_data.artifact and next(h_data.artifact) ~= nil then
		local art_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(h_data.artifact.id) 
		return art_cfg
	end
	return nil
end

return M
