local M = class("TalisManmentSuccessPopView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroTalisMan/TalisManmentSuccessPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end


function M:refreshUI()

end



function M:destroy()
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	M.super.destroy(self)
end

return M