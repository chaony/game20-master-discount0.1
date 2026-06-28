--- 多阵容
local M = class("FormationAddition",LikeOO.OOUIbase)

M.m_uiName = "Formation/FormationAddition"

function M:onEnter()
    audio:SendEvtUI("UI_ShiLiJiHuo")
    self.m_transfer = "scale"
    self:refreshUI()
    self.m_control:setOnceTimer(3,function ()
        if self.m_control then
            self:destroy()
        end
    end)
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	end
end



function M:refreshUI()
    self.m_callback = self.m_params.callback
end

function M:destroy()
    self.m_transfer = ""
    if self.m_callback then
        self.m_callback()
    end
    M.super.destroy(self)
end

return M