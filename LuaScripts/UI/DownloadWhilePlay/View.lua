local M = class("DownloadWhilePlayView",LikeOO.OOPopBase)

M.m_uiName = "DownloadWhilePlay/DownloadWhilePlay"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "")
	self.task_reward_item = self:findGameObject("task_reward_item")
	self:setObjectVisible("task_reward_item", false)
	
	local download_play_stage = UserDataManager:getDownloadWhilePlayStage() or 1
	if download_play_stage == 0 then
		self:setTextByLanKey("btn_get_text", "download_play_02")
	elseif download_play_stage == 1 then
		self:setObjectVisible("btn_get", false)
	elseif download_play_stage == 2 then
		self:setTextByLanKey("btn_get_text", "download_play_08")
	end
	
	self:setTextByLanKey("des_text_1", "download_play_05")
	local gift_data = self.m_model:getGiftData()
	local data = RewardUtil:getProcessRewardData(gift_data[1]) or {}
	self:setTextByLanKey("des_text_2", "download_play_06", data.data_num or 0, data.name or Language:getTextByKey("download_play_07"))
	self:initReward()
end

function M:initReward()
	local task_reward_content = self:findGameObject("reward_content")
	UIUtil.destroyAllChild(task_reward_content.transform)
	local gift_data = self.m_model:getGiftData()
	for kk, vv in ipairs(gift_data) do
		local reward_item = GameUtil:instanceObject(self.task_reward_item, task_reward_content)
		reward_item:SetActive(true)
		local ItemNode = UIUtil.findTrans(reward_item.transform, "ItemNode")
		GameUtil:updateItemElement(ItemNode, vv, true, true)
	end
end

return M