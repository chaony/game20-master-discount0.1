local M = class("NoticePopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent") 
        if( self.m_model.m_params.onCloseCallback) then 
            self.m_model.m_params.onCloseCallback()
        end
        self:closeView()

        SDKUtil:sendBitrack(SDKUtil.BI_NoticeShow)
    elseif msg == "click_cell" then
        self.m_model:setSelectIndex(data)
        self.m_view:refreshUI()
    elseif msg == "url_btn" then
        local notice = self.m_model:getNoticeByIndex(self.m_model.m_select_index)
        -- SDKUtil:openUrl(notice.url)    
    end
end

return M;
