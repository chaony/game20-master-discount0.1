local M = class("BiographyChapterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
	self:updateData()
end

function M:updateData(data)
	if data then
		self.m_data = data
	end

	self.m_biography = self.m_params.biography
	self.m_chapter = self.m_params.chapter
	self.m_battle_stage = nil
	self.m_stage = self:getBattleStage()
	self.m_cur_stage = self.m_stage
	if self:stageIsDone(self.m_stage) == false then
		self.m_battle_stage = self.m_stage
	end
end

function M:getBattleStage()
	local biography_chapter = ConfigManager:getCfgByName("biography_chapter")
	local biography_stage = ConfigManager:getCfgByName("biography_stage")
	local chapter_cfg = biography_chapter[self.m_chapter]
	local min_stage = chapter_cfg.group[1]
	local bio_data = self.m_data.bio_data[tostring(self.m_biography)]
	for i,v in ipairs(self.m_data.bio_done or {}) do
		if self.m_biography == v then
			min_stage = chapter_cfg.group[#chapter_cfg.group]
			return min_stage
		end
	end
	if bio_data then
		if bio_data.chapter_done then
			for i,v in ipairs(bio_data.chapter_done or {}) do
				if v == self.m_chapter then
					min_stage = chapter_cfg.group[#chapter_cfg.group]
					break
				end
			end
		end
		if bio_data.chapter_data and bio_data.chapter_data[tostring(self.m_chapter)] and next(bio_data.chapter_data[tostring(self.m_chapter)].stage_done or {}) then
			for i,v in ipairs(bio_data.chapter_data[tostring(self.m_chapter)].stage_done) do
				if min_stage < v then
					min_stage = v
				end
			end
			
			local stage_cfg = biography_stage[min_stage]
			if stage_cfg.next and stage_cfg.next > 0 then
				min_stage = stage_cfg.next
			end
		end
		
	end
	return min_stage
end

function M:setCurStage(id)
	if id ~= self.m_cur_stage and id <= self.m_stage then
		self.m_cur_stage = id
		return true
	elseif id > self.m_stage then
		return false, 1	
	end
	return false
end

function M:stageIsDone(stage)
	if table.keyof(self.m_data.bio_done, self.m_biography) then -- 传记已经完成
		return true
	else
		if self.m_data.bio_data and self.m_data.bio_data[tostring(self.m_biography)] and self.m_data.bio_data[tostring(self.m_biography)].chapter_done then
			if table.keyof(self.m_data.bio_data[tostring(self.m_biography)].chapter_done, self.m_chapter) then -- 章节已经完成
				return true
			end
		end
		if stage < self.m_stage then
			return true
		end
	end
	return false
end

function M:getStageEnemy()
	local biography_stage = ConfigManager:getCfgByName("biography_stage")
	--local stage_battle = ConfigManager:getCfgByName("stage_battle")
	local stage_cfg = biography_stage[self.m_cur_stage]

	local battle_data = ConfigManager:getCfgStageBattle(stage_cfg.battle)-- stage_battle[stage_cfg.battle]
	local monsters = battle_data["monster"]
	local enemy = {}
	for i,v in ipairs(monsters) do
		table.insert(enemy,{RewardUtil.REWARD_TYPE_KEYS.HEROS, v.id, 1, quality = v.evo})
	end
	return enemy
end

return M
