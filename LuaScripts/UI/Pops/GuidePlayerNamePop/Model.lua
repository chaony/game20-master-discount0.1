local M = class("GuidePlayerNameModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	math.randomseed(os.time())
end

function M:randName()
	local surname_cfg = ConfigManager:getCfgByName("surname")
	local name_cfg = ConfigManager:getCfgByName("name")
	local surname_id = math.random(#surname_cfg)
	local name_id = math.random(#name_cfg)
	return Language:getTextByKey(surname_cfg[surname_id].surname) .. Language:getTextByKey(name_cfg[name_id].name)
end

return M
