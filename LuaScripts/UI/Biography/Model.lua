local M = class("BiographyModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("biography_index")
end

function M:onEnter()
	self:updateData()
end

function M:updateData(data)
	if data then
		self.m_data = data
	end

	local biography = ConfigManager:getCfgByName("biography")
	self.m_max_bio_id = #biography
	self.m_biography = 1 -- 当前挑战的传记
	self:setCurBiography()
	self.m_show_biography = self.m_biography

	local bio_cfg = biography[self.m_biography]
	self.m_chapter = bio_cfg.group[1] -- 当前可挑战的章节
	self:setCurChapter()
end

function M:changeBiography(increments)
	if self.m_show_biography + increments < 1 then
		self.m_show_biography = 1
	elseif self.m_show_biography + increments > self.m_max_bio_id then
		self.m_show_biography = self.m_max_bio_id
	else
		self.m_show_biography = self.m_show_biography + increments
	end
end

function M:setCurBiography()
	local biography = ConfigManager:getCfgByName("biography")
	if self.m_data.bio_done and next(self.m_data.bio_done) then
		local min_boi = 1
		for i,v in ipairs(self.m_data.bio_done) do
			if min_boi < v then
				min_boi = v
			end
		end
		local bio_cfg = biography[min_boi]
		if bio_cfg.next and bio_cfg.next > 0 then
			self.m_biography = bio_cfg.next
		else
			self.m_biography = min_boi
		end
	end
end

function M:setCurChapter()
	local biography_chapter = ConfigManager:getCfgByName("biography_chapter")
	if self.m_data.bio_data then
		if self.m_data.bio_data[tostring(self.m_biography)] then
			local bio_data = self.m_data.bio_data[tostring(self.m_biography)]
			if bio_data.chapter_done then
				local min_chapter = self.m_chapter
				for i,v in ipairs(bio_data.chapter_done) do
					if min_chapter < v then
						min_chapter = v
					end
				end
				local chapter_cfg = biography_chapter[min_chapter]
				if chapter_cfg.next then
					self.m_chapter = chapter_cfg.next
				else
					self.m_chapter = min_chapter
				end
			end
		end
	end
end

function M:biographyIsDone(biography)
	if table.keyof(self.m_data.bio_done, biography) then
		return true
	end
	return false
end

function M:biographyIsOpen(biography)
	return biography <= self.m_biography
end

function M:chapterIsDone(chapter)
	if self:biographyIsDone(self.m_show_biography) then
		return true
	else
		if self.m_data.bio_data and self.m_data.bio_data[tostring(self.m_show_biography)] and self.m_data.bio_data[tostring(self.m_show_biography)].chapter_done then
			if table.keyof(self.m_data.bio_data[tostring(self.m_show_biography)].chapter_done, chapter) then
				return true
			end
		end
	end
	return false
end

function M:getChapterByIndex(index)
	local biography = ConfigManager:getCfgByName("biography")
	local bio_cfg = biography[self.m_show_biography]
	if bio_cfg then
		return bio_cfg.group[index]
	end
end

function M:finishChapterLength()
	local len = 0
	if self.m_data.bio_data and self.m_data.bio_data[tostring(self.m_show_biography)] and self.m_data.bio_data[tostring(self.m_show_biography)].chapter_done then
		len = #self.m_data.bio_data[tostring(self.m_show_biography)].chapter_done
	end
	return len
end

function M:chapterRewardIsReceive(bio,chapter)
	if self.m_data.bio_data[tostring(bio)] then
		for i,v in ipairs(self.m_data.bio_data[tostring(bio)].chapter_recv or {}) do
			if v == chapter then
				return true
			end
		end
	end
	return false
end

function M:biographyRewardIsReceive(bio)
	if self.m_data.bio_data[tostring(bio)] then
		if self.m_data.bio_data[tostring(bio)].recv == 1 then
			return true
		end
	end
	return false
end

function M:getRewardType()
	local biography = ConfigManager:getCfgByName("biography")
	local bio_cfg = biography[self.m_show_biography]
	return bio_cfg.reward_type
end

function M:boxIsCanReceive(quest_type)
	quest_type = quest_type or self:getRewardType() 
	local flag = false
	for i,v in ipairs(quest_type or {}) do
		local chapter_quest = UserDataManager:getChapterQuestSpecialData(v)
		local chapter_quest_first = chapter_quest[1]
		if chapter_quest_first then
			if chapter_quest_first.status == 2 then -- 完成可领取
				flag = true
			end
		end
	end
	return flag
end

function M:chapterOpened()
	local flag = false
	local open_day = 0
	local biography = ConfigManager:getCfgByName("biography")
	local bio_cfg = biography[self.m_show_biography]
	if bio_cfg and bio_cfg.day then
		local server_time = UserDataManager:getServerTime()
		local reg_ts = UserDataManager.reg_ts
		local day = math.floor((TimeUtil.getIntTimestamp(server_time) - TimeUtil.getIntTimestamp(reg_ts))/86400)
		if day >= bio_cfg.day then
			flag = true
		else
			open_day = bio_cfg.day - day
		end
	else
		flag = true
	end
	return flag, open_day
end

return M
