local M = class("SettingView",LikeOO.OOPopBase)

M.m_uiName = "Pops/Setting"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()

end


return M