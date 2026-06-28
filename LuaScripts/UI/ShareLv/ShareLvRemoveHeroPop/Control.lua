local M = class("ShareLvRemoveHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
		self.m_model.m_params.callback(self.m_model.m_params.data)
		self:closeView()
	elseif msg == "cancle_btn" then
		self:closeView()
    end
end

return M
