local M = class("BuySkinModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.skin_id = self.m_params.skin_id
	self.have_flag = self.m_params.flag
	self.fenghua_record_skin = ConfigManager:getCfgByName("fenghua_record_skin")
	self.select_skin_cfg = self.fenghua_record_skin[self.skin_id]
	--self.m_hero_id = self.select_skin_cfg.hero_id
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.skin_id)
	local time = {}
end

return M
