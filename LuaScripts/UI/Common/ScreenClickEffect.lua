local M = class("ScreenClickEffect", LikeOO.OOUIbase)

M.m_uiName = "Common/ScreenClick"
M.m_sortOrder = 10020
M.m_sortOrderChange = false
local Input = U3DUtil:Get_Input()
function M:onCreate()
	self.m_is_down = false
	self.g_screen_effect = UserDataManager.local_data:getLocalDataByKey("effectShow", 1)
	local RectTransform = self.m_rootView:GetComponent("RectTransform")
	self.rect = RectTransform.rect
	self.m_effect_obj = self:findGameObject("UI_CommonClickEffect")
	self.m_effect = self:findParticleSystem("UI_CommonClickEffect")
	self.m_update_key = self.__cname .. "_update_" .. os.time()
	GameMain.addUpdate(self.m_update_key, handler(self,self.update))
	CS.ScreenShot.screenClickObj = self.m_rootView
end

function M:update()
	self:mouseDown()
	self:mouseMove()
	self:mouseUp()
end

function M:mouseDown()
	if U3DUtil:Input_GetMouseButtonDown(0) then
		self.m_is_down = true
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.SCREEN_CLICK_EVENT)
	end
end

function M:mouseMove()

end

function M:mouseUp()
	if U3DUtil:Input_GetMouseButtonUp(0) then
		if self.g_screen_effect == 1 then
			self.m_is_down = false
			local input_pos = Input.mousePosition
			-- local ui_pos = UIUtil.screenToWorldPoint(input_pos)
			-- local word_pos = SceneManager.curScene.cameraController.Camera_UI:ScreenToWorldPoint(input_pos)

			input_pos.x = input_pos.x/U3DUtil:Screen_Width()*self.rect.width
			input_pos.y = input_pos.y/U3DUtil:Screen_Height()*self.rect.height
			if not IsNull(self.m_effect_obj) then
				self.m_effect_obj.transform.localPosition = input_pos
				-- local local_pos = self.m_effect_obj.transform.localPosition
				-- local_pos.z = 0
				-- self.m_effect_obj.transform.localPosition = local_pos
				self.m_effect:Play()
			end
		end
	end
end

function M:setFrameVisibleStatus(flag)
	if flag == nil then
		self.g_screen_effect = UserDataManager.local_data:getLocalDataByKey("effectShow", 1)
		local gameFPS = UserDataManager.local_data:getLocalDataByKey("gameFPS",0)
		-- self:setObjectVisible("frame_text", gameFPS > 0)
		self:setObjectVisible("frame_text", false)
	else
		self:setObjectVisible("frame_text", flag)
		self:setObjectVisible("UI_CommonClickEffect", flag)
	end
	self:setObjectVisible("frame_text", false)
end

function M:destroy()
	CS.ScreenShot.screenClickObj = nil
	M.super.destroy(self)
end

return M