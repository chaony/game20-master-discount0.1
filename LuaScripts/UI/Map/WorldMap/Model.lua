local M = class("WorldMapModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

local chapter_pos = {
	{-251.6,-276.67,0},
	{-92,-442,0},
	{32,-301.3,0},
	{101,-226,0},
	{178,-414,0},
	{268,-235,0},
	{341.2,-117,0},
	{298,-10,0},
	{247,-79,0},
	{247,84,0},
	{178,6.5,0},
	{86,11.7,0},
	{-188,14.2,0},
	{155,310,0},
	{1000,-1000,0},
	{1000,-1000,0},
	{1000,-1000,0},
	{1000,-1000,0},
	{1000,-1000,0},
}

function M:onEnter()
	self.cur_chapter = self:getCurChapter()
end

function M:getCurChapter()
	local cur_stage = UserDataManager:getCurStage()
	local stage_tab = ConfigManager:getCfgByName("stage")
	return stage_tab[cur_stage].chapter_id
end

function M:getChapterList()
	local chapter_tab = ConfigManager:getCfgByName("chapter")
	return chapter_tab
end

function M:getChapterPos()
	return chapter_pos
end

return M
