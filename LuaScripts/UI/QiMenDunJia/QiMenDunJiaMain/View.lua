local M = class("QiMenDunJiaMainView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "qi_men_dun_jia_str_001")
	self:setTextByLanKey("chakan_btn_text", "moon_shadow_str_006")
	self:setTextByLanKey("battle_record_btn_text", "qi_men_dun_jia_str_048")
	self:setTextByLanKey("rank_btn_text", "qi_men_dun_jia_str_049")
	self:setTextByLanKey("task_btn_text", "qi_men_dun_jia_str_009")
	self:setTextByLanKey("jindu_name_text", "qi_men_dun_jia_str_050")
	self:setTextByLanKey("tili_name_text", "qi_men_dun_jia_str_051")
	self:refreshUI()
	self:createPlayerImgLogo()
	self:setPlayerImg()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent})
	self.m_control:setExteriorOpen(false)
	
	--local refreshGridObj = self:findGameObject("refreshGridNode")
	--local refreshGridLuaBehaviour = UIUtil.findLuaBehaviour(refreshGridObj)
	--refreshGridLuaBehaviour:AddTrigger("refreshGridNode", U3DUtil:Get_EventTriggerType("PointerDown") , handler(self, self.onDragStart))
	--refreshGridLuaBehaviour:AddTrigger("refreshGridNode", U3DUtil:Get_EventTriggerType("Drag") , handler(self, self.onDrag))
end

--function M:onDragStart()
--	self.dragStartPos = CS.UnityEngine.Input.mousePosition
--end
--
--function M:onDrag()
--	local dragEndPos = CS.UnityEngine.Input.mousePosition
--	local offset = 200
--	if (math.abs(self.dragStartPos.x - dragEndPos.x) > offset) or (math.abs(self.dragStartPos.y - dragEndPos.y) > offset) then
--		self.dragStartPos = CS.UnityEngine.Input.mousePosition
--		if (SceneManager.curScene ~= nil) then
--			SceneManager.curScene:raycastEvent()
--		end
--	end
--end

function M:reqErrorEvent(event, data)
	self.m_control:qmdjReqErrorEvent(data)
end

function M:refreshUI()
	self:refreshExploreProgress()
	self:refreshStrength()
	self:refreshAllBuffValue()
	self:refreshRedPoint()
end

function M:refreshExploreProgress()
	self:updateExploreProgress(self.m_model:getExploreProgress())
end

function M:refreshStrength()
	self:updateStrength(self.m_model:getStrength())
end

function M:refreshAllBuffValue()
	self:updateAllBuffValue(self.m_model:getAllBuffValue())
end

function M:updateExploreProgress(value)
	self:setText("jindu_text", value )
end

function M:updateStrength(value_cur)
	self:setText("tili_text", value_cur )
end

function M:updateAllBuffValue(value)
	self:setObjectVisible("all_buff_node", value > 0)
	self:setTextByLanKey("all_buff_text", "qi_men_dun_jia_str_033", tostring(value))
end

function M:createPlayerImgLogo()
	local avatar,_  = GameUtil:getUserOwnAvatar()
	local cfg = ConfigManager:getPlayerPictureCfg(avatar)
	self:setImg(cfg.icon, "hero_head_ui", "tx_img")
end

function M:setPlayerImg()
	local head_node = self:findGameObject("head_node")
	local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
	GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
	self:setTextByLanKey("text_return", "qmdj_text_0003")
	self:setObjectVisible("playerPosLogo", false)
end

function M:switchPlayerImgType(isShow)
	self:setObjectVisible("playerPosLogo", isShow)
end

function M:refreshRedPoint()
	self:setObjectVisible("battle_record_btn_red_point_img", self.m_model:hasGuildReward())
	self:setObjectVisible("task_btn_red_point_img", self.m_model:hasTaskReward())
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent})
	self.m_control:setExteriorOpen(true)
	M.super.destroy(self)
end

return M