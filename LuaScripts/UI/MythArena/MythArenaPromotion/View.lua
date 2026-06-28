local M = class("MythArenaPromotionView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaPromotion"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setObjectVisible("UI_MythArena_Stage_004", false)
	for i = 1, 3 do
		self:setObjectVisible("stage_icon" .. i, i == self.m_model.m_pop_type)
	end
	self.m_control:setOnceTimer(0.3, function()
		for i = 1, 3 do
			self:setObjectVisible("UI_MythArena_Stage_00" .. i, i == self.m_model.m_pop_type)
		end
		self:setObjectVisible("UI_MythArena_Stage_004", true)
	end)
	
	self:setTextByLanKey("stage_text", self.m_model.m_stage_name)
	self:setTextByLanKey("share_btn_text", "castingSword_str_0016")
	self:setTextByLanKey("close_title_text", "wlsh_text_0012")
	self:refreshUI()
end

function M:refreshUI()
	self:refreshHead()
end

function M:refreshHead()
	local head_node = self:findGameObject("HeadNode")
	local userData = UserDataManager.user_data:getOwnRankData({  })
	GameUtil:setUserAvatar(head_node, userData.user, false, false, {show_flag = true, scale = 1})
	self:setText("player_name_text", userData.user.name)
end

function M:showShareNode()
	-- 官方包才有
	local isOfficialBag = false
	if SDKUtil.is_gmsdk then
		local bundleid = SDKUtil.sdk_params.applicationId or ""
		if bundleid == "com.hermes.wl" then
			-- 是官方包
			isOfficialBag = true
		end
	end
	self:setTextByLanKey("text_shareHintText", "castingSword_str_0027")
	self:setObjectVisible("img_QRcode", isOfficialBag)
	self:setObjectVisible("hintNode", (not isOfficialBag))
	self:setObjectVisible("shareNode", true)
end

function M:hideShereNode()
	self:setObjectVisible("img_QRcode", false)
	self:setObjectVisible("hintNode", false)
	self:setObjectVisible("shareNode", false)
end

function M:destroy()
    M.super.destroy(self)
end

return M