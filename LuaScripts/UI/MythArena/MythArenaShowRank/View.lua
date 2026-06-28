local M = class("MythArenaShowRankView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaShowRank"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_stage_slider = self:findSlider("stage_slider")
	self:setTextByLanKey("go_btn_text", "new_str_0690")
	self:setTextByLanKey("reward_btn_text", "new_str_0690")
	self:setTextByLanKey("close_title_text", "wlsh_text_0004")
	self:refreshUI()
	--UserDataManager:removeRedDotByKey("high_arena")
end

function M:refreshUI()
	self:refreshRankItem()
end

function M:refreshRankItem()
	for i = 1, 8 do
		local rank_data = self.m_model.m_ranks[i] or {} 
		local rank_item = self:findGameObject("rank_img" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(rank_item)
		local head_node = luaBehaviour:FindGameObject("HeadNode")
		if next(rank_data) then
			local userData = rank_data.user
			GameUtil:setUserAvatar(head_node, userData, false, false, {show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"player_name_text",userData.name)
		end
		local title = self.m_model:getRankTitleDes(i)
		if title then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"title_text", title)
		end
		local rank_record_btn = luaBehaviour:FindGameObject("rank_record_btn")

		UIUtil.setButtonClick(rank_record_btn.transform, function(obj, data)
			self:updateMsg("rank_record_btn", data)
		end, i, nil, self.m_uiName)

	end
end

function M:destroy()
    M.super.destroy(self)
end

return M