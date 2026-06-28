local M = class("RacconShowBeforeStoryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.new_chapter = self.m_params.new_chapter;
	self.is_battle = self.m_params.is_battle;
	self.battle_id = self.m_params.battle_id;
	self.cfg_type = self.m_params.cfg_type;
	self.hero_index = self.m_params.hero_index;
	self.stage_id = self.m_params.stage_id;
	self.m_mode = self.m_params.mode or 0
	self.m_open_event = self.m_params.open_event or 0
end

return M
