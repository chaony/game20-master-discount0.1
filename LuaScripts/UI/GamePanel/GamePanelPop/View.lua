local M = class("CommonPopView",LikeOO.OOPopBase)

M.m_uiName = "GamePanel/GamePanelPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("btn_1_text", self.m_model.m_btn1_text)
	self:setText("btn_2_text", self.m_model.m_btn2_text)
	self:setText("btn_3_text", self.m_model.m_btn3_text)
	local stage = UserDataManager:getCurStage()
	self:setObjectVisible("btn_2", stage > 0)
	self:setObjectVisible("btn_3", self.m_model:showRestartBtn())
end

function M:refreshUI()
	
end


return M