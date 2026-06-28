local M = class("ArtifactPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.heroid 
	self.m_callback = self.m_params.callback
	self.m_look_model = self.m_params.look_model -- 0 自己 1 其他人
	self.m_artid = self.m_params.artid 
	if self.m_look_model == 1 then
		self.m_art_data = self.m_params.art_data 
		self.m_art_cfg =  UserDataManager.artifact_data:getArtifactConfigByCid(self.m_art_data.id)
	else
		self.m_art_data, self.m_art_cfg = self:gerArtData()	
	end
end

function M:gerArtData()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local data = h_data.artifact
	local cfg = UserDataManager.artifact_data:getArtifactConfigByCid(data.id)
	return data, cfg
end

function M:getAttrs()
	local attrs = self.m_art_cfg.level_up[self.m_art_data.lv].attr
	return attrs
end

function M:getSkillDesc()
	local tab_desc = {}
	for k,v in pairs(self.m_art_cfg.level_up) do
		if #v.param_des > 0 then
			table.insert( tab_desc, { activate = self.m_art_data.lv >= k, lv = k, desc = v.param_des })
		end
	end
	return tab_desc
end

function M:isMaxLv()
	if self.m_art_data.lv >= #self.m_art_cfg.level_up then
		return true
	else
		return false	
	end
end

return M
