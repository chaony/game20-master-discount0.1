local M = class("MapPopModel", LikeOO.OODataBase)


function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_stage_id = self.m_params.stage_id
	self.m_chapter = self.m_params.chapter_id
	if self.m_chapter == nil then
		local chapter_tab = ConfigManager:getCfgByName("chapter")
		local stage_tab = ConfigManager:getCfgByName("stage")
		local cur_stage = stage_tab[self.m_stage_id]
		self.m_chapter = cur_stage.chapter_id
	end
end

function M:getReward()
	local chapter_tab = ConfigManager:getCfgByName("chapter_important_show")
	local stage_tab = ConfigManager:getCfgByName("stage")
	if self.m_stage_id then
		local cur_stage = stage_tab[self.m_stage_id]
		local cur_chapter = chapter_tab[cur_stage.chapter_id]
		return cur_chapter.important_show
	elseif self.m_chapter then
		local cur_chapter = chapter_tab[self.m_chapter]
		return cur_chapter.important_show
	end
	return {}
end

function M:getTitleName()
	local stage_tab = ConfigManager:getCfgByName("stage")
	local chapter_tab = ConfigManager:getCfgByName("chapter")
	local str = ""
	-- if self.m_stage_id then
	-- 	str = stage_tab[self.m_stage_id].map_point_name
	-- elseif self.m_chapter then
		str = chapter_tab[self.m_chapter].chapter_name
	-- end
	return str
end

return M
 