--悬赏列表
local M = class("BiographyControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.Biography.Guide"
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
	if msg == 99999 then
		self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
	elseif msg == "last_btn" then
		self.m_model:changeBiography(-1)
		self.m_view:refreshUI()
	elseif msg == "next_btn" then
		self.m_model:changeBiography(1)
		self.m_view:refreshUI()
	elseif msg == "enter_btn" then
		self:intoChapter(self.m_model.m_biography, self.m_model.m_chapter)
	elseif msg == "chapter_btn_1" then
		local chapter = self.m_model:getChapterByIndex(1)
		self:chapterClickHandle(chapter)
	elseif msg == "chapter_btn_2" then
		local chapter = self.m_model:getChapterByIndex(2)
		self:chapterClickHandle(chapter)
	elseif msg == "chapter_btn_3" then
		local chapter = self.m_model:getChapterByIndex(3)
		self:chapterClickHandle(chapter)
	elseif msg == "chapter_btn_4" then
		local chapter = self.m_model:getChapterByIndex(4)
		self:chapterClickHandle(chapter)
	elseif msg == "reward_click" then
		--if self.m_model:chapterIsDone(data.chapter_id) then
		--	if self.m_model:chapterRewardIsReceive(data.bio_id, data.chapter_id) == false then
		--		self:receiveChapterReward(data)
		--	end
		--end
	elseif msg == "biography_box_btn" then
		--local tips = nil
		--if self.m_model:biographyIsDone(self.m_model.m_show_biography) then
		--	if self.m_model:biographyRewardIsReceive(self.m_model.m_show_biography) == false then
		--		self:receiveBiographyReward()
		--		return
		--	else
		--		tips = "new_str_0058"
		--	end
		--end
		--local biography = ConfigManager:getCfgByName("biography")
		--local cfg = biography[self.m_model.m_show_biography]
		--self:openView("Pops.LookRewardTips", {rewards = cfg.reward, click_transform = self.m_view.biography_box_btn.transform, show_check_mark = false, tips = tips})
		local reward_type = self.m_model:getRewardType()
		self:openView("Task.TaskMainChapter", {quest_type = reward_type})
	elseif msg == "help_btn" then
		local params = {}
		params.title = "biography_str_001"
		params.content = "tid#BiographyShowDes_001"
		self:openView("Pops.CommonHelpPop", params)
	elseif msg == "update_data" then
		self.m_model:updateData(data)
		self.m_view:refreshUI()
	end
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "quest_special_update" or curEvent == "stage_update" then
		self.m_view:refreshUI()
	end
end

function M:chapterClickHandle(chapter)
	if self.m_model:chapterIsDone(chapter) or chapter == self.m_model.m_chapter then
		self:intoChapter(self.m_model.m_show_biography, chapter)
	else
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("biography_str_008"), delay_close = 2})
	end
end

function M:intoChapter(bio_id, chapter_id)
	local opened, open_day = self.m_model:chapterOpened()
	if opened == false then
		GameUtil:lookInfoTips(self, {msg = string.format(Language:getTextByKey("biography_str_009"), open_day), delay_close = 2})
		return
	end
	
	local params = {}
	params.biography = bio_id or self.m_model.m_biography
	params.chapter = chapter_id or self.m_model.m_chapter
	params.data = self.m_model.m_data
	self:openView("Biography.BiographyChapter", params)
end

function M:receiveChapterReward(data)
	local function receiveCallback(response)
		RewardUtil:rewardTipsByData(response.reward)
		self.m_model:updateData(response)
		self.m_view:refreshUI()
	end

	self.m_model:getNetData("biography_recv_chapter_reward", data, receiveCallback)
end

function M:receiveBiographyReward()
	local function receiveCallback(response)
		RewardUtil:rewardTipsByData(response.reward)
		self.m_model:updateData(response)
		self.m_view:refreshUI()
	end
	local params = {}
	params.bio_id = self.m_model.m_show_biography
	self.m_model:getNetData("biography_recv_bio_reward", params, receiveCallback)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M;
