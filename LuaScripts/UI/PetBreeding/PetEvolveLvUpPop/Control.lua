---@class PetEvolveLvUpPopControl: OOControlBase
---@field m_model PetEvolveLvUpPopModel
---@field m_view PetEvolveLvUpPopView
local M = class("PetEvolveLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
		self.m_model.m_isOk = true
	    self:closeView()
	elseif msg == "cancel_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
	    self:closeView()
	elseif msg == "select_btn" then 
		self.m_model:changeTipsState()
		self.m_view:refreshCheckImg()
    end
end

return M;
